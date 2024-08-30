unit running;

interface

uses
	sdl2,
	
	game,
	phases,
	states;

function Update(var state : game.State) : phases.Phase;
procedure Draw(renderer : PSDL_Renderer; state : game.State);

implementation

uses
	color;

function Grab(state : game.State) : game.State;
var
	i : Smallint;
begin
	for i := Low(state.gems) to High(state.gems) do
	with state.gems[i] do
	begin
		if visible and (x = state.c.x) and (y = state.c.y) then
		begin
			if state.lootNum <= High(state.loot) then
			begin
				state.loot[state.lootNum] := state.gems[i];
				state.lootNum := state.lootNum + 1;
				state.gems[i].visible := false;
			end;
		end;
	end;

	Grab := state;
end;

procedure DrawCharacter(r : PSDL_Renderer; c : Character);
var
	rect : TSDL_Rect;
begin
	SDL_SetRenderDrawColor(r, 255, 0, 0, 0);

	with rect do
	begin
		x := c.x;
		y := c.y;
		w := 10;
		h := 10;
	end;

	SDL_RenderFillRect(r, @rect);
end;

procedure DrawGems(r : PSDL_Renderer; gems : Array of Gem);
var
	g	: Gem;
	rect : TSDL_Rect;
	color : RGB;
begin
	for g in gems do
	begin
		if g.visible then
		begin
			with rect do
			begin
				x := g.x + 1;
				y := g.y + 1;
				w := 8;
				h := 8;
			end;

			color := HueToRGB(g.hue);
			SDL_SetRenderDrawColor(r, color.r, color.g, color.b, 0);
			SDL_RenderFillRect(r, @rect);
		end;
	end;
end;

function Update(var state : game.State) : phases.Phase;
var
	event : TSDL_Event;
begin
	Update := phases.Phase.running;

	while SDL_PollEvent(@event) = 1 do
	begin
		case event.type_ of
		SDL_QUITEV: Update := quit;
		SDL_KEYDOWN:
			if event.key.repeat_ = 0 then
			case event.key.keysym.sym of
			SDLK_UP:		state.c.y -= 10;
			SDLK_DOWN:	state.c.y += 10;
			SDLK_LEFT:	state.c.x -= 10;
			SDLK_RIGHT: state.c.x += 10;
			end;
		end;
	end;

	state := Grab(state);

	if state.lootNum = 5 then
		Update := score;
end;

procedure Draw(renderer : PSDL_Renderer; state : game.State);
begin
	DrawGems(renderer, state.gems);
	DrawCharacter(renderer, state.c);
end;

end.
