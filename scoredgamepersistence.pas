unit scoredgamepersistence;

interface

uses
	arenas,
  scoredgames;

procedure InsertScoredGame(game : scoredgames.ScoredGame);
function SelectTop5ScoredGames(var a : arenas.Arena) : ScoredGameList;

implementation

uses
	sqlite3,
	sysutils,

	sdl2;

function Open() : psqlite3;
const
	filename = 'scores.db';
var
	db     : psqlite3;
	result : Integer;
begin
	result := sqlite3_open(filename, @db);
	if result <> SQLITE_OK then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
		Abort();
	end;

	Open := db;
end;

procedure Close(db : psqlite3);
begin
	sqlite3_close(db);
end;

procedure Exec(db : psqlite3; SQL : UTF8String);
var
	err : PChar;
begin
	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(SQL)]);
	sqlite3_exec(db, PChar(SQL), Nil, Nil, @err);
	if err <> Nil then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [err]);
		Abort();
	end;
end;

procedure BeginTransaction(db : psqlite3);
const
	SQL = 'begin transaction;';
begin
	Exec(db, SQL);
end;

procedure Commit(db : psqlite3);
const
	SQL = 'commit;';
begin
	Exec(db, SQL);
end;

procedure CreateTableGames(db : psqlite3);
const
	SQL = 'begin transaction; ' +
		'CREATE TABLE if not exists games (' +
			'id integer primary key, sum integer, date timestamp DEFAULT CURRENT_TIMESTAMP' +
		'); ' +
		'CREATE TABLE if not exists gems (' +
			'value integer, game_id integer, foreign key (game_id) references games(id)' +
		'); ' +
		'commit;';
begin
	Exec(db, SQL);
end;

procedure InsertScoredGame(game : scoredgames.ScoredGame);
var
	db     : psqlite3;
	q      : psqlite3_stmt;
	SQL    : UTF8String;
	status : Integer = 0;
	gameId : Integer = 0;
	gem    : scoredGames.Gem;
begin
	db := Open();

	CreateTableGames(db);

	BeginTransaction(db);

	SQL := 'INSERT INTO games (sum) VALUES (:sum) RETURNING id;';
	status := sqlite3_prepare_v2(db, PChar(SQL), Length(SQL), @q, Nil);
	if status <> SQLITE_OK then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
		Abort();
	end;

	status := sqlite3_bind_int(q, 1, game.sum);
	if status <> SQLITE_OK then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
		Abort();
	end;

	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s [%d]', [PChar(SQL), game.sum]);
	if sqlite3_step(q) <> SQLITE_ROW then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
		Abort();
	end;

	gameId := sqlite3_column_int(q, 0);

	sqlite3_finalize(q);

	SQL := 'INSERT INTO gems (value, game_id) VALUES (:value, :game_id);';
	status := sqlite3_prepare_v2(db, PChar(SQL), Length(SQL), @q, Nil);
	if status <> SQLITE_OK then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
		Abort();
	end;

	for gem in game.gems do
	begin
		sqlite3_reset(q);

		status := sqlite3_bind_int(q, 1, gem);
		if status <> SQLITE_OK then
		begin
			SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
			Abort();
		end;

		status := sqlite3_bind_int(q, 2, gameId);
		if status <> SQLITE_OK then
		begin
			SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
			Abort();
		end;

		SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s [%d, %d]', [PChar(SQL), gem, gameId]);
		if not sqlite3_step(q) in [SQLITE_ROW, SQLITE_DONE] then
		begin
			SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
			Abort();
		end;
	end;

	sqlite3_finalize(q);

	Commit(db);
	Close(db);
end;

function SelectTop5ScoredGames(var a : arenas.Arena) : ScoredGameList;
const
	selectFromGames = 'SELECT id, sum FROM games ORDER BY sum LIMIT 5;';
	selectFromGems  = 'SELECT value FROM gems WHERE game_id = :game_id;';
var
	db         : psqlite3;
	gamesQuery : psqlite3_stmt;
	gemsQuery  : psqlite3_stmt;
	status     : Integer = 0;
	scores     : scoredgames.ScoredGameList;
	i          : Integer = 0;
	j          : Integer = 0;
	gameId     : Integer = 0;
begin
	db := Open();
	CreateTableGames(db);

	BeginTransaction(db);

	scores.cap := 5;
	scores.games := arenas.Alloc(a, SizeOf(scoredgames.ScoredGame), scores.cap);

	status := sqlite3_prepare_v2(db, PChar(selectFromGames), Length(selectFromGames), @gamesQuery, Nil);
	if status <> SQLITE_OK then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
		Abort();
	end;

	status := sqlite3_prepare_v2(db, PChar(selectFromGems), Length(selectFromGems), @gemsQuery, Nil);
	if status <> SQLITE_OK then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [sqlite3_errmsg(db)]);
		Abort();
	end;

	SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(selectFromGames)]);
	while sqlite3_step(gamesQuery) <> SQLITE_DONE do
	begin
		gameId := sqlite3_column_int(gamesQuery, 0);
		scores.games[i].sum := sqlite3_column_int(gamesQuery, 1);

		sqlite3_reset(gemsQuery);
		sqlite3_bind_int(gemsQuery, 1, gameId);
		SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s [%d]', [PChar(selectFromGems), gameId]);

		j := 0;
		while sqlite3_step(gemsQuery) <> SQLITE_DONE do
		begin
			scores.games[i].gems[j] := sqlite3_column_int(gemsQuery, 0);
			Inc(j);
		end;

		Inc(i);
	end;

	sqlite3_finalize(gamesQuery);
	sqlite3_finalize(gemsQuery);

	Commit(db);

	Close(db);

	SelectTop5ScoredGames := scores;
end;

end.
