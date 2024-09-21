unit running;

interface

uses
	sdl2,
	
	game,
	phases;

function Update(var state : game.State) : phases.Phase;
procedure Draw(renderer : PSDL_Renderer; state : game.State);

procedure DrawGem(r : PSDL_Renderer; gem : game.Gem);

procedure KeyDown(var state : game.State; key : TSDL_Keycode);

implementation

uses
	color,
	scoredgamepersistence,
	scoredgames;

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

procedure DrawGem(r : PSDL_Renderer; gem : game.Gem);
var
	rect : TSDL_Rect;
	color : RGB;
begin
	if gem.visible then
	begin
		with rect do
		begin
			x := gem.x + 1;
			y := gem.y + 1;
			w := 8;
			h := 8;
		end;

		color := HueToRGB(gem.hue);
		SDL_SetRenderDrawColor(r, color.r, color.g, color.b, 0);
		SDL_RenderFillRect(r, @rect);
	end;
end;

function Update(var state : game.State) : phases.Phase;
var
	score : scoredgames.ScoredGame;
begin
	Update := phases.Phase.running;

	state := Grab(state);

	if state.lootNum = 5 then
	begin
		score := game.ScoreGame(state);
		scoredgamepersistence.InsertScoredGame(score);

		Update := phases.Phase.quit;
	end;
end;

procedure Draw(renderer : PSDL_Renderer; state : game.State);
var
	gem: game.Gem;
begin
	for gem in state.gems do
	begin
		DrawGem(renderer, gem);
	end;
	DrawCharacter(renderer, state.c);
end;

procedure KeyDown(var state : game.State; key : TSDL_Keycode);
begin
	case key of
		SDLK_UP:		state.c.y -= 10;
		SDLK_DOWN:	state.c.y += 10;
		SDLK_LEFT:	state.c.x -= 10;
		SDLK_RIGHT: state.c.x += 10;
	end;
end;

end.
