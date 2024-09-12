unit gamepersistence;

interface

uses
  scoredgames;

procedure PersistScoredGame(game : scoredgames.ScoredGame);

implementation

uses
  sqldb,
  sqlite3conn,

  sdl2;

procedure PersistScoredGame(game : scoredgames.ScoredGame);
const
	createTableGames = 'CREATE TABLE if not exists games (' +
			'id integer primary key, sum integer, date timestamp DEFAULT CURRENT_TIMESTAMP' +
		');';
	createTableGems = 'CREATE TABLE if not exists gems (' +
			'value integer, game_id integer, foreign key (game_id) references games(id)' +
		');';
var
	conn   : TSQLite3Connection;
	t      : TSQLTransaction;
	q      : TSQLQuery;
	sum    : Integer = 0;
	gameId : Integer = 0;
	gem    : scoredGames.Gem;
begin
	conn := TSQLite3Connection.Create(nil);
	conn.DatabaseName := 'scores.db';
	t := TSQLTransaction.Create(conn);
	conn.Transaction := t;
	conn.Open;

	t.StartTransaction;
	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(createTableGames)]);
	conn.ExecuteDirect(createTableGames);
	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(createTableGems)]);
	conn.ExecuteDirect(createTableGems);
	t.Commit;

	t.StartTransaction;

	q := TSQLQuery.Create(nil);
	q.Database := conn;
	q.Transaction := t;
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

	t.Commit;
end;

end.
