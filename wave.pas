uses
	SDL3,
	SDL3_image,

	arenas,
	drawables,
	game,
	mainmenu,
	phases,
	running,
	scores,
	sprites;

type
	ProgramState = record
		window      : PSDL_Window;
		renderer    : PSDL_Renderer;
		spritesheet : PSDL_Texture;
		sprites     : sprites.SpriteDataList;
		phase       : phases.Phase;
		game        : game.State;
		menu        : mainMenu.State;
		scores      : scores.State;
	end;

procedure Init(var state : ProgramState);
begin
	state.window := Nil;
	state.renderer := Nil;

	if not SDL_SetAppMetadata('WAVE', '0.1', 'xyz.neolog.wave') then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [SDL_GetError()]);
	end;

	SDL_SetHint(SDL_HINT_RENDER_VSYNC, '1');

	if not SDL_Init(SDL_INIT_VIDEO) then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [SDL_GetError()]);
	end;

	if not SDL_CreateWindowAndRenderer('Wave', 640, 480, 0, @state.window, @state.renderer) then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, '%s', [SDL_GetError()]);
	end;

	state.spritesheet := IMG_LoadTexture(state.renderer, 'dice.png');
	if state.spritesheet = Nil then
	begin
		SDL_LogError(SDL_LOG_CATEGORY_APPLICATION, 'Failed to load spritesheet: %s', [SDL_GetError()]);
	end;
end;

procedure DrawFilledRect(renderer : PSDL_Renderer; obj : drawables.DrawObject);
var
	sdlRect : TSDL_FRect;
begin
	Assert(obj.objectType = drawables.FilledRect);

	sdlRect.x := obj.x;
	sdlRect.y := obj.y;
	sdlRect.w := obj.w;
	sdlRect.h := obj.h;

	SDL_SetRenderDrawColor(renderer, obj.c.r, obj.c.g, obj.c.b, SDL_ALPHA_OPAQUE);
	SDL_RenderFillRect(renderer, @sdlRect);
	SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);
end;

procedure DrawTexture(renderer : PSDL_Renderer; spriteList: sprites.SpriteDataList; obj : drawables.DrawObject);
const
	topLeft : TSDL_Point = (x: 0; y: 0);
var
	sprite  : sprites.SpriteData;
	dst     : TSDL_FRect;
	center  : PSDL_FPoint;
begin
	Assert(obj.objectType = drawables.Texture);

	sprite := spriteList[Ord(obj.sprite)];

	dst.x := obj.x;
	dst.y := obj.y;
	dst.w := sprite.rect.w;
	dst.h := sprite.rect.h;

	case obj.o of
		drawables.Origin.Center:
			center := Nil;
		drawables.Origin.TopLeft:
			center := @topLeft;
	end;

	SDL_SetRenderDrawColor(renderer, obj.c.r, obj.c.g, obj.c.b, SDL_ALPHA_OPAQUE);
	SDL_RenderTextureRotated(
		renderer, sprite.spritesheet,
		@sprite.rect, @dst,
		obj.r, center, SDL_FLIP_NONE
	);
	SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);
end;

procedure GameLoop(var state : ProgramState);
var
	event : TSDL_Event;

	objects : drawables.DrawObjectList;
	obj : drawables.DrawObject;
begin
	while state.phase <> phases.Phase.quit do
	begin
		SDL_SetRenderDrawColor(state.renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
		SDL_RenderClear(state.renderer);

		while SDL_PollEvent(@event) do
		begin
			case event.type_ of
				SDL_EVENT_QUIT: state.phase := quit;
				SDL_EVENT_KEY_DOWN:
					if not event.key.repeat_ then
					case state.phase of
						phases.Phase.mainmenu:
							MainMenu.KeyDown(state.menu, event.key.key);
						phases.Phase.scores:
							Scores.KeyDown(state.scores, event.key.key);
						phases.Phase.running:
							Running.KeyDown(state.game, event.key.key);
					end;
				SDL_EVENT_MOUSE_BUTTON_DOWN:
					case state.phase of
						phases.Phase.mainmenu:
							MainMenu.MouseButtonDown(state.menu, event.button.button, event.button.x, event.button.y);
						phases.Phase.running:
							Running.MouseButtonDown(state.game, event.button.button, event.button.x, event.button.y);
					end;
			end;
		end;

		case state.phase of
			phases.Phase.mainmenu:
			begin
				state.phase := mainmenu.Update(state.menu);
				objects := MainMenu.Draw(state.menu);
			end;

			phases.Phase.scores:
			begin
				state.phase := scores.Update(state.scores);
				scores.Draw(state.scores);
				objects := [];
			end;

			phases.Phase.running:
			begin
				state.phase := running.Update(state.game);
				objects := Running.Draw(state.renderer, state.spritesheet, state.game);
			end;
		end;

		SDL_LogDebug(SDL_LOG_CATEGORY_APPLICATION, '%s', [PChar(DrawObjectsToString(objects))]);

		for obj in objects do
		case obj.objectType of
		FilledRect:
			DrawFilledRect(state.renderer, obj);
		Texture:
			DrawTexture(state.renderer, state.sprites, obj);
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
	state.sprites := sprites.Load(state.renderer);
	state.game := game.New();
	state.menu := mainMenu.New(state.renderer, ['NEW GAME', 'HIGH SCORES'] );
	state.scores := scores.New(a, state.renderer);
	state.phase := phases.Phase.mainMenu;
	GameLoop(state);
end.
