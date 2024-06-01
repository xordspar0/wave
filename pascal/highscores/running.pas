unit running;

interface

uses
	gametypes;

function RunningUpdate(var game : GameState) : GamePhase;

implementation

uses
	sdl2,
	
	color;

function Grab(game : Gamestate) : Gamestate;
var
	i : Smallint;
begin
	for i := Low(game.gems) to High(game.gems) do
	with game.gems[i] do
	begin
		if visible and (x = game.c.x) and (y = game.c.y) then
		begin
			if game.lootNum <= High(game.loot) then
			begin
				game.loot[game.lootNum] := game.gems[i];
				game.lootNum := game.lootNum + 1;
				game.gems[i].visible := false;
			end;
		end;
	end;

	Grab := game;
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

function RunningUpdate(var game : GameState) : GamePhase;
var
	event : TSDL_Event;
begin
	RunningUpdate := GamePhase.running;

	while SDL_PollEvent(@event) = 1 do
	begin
		case event.type_ of
		SDL_QUITEV: RunningUpdate := quit;
		SDL_KEYDOWN:
			if event.key.repeat_ = 0 then
			case event.key.keysym.sym of
			SDLK_UP:		game.c.y -= 10;
			SDLK_DOWN:	game.c.y += 10;
			SDLK_LEFT:	game.c.x -= 10;
			SDLK_RIGHT: game.c.x += 10;
			end;
		end;
	end;

	game := Grab(game);

	if game.lootNum = 5 then
		RunningUpdate := score;

	SDL_SetRenderDrawColor(game.renderer, 0, 0, 0, 0);
	SDL_RenderClear(game.renderer);

	DrawGems(game.renderer, game.gems);
	DrawCharacter(game.renderer, game.c);

	SDL_RenderPresent(game.renderer);
end;

end.
