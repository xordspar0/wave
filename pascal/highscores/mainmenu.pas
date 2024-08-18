unit mainmenu;

interface

uses
	sdl2,
	
	game,
	text;

type
	State = record
		renderer     : PSDL_Renderer;
		selected     : Smallint;
		textBuffer   : PSDL_Texture;
		textRenderer : text.State;
	end;

function New(renderer : PSDL_Renderer) : mainmenu.State;
function Update(var state : mainmenu.State) : game.Phase;
procedure Draw(state : mainmenu.State);

implementation

uses
	color;

const
	buttonWidth   : integer = 250;
	buttonHeight  : integer = 48;
	buttonPadding : integer = 5;
	buttonMargin  : integer = 10;

function New(renderer : PSDL_Renderer) : mainmenu.State;
begin
	New.renderer := renderer;
	New.selected := 0;
	New.textBuffer := SDL_CreateTexture(
		renderer,
		SDL_PIXELFORMAT_RGBA32,
		SDL_TEXTUREACCESS_TARGET,
		buttonWidth - buttonPadding * 2,
		buttonHeight - buttonPadding * 2
	);
	New.textRenderer := text.New(renderer);
end;

function Update(var state : mainmenu.State) : game.Phase;
var
	event : TSDL_Event;
begin
	Update := game.Phase.mainmenu;

	while SDL_PollEvent(@event) = 1 do
	begin
		case event.type_ of
		SDL_QUITEV: Update := quit;
		SDL_KEYDOWN:
			if event.key.repeat_ = 0 then
			case event.key.keysym.sym of
			SDLK_UP:		 state.selected -= 1;
			SDLK_DOWN:	 state.selected += 1;
			SDLK_RETURN: Update := running;
			end;
		end;
	end;

end;

procedure Draw(state : mainmenu.State);
const
	labels     : array[1..2] of string = ('NEW GAME', 'HIGH SCORES');
var
	i          : integer;
	buttonRect : TSDL_Rect;
	textRect   : TSDL_Rect;
begin
	for i := Low(labels) to High(labels) do
	begin
		with buttonRect do
		begin
			x := 20;
			y := i * (buttonHeight + buttonMargin);
			w := buttonWidth;
			h := buttonHeight;
		end;

		with textRect do
		begin
			x := buttonRect.x + buttonPadding;
			y := buttonRect.y + buttonPadding;
			w := buttonRect.w - buttonPadding * 2;
			h := buttonRect.h - buttonPadding * 2;
		end;

		SDL_SetRenderDrawColor(state.renderer, 150, 150, 150, 0);
		SDL_RenderFillRect(state.renderer, @buttonRect);

		SDL_SetRenderTarget(state.renderer, state.textBuffer);
		SDL_SetRenderDrawColor(state.renderer, 0, 0, 0, 0);
		SDL_RenderClear(state.renderer);
		SDL_SetRenderDrawColor(state.renderer, 255, 255, 255, 0);
		RenderText(state.renderer, state.textRenderer, labels[i]);

		{ TODO: Respect transparency in the text buffer when copying to the screen. }
		SDL_SetRenderTarget(state.renderer, Nil);
		SDL_RenderCopy(state.renderer, state.textBuffer, Nil, @textRect);
	end;
end;

end.

