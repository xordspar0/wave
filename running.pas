unit running;

interface

uses
	SDL3,
	
	game,
	phases;

function Update(var state : game.State) : phases.Phase;
procedure Draw(renderer : PSDL_Renderer; spritesheet : PSDL_Texture; state : game.State);

procedure DrawDie(r : PSDL_Renderer; spritesheet: PSDL_Texture; die : game.Die);

procedure KeyDown(var state : game.State; key : TSDL_Keycode);

implementation

uses
	color,
	dice,
	scoredgamepersistence,
	scoredgames;

procedure DrawCharacter(r : PSDL_Renderer; c : Character);
var
	rect : TSDL_FRect;
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

procedure DrawDie(r : PSDL_Renderer; spritesheet: PSDL_Texture; die : game.Die);
var
	diePos : TSDL_FRect;
	dotPos : TSDL_FRect;
	dot    : TSDL_FRect;
begin
	with diePos do
	begin
		x := die.x;
		y := die.y;
		w := dice.sprite.w;
		h := dice.sprite.h;
	end;

	SDL_SetRenderDrawColor(r, 255, 255, 255, SDL_ALPHA_OPAQUE);
	SDL_RenderTextureRotated(
		r, spritesheet, @dice.sprite,
		@diePos, die.r,
		Nil, SDL_FLIP_NONE
	);

	for dot in dice.dotsPos[die.value] do
	begin
		with dotPos do
		begin
			x := die.x + dot.x - dot.w/2;
			y := die.y + dot.y - dot.w/2;
			w := dot.w;
			h := dot.h;
		end;

		SDL_RenderTexture(
			r, spritesheet,
			@dice.dotSprite, @dotPos
		);
	end;
end;

function Update(var state : game.State) : phases.Phase;
begin
	Update := phases.Phase.running;
end;

procedure Draw(renderer : PSDL_Renderer; spritesheet : PSDL_Texture; state : game.State);
var
	die: game.Die;
begin
	for die in state.dice do
	begin
		DrawDie(renderer, spritesheet, die);
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
