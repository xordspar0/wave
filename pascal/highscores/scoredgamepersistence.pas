unit scoredgamepersistence;

interface

uses
	arenas,
  scoredgames;

procedure InsertScoredGame(game : scoredgames.ScoredGame);
function SelectTop5ScoredGames(var a : arenas.Arena) : ScoredGameList;

implementation

uses
	sqldb,
	sqlite3conn,

	sdl2;

function Open() : TSQLite3Connection;
const
	filename = 'scores.db';
var
	conn : TSQLite3Connection;
begin
	conn := TSQLite3Connection.Create(nil);
	conn.DatabaseName := filename;
	conn.Transaction := TSQLTransaction.Create(conn);
	conn.Open;

	Open := conn;
end;

procedure CreateTableGames(conn : TSQLite3Connection);
const
	createTableGames = 'CREATE TABLE if not exists games (' +
			'id integer primary key, sum integer, date timestamp DEFAULT CURRENT_TIMESTAMP' +
		');';
	createTableGems = 'CREATE TABLE if not exists gems (' +
			'value integer, game_id integer, foreign key (game_id) references games(id)' +
		');';
begin
	conn.Transaction.StartTransaction;

	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(createTableGames)]);
	conn.ExecuteDirect(createTableGames);
	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(createTableGems)]);
	conn.ExecuteDirect(createTableGems);

	conn.Transaction.Commit;
end;

procedure InsertScoredGame(game : scoredgames.ScoredGame);
var
	conn   : TSQLite3Connection;
	q      : TSQLQuery;
	sum    : Integer = 0;
	gameId : Integer = 0;
	gem    : scoredGames.Gem;
begin
	conn := Open();

	CreateTableGames(conn);

	conn.Transaction.StartTransaction;

	q := TSQLQuery.Create(nil);
	q.Database := conn;
	q.Transaction := conn.Transaction;
	q.SQL.Text := 'INSERT INTO games (sum) VALUES (:sum) RETURNING id;';
	q.Params.ParamByName('sum').AsInteger := sum;
	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s [%d]', [PChar(q.SQL.Text), sum]);
	q.Open;
	gameId := q.FieldByName('id').AsInteger;
	q.Close;

	for gem in game.gems do
	begin
		q.SQL.Text := 'INSERT INTO gems (value, game_id) VALUES (:value, :game_id);';
		q.Params.ParamByName('value').AsInteger := gem;
		q.Params.ParamByName('game_id').AsInteger := gameId;
		SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s [%d, %d]', [PChar(q.SQL.Text), gem, gameId]);
		q.ExecSQL;
	end;

	conn.Transaction.Commit;
end;

function SelectTop5ScoredGames(var a : arenas.Arena) : ScoredGameList;
var
	conn       : TSQLite3Connection;
	gamesQuery : TSQLQuery;
	gemsQuery  : TSQLQuery;
	scores     : array of scoredgames.ScoredGame;
	i          : Integer = 0;
	j          : Integer = 0;
	gameId     : Integer;
begin
	conn := Open();
	CreateTableGames(conn);

	scores := arenas.Alloc(a, SizeOf(scores), 5);

	gamesQuery := TSQLQuery.Create(nil);
	gamesQuery.Database := conn;
	gemsQuery := TSQLQuery.Create(nil);
	gemsQuery.Database := conn;

	with gamesQuery do
	begin
		SQL.Text := 'SELECT * FROM games ORDER BY sum LIMIT 5;';
		SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(SQL.Text)]);
		Open;

		while not EOF do
		begin
			gameId := FieldByName('id').AsInteger;
			scores[i].sum := FieldByName('sum').AsInteger;

			with gemsQuery do
			begin
				SQL.Text := 'SELECT * FROM gems WHERE game_id = :game_id;';
				Params.ParamByName('game_id').AsInteger := gameId;
				SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s [%d]', [PChar(SQL.Text), gameId]);
				Open;

				while not EOF do
				begin
					scores[i].gems[j] := FieldByName('value').AsInteger;
					Next;
					Inc(j);
				end;
				Close;
			end;

			Next;
			Inc(i);
		end;

		Close;
	end;

	SelectTop5ScoredGames := scores;
end;

end.
