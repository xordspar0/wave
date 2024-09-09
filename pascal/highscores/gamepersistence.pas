unit gamepersistence;

interface

uses
  game;

procedure PersistScore(state : game.State);

implementation

uses
  sqldb,
  sqlite3conn,

  sdl2;

procedure PersistScore(state : game.State);
const
	createTableGames = 'CREATE TABLE if not exists games (' +
			'id integer primary key, sum integer, date timestamp DEFAULT CURRENT_TIMESTAMP' +
		');';
	createTableScores = 'CREATE TABLE if not exists scores (' +
			'score integer, game_id integer, foreign key (game_id) references games(id)' +
		');';
var
	conn   : TSQLite3Connection;
	t      : TSQLTransaction;
	q      : TSQLQuery;
	i      : Smallint = 0;
	sum    : Integer = 0;
	gameId : Integer = 0;
begin
	conn := TSQLite3Connection.Create(nil);
	conn.DatabaseName := 'scores.db';
	t := TSQLTransaction.Create(conn);
	conn.Transaction := t;
	conn.Open;

	t.StartTransaction;
	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(createTableGames)]);
	conn.ExecuteDirect(createTableGames);
	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(createTableScores)]);
	conn.ExecuteDirect(createTableScores);
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

	for i := Low(state.loot) to state.lootNum - 1 do
	begin
		q.SQL.Text := 'INSERT INTO scores (score, game_id) VALUES (:score, :game_id);';
		q.Params.ParamByName('score').AsInteger := state.loot[i].hue;
		q.Params.ParamByName('game_id').AsInteger := gameId;
		SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s [%d, %d]', [PChar(q.SQL.Text), state.loot[i].hue, gameId]);
		q.ExecSQL;
	end;

	t.Commit;
end;

end.
