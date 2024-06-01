uses
	sdl2,
	sqldb,
	sqlite3conn,
	sysutils,

	log,
	running,
	gametypes;

function Init() : Gamestate;
var
	game : Gamestate;
begin
	game.logger := NewLogger();

	case GetEnvironmentVariable('LOG_LEVEL') of
	'ERROR':
		 game.logger.level := error;
	'INFO':
		 game.logger.level := info;
	'DEBUG':
		 game.logger.level := debug;
	end;

	game.window := Nil;
	game.renderer := Nil;

	if SDL_Init(SDL_INIT_VIDEO) < 0 then
	begin
		LogError(game.logger, SDL_GetError());
	end;

	if SDL_CreateWindowAndRenderer(640, 480, 0, @game.window, @game.renderer) < 0 then
	begin
		LogError(game.logger, SDL_GetError());
	end;

	Init := game;
end;

function GameSetup(game : Gamestate) : Gamestate;
var
	i : Smallint;
begin
	game.c.x := 0;
	game.c.y := 0;

	for i := Low(game.gems) to High(game.gems) div 2 do
	with game.gems[i] do
	begin
		x := i * 10 + 20;
		y := 30;
		hue := i * 25;
		visible := true;
	end;
	for i := High(game.gems) div 2 + 1 to High(game.gems) do
	with game.gems[i] do
	begin
		x := (i - (High(game.gems) div 2 + 1)) * 10 + 20;
		y := 40;
		hue := Random(256);
		visible := true;
	end;

	game.lootNum := 0;

	GameSetup := game;
end;

function ScoreGame(game : Gamestate) : Integer;
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
	LogDebug(game.logger, createTableGames);
	conn.ExecuteDirect(createTableGames);
	LogDebug(game.logger, createTableScores);
	conn.ExecuteDirect(createTableScores);
	t.Commit;

	t.StartTransaction;

	for i := Low(game.loot) to game.lootNum - 1 do
	begin
		sum := sum + game.loot[i].hue;
	end;

	q := TSQLQuery.Create(nil);
	q.Database := conn;
	q.Transaction := t;
	q.SQL.Text := 'INSERT INTO games (sum) VALUES (:sum) RETURNING id;';
	q.Params.ParamByName('sum').AsInteger := sum;
	LogDebug(game.logger, q.SQL.Text);
	q.Open;
	gameId := q.FieldByName('id').AsInteger;
	q.Close;

	for i := Low(game.loot) to game.lootNum - 1 do
	begin
		q.SQL.Text := 'INSERT INTO scores (score, game_id) VALUES (:score, :game_id);';
		q.Params.ParamByName('score').AsInteger := game.loot[i].hue;
		q.Params.ParamByName('game_id').AsInteger := gameId;
		LogDebug(game.logger, q.SQL.Text);
		q.ExecSQL;
	end;

	t.Commit;

	ScoreGame := sum;
end;

procedure GameLoop(game : Gamestate);
var
	phase : GamePhase = GamePhase.running;
begin
	while phase <> GamePhase.quit do
	begin

		case phase of
		GamePhase.running:
		begin
			phase := RunningUpdate(game);
		end;

		GamePhase.score:
		begin
			Writeln('Game over!');
			Writeln('Score: ', ScoreGame(game));

			phase := quit;
		end;

		end;

		SDL_Delay(20);
	end;
end;

var
	game : Gamestate;
begin
	game := Init();
	game := GameSetup(game);
	GameLoop(game);
end.
