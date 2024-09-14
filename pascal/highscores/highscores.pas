uses
	sdl2,
	sysutils,

	arenas,
	game,
	mainmenu,
	phases,
	running,
	scores;

type
	ProgramState = record
		window   : PSDL_Window;
		renderer : PSDL_Renderer;
		phase    : phases.Phase;
		game     : game.State;
		menu     : mainMenu.State;
		scores   : scores.State;
	end;

procedure Init(var state : ProgramState);
begin
	state.window := Nil;
	state.renderer := Nil;

	case GetEnvironmentVariable('LOG_LEVEL') of
		'ERROR': SDL_LogSetAllPriority(SDL_LOG_PRIORITY_ERROR);
		'INFO':  SDL_LogSetAllPriority(SDL_LOG_PRIORITY_INFO);
		'DEBUG': SDL_LogSetAllPriority(SDL_LOG_PRIORITY_DEBUG);
	end;

	SDL_SetHint(SDL_HINT_RENDER_VSYNC, '1');

	if SDL_Init(SDL_INIT_VIDEO) < 0 then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [SDL_GetError()]);
	end;

	if SDL_CreateWindowAndRenderer(640, 480, 0, @state.window, @state.renderer) < 0 then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [SDL_GetError()]);
	end;
end;

procedure GameLoop(var state : ProgramState);
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
		end;

		SDL_RenderPresent(state.renderer);
	end;
end;

var
	a     : arenas.Arena;
	state : ProgramState;
begin
	a := arenas.New(4096);
	Init(state);
	state.game := game.New();
	state.menu := mainMenu.New(state.renderer, ['NEW GAME', 'HIGH SCORES'] );
	state.scores := scores.New(a, state.renderer);
	state.phase := phases.Phase.mainMenu;
	GameLoop(state);
end.
