unit mainmenu;

interface

uses
	sdl2,
	
	game;

type
	State = record
		renderer : PSDL_Renderer;
		selected : Smallint;
	end;

function Update(var state : mainmenu.State) : game.Phase;
procedure Draw(state : mainmenu.State);

implementation

uses
	color;

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
	labels : array[1..2] of string = ('New Game', 'High Scores');
var
	i     : smallint;
	rect  : TSDL_Rect;
begin

	for i := Low(labels) to High(labels) do
	begin
		with rect do
		begin
			x := 20;
			y := i * 25;
			w := 100;
			h := 20;
		end;

		SDL_SetRenderDrawColor(state.renderer, 150, 150, 150, 0);
		SDL_RenderFillRect(state.renderer, @rect);
	end;
end;

end.

