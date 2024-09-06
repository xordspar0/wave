uses
	ctypes,

	sdl2,
	sqldb,
	sqlite3conn,
	sysutils,

	game,
	log,
	mainmenu,
	phases,
	running,
	scores,
	states;

procedure Init(var state : states.State);
begin
	state.logger := log.NewLogger();

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
end;

function ScoreGame(state : states.State) : Integer;
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

	for i := Low(state.game.loot) to state.game.lootNum - 1 do
	begin
		sum := sum + state.game.loot[i].hue;
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

	for i := Low(state.game.loot) to state.game.lootNum - 1 do
	begin
		q.SQL.Text := 'INSERT INTO scores (score, game_id) VALUES (:score, :game_id);';
		q.Params.ParamByName('score').AsInteger := state.game.loot[i].hue;
		q.Params.ParamByName('game_id').AsInteger := gameId;
		LogDebug(state.logger, q.SQL.Text);
		q.ExecSQL;
	end;

	t.Commit;

	ScoreGame := sum;
end;

procedure GameLoop(var state : states.State);
var
	event : TSDL_Event;
begin
	while state.phase <> phases.Phase.quit do
	begin
		SDL_SetRenderDrawColor(state.renderer, 0, 0, 0, 0);
		SDL_RenderClear(state.renderer);

		while SDL_PollEvent(@event) = 1 do
		begin
			case event.type_ of
				SDL_QUITEV: state.phase := quit;
				SDL_KEYDOWN:
					if event.key.repeat_ = 0 then
					case state.phase of
						phases.Phase.mainmenu:
							MainMenu.KeyDown(state.menu, event.key.keysym.sym);
						phases.Phase.scores:
							Scores.KeyDown(state.scores, event.key.keysym.sym);
						phases.Phase.running:
							Running.KeyDown(state.game, event.key.keysym.sym);
					end;
				SDL_MOUSEBUTTONDOWN:
					case state.phase of
						phases.Phase.mainmenu:
							mainMenu.MouseButtonDown(state.menu, event.button.button, event.button.x, event.button.y);
					end;
			end;
		end;

		case state.phase of
		phases.Phase.mainmenu:
		begin
			state.phase := mainmenu.Update(state.menu);
			MainMenu.Draw(state.menu);
		end;

		phases.Phase.scores:
		begin
			state.phase := scores.Update(state.scores);
			scores.Draw(state.scores);
		end;

		phases.Phase.running:
		begin
			state.phase := running.Update(state.game);
			Running.Draw(state.renderer, state.game);
		end;

		phases.Phase.score:
		begin
			Writeln('Game over!');
			Writeln('Score: ', ScoreGame(state));

			state.phase := quit;
		end;

		end;

		SDL_RenderPresent(state.renderer);
		SDL_Delay(20);
	end;
end;

var
	s : states.State;
begin
	Init(s);
	s.game := game.New();
	s.menu := mainMenu.New(s.renderer, ['NEW GAME', 'HIGH SCORES'] );
	s.scores := scores.New(s.renderer);
	s.phase := phases.Phase.mainMenu;
	GameLoop(s);
end.
