uses
	ctypes,

	sdl2,
	sqldb,
	sqlite3conn,
	sysutils,

	game,
	log,
	mainmenu,
	running;

procedure MouseButtonDown(var state : game.State; button : Integer; x, y : Integer);
begin
	state.c.x := 0;
end;

function ReceivedEvent(userdata : Pointer; event : PSDL_Event) : cint; cdecl;
var
	state : ^game.State;
begin
	state := userdata;

	case event^.type_ of
	SDL_MOUSEBUTTONDOWN:
		MouseButtonDown(state^, event^.button.button, event^.button.x, event^.button.y);
	end;

	ReceivedEvent := 1;
end;

procedure Init(var state : game.State);
begin
	state.logger := NewLogger();

	case GetEnvironmentVariable('LOG_LEVEL') of
	'ERROR':
		 state.logger.level := error;
	'INFO':
		 state.logger.level := info;
	'DEBUG':
		 state.logger.level := debug;
	end;

	state.window := Nil;
	state.renderer := Nil;

	if SDL_Init(SDL_INIT_VIDEO) < 0 then
	begin
		LogError(state.logger, SDL_GetError());
	end;

	if SDL_CreateWindowAndRenderer(640, 480, 0, @state.window, @state.renderer) < 0 then
	begin
		LogError(state.logger, SDL_GetError());
	end;

	SDL_AddEventWatch(@ReceivedEvent, @state);
end;

function ScoreGame(state : game.State) : Integer;
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
	LogDebug(state.logger, createTableGames);
	conn.ExecuteDirect(createTableGames);
	LogDebug(state.logger, createTableScores);
	conn.ExecuteDirect(createTableScores);
	t.Commit;

	t.StartTransaction;

	for i := Low(state.loot) to state.lootNum - 1 do
	begin
		sum := sum + state.loot[i].hue;
	end;

	q := TSQLQuery.Create(nil);
	q.Database := conn;
	q.Transaction := t;
	q.SQL.Text := 'INSERT INTO games (sum) VALUES (:sum) RETURNING id;';
	q.Params.ParamByName('sum').AsInteger := sum;
	LogDebug(state.logger, q.SQL.Text);
	q.Open;
	gameId := q.FieldByName('id').AsInteger;
	q.Close;

	for i := Low(state.loot) to state.lootNum - 1 do
	begin
		q.SQL.Text := 'INSERT INTO scores (score, game_id) VALUES (:score, :game_id);';
		q.Params.ParamByName('score').AsInteger := state.loot[i].hue;
		q.Params.ParamByName('game_id').AsInteger := gameId;
		LogDebug(state.logger, q.SQL.Text);
		q.ExecSQL;
	end;

	t.Commit;

	ScoreGame := sum;
end;

procedure GameLoop(var state : game.State);
var
	phase     : game.Phase = game.Phase.mainmenu;
	menuState : mainmenu.State;
begin
	menuState := mainmenu.New(state.renderer);

	while phase <> game.Phase.quit do
	begin
		SDL_SetRenderDrawColor(state.renderer, 0, 0, 0, 0);
		SDL_RenderClear(state.renderer);

		case phase of
		game.Phase.mainmenu:
		begin
			phase := MainMenu.Update(menuState);
			MainMenu.Draw(menuState);
		end;

		game.Phase.running:
		begin
			phase := Running.Update(state);
			Running.Draw(state);
		end;

		game.Phase.score:
		begin
			Writeln('Game over!');
			Writeln('Score: ', ScoreGame(state));

			phase := quit;
		end;

		end;

		SDL_RenderPresent(state.renderer);
		SDL_Delay(20);
	end;
end;

var
	state : game.State;
begin
	state := game.New();
	Init(state);
	GameLoop(state);
end.
