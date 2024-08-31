unit mainmenu;

interface

uses
	sdl2,
	
	game,
	phases,
	text;

type
	Button = record
		x, y, w, h : Integer;
		text       : String;
	end;

	State = record
		renderer     : PSDL_Renderer;
		selected     : Smallint;
		textBuffer   : PSDL_Texture;
		textRenderer : text.State;
		buttons      : array[0..1] of Button;
	end;

function New(renderer : PSDL_Renderer; labels : array of string) : mainmenu.State;
function Update(var state : mainmenu.State) : phases.Phase;
procedure Draw(state : mainmenu.State);

function MouseButtonDown(var state : mainmenu.State; _ : Integer; x, y : Integer) : phases.Phase;

implementation

uses
	color;

const
	buttonWidth   : integer = 250;
	buttonHeight  : integer = 48;
	buttonPadding : integer = 5;
	buttonMargin  : integer = 10;

function New(renderer : PSDL_Renderer; labels : array of string) : mainmenu.State;
var
	i : Integer;
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
	SDL_SetTextureBlendMode(New.textBuffer, SDL_BLENDMODE_BLEND);
	New.textRenderer := text.New(renderer);

	for i := Low(labels) to High(labels) do
	begin
		with New.buttons[i] do
		begin
			x := 20;
			y := (i+1) * (buttonHeight + buttonMargin);
			w := buttonWidth;
			h := buttonHeight;
			text := labels[i];
		end;
	end;
end;

function Update(var state : mainmenu.State) : phases.Phase;
var
	event : TSDL_Event;
begin
	Update := phases.Phase.mainmenu;

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
var
	button     : mainmenu.Button;
	buttonRect : TSDL_Rect;
	textRect   : TSDL_Rect;
begin
	for button in state.buttons do
	begin
		with buttonRect do
		begin
			x := button.x;
			y := button.y;
			w := button.w;
			h := button.h;
		end;

		with textRect do
		begin
			x := buttonRect.x + buttonPadding;
			y := buttonRect.y + buttonPadding;
			w := buttonRect.w - buttonPadding * 2;
			h := buttonRect.h - buttonPadding * 2;
		end;

		SDL_SetRenderDrawColor(state.renderer, 120, 120, 120, 0);
		SDL_RenderFillRect(state.renderer, @buttonRect);

		SDL_SetRenderTarget(state.renderer, state.textBuffer);
		SDL_SetRenderDrawColor(state.renderer, 0, 0, 0, 0);
		SDL_RenderClear(state.renderer);
		SDL_SetRenderDrawColor(state.renderer, 255, 255, 255, 255);
		RenderText(state.renderer, state.textRenderer, button.text);

		SDL_SetRenderTarget(state.renderer, Nil);
		SDL_RenderCopy(state.renderer, state.textBuffer, Nil, @textRect);
	end;
end;

function MouseButtonDown(var state : mainmenu.State; _ : Integer; x, y : Integer) : phases.Phase;
var
	b : mainmenu.Button;
begin
	for b in state.buttons do
	begin
		if (x > b.x) and (x < b.x + b.w)
			and (y > b.y) and (y < b.y + b.h) then
		case b.text of
		'NEW GAME':
			begin
				MouseButtonDown := phases.Phase.running;
			end;
		end;
	end;
end;

end.

