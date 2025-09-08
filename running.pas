unit running;

interface

uses
	SDL3,
	
	drawables,
	game,
	phases;

function Update(var state : game.State) : phases.Phase;
function Draw(renderer : PSDL_Renderer; spritesheet : PSDL_Texture; state : game.State) : DrawObjectList;

procedure KeyDown(var state : game.State; key : TSDL_Keycode);
procedure MouseButtonDown(var state : game.State; _ : Integer; x, y : Single);

implementation

uses
	color,
	dice,
	scoredgamepersistence,
	scoredgames;

function DrawCharacter(r : PSDL_Renderer; c : Character) : drawables.DrawObject;
begin
	DrawCharacter := drawables.NewFilledRect(c.x, c.y, drawables.NewColor(255, 0, 0), 10, 10);
end;

procedure DrawDie(renderer : PSDL_Renderer; spritesheet: PSDL_Texture;
	sprite : PSDL_FRect;
	x : Single; y : Single; r : Single;
	value : Byte);
var
	diePos : TSDL_FRect;
	dotPos : TSDL_FRect;
	dot    : TSDL_FRect;
begin
	diePos.x := x;
	diePos.y := y;
	diePos.w := dice.sprite.w;
	diePos.h := dice.sprite.h;

	if value > 0 then
	begin
		SDL_SetRenderDrawColor(renderer, 255, 255, 255, SDL_ALPHA_OPAQUE);
		SDL_RenderTextureRotated(
			renderer, spritesheet, sprite,
			@diePos, r,
			Nil, SDL_FLIP_NONE
		);

		for dot in dice.dotsPos[value] do
		begin
			with dotPos do
			begin
				x := diePos.x + dot.x - dot.w/2;
				y := diePos.y + dot.y - dot.w/2;
				w := dot.w;
				h := dot.h;
			end;

			SDL_RenderTexture(
				renderer, spritesheet,
				@dice.dotSprite, @dotPos
			);
		end;
	end;
end;

function DrawCosts(r : PSDL_Renderer; spritesheet: PSDL_Texture; payments : Array of game.Die; x : Integer; y : Integer) : DrawObjectList;
var
	menuPos : TSDL_FRect;
	diePos  : TSDL_FRect;

	i : Integer;
begin
	SetLength(DrawCosts, Length(payments));

	for i := Low(payments) to High(payments) do
	begin
		menuPos.x := x;
		menuPos.y := y + i * (dice.shadowSprite.h + 10);
		menuPos.w := 64;
		menuPos.h := dice.shadowSprite.h;

		DrawCosts[i] := drawables.NewFilledRect(
			Trunc(menuPos.x),
			Trunc(menuPos.y),
			drawables.NewColor(180, 180, 180),
			Trunc(menuPos.w),
			Trunc(menuPos.h)
		);

		with diePos do
		begin
			x := menuPos.x + menuPos.w + 10;
			y := menuPos.y;
			w := dice.shadowSprite.w;
			h := dice.shadowSprite.h;
		end;
	
		if payments[i].value > 0 then
		begin
			DrawDie(
				r, spritesheet, @dice.sprite,
				diePos.x, diePos.y, 0, payments[i].value);
		end
		else begin
			SDL_RenderTexture(
				r, spritesheet,
				@dice.shadowSprite, @diePos
			);
		end;

		diePos.x += dice.shadowSprite.w + 10;

		if payments[i].value > 0 then
		begin
			DrawDie(
				r, spritesheet, @dice.shadowSprite,
				diePos.x, diePos.y, 0, i + 1 - payments[i].value);
		end
		else begin
			SDL_RenderTexture(
				r, spritesheet,
				@dice.shadowSprite, @diePos
			);
		end;
	end;
end;

function Update(var state : game.State) : phases.Phase;
begin
	Update := phases.Phase.running;
end;

function Draw(renderer : PSDL_Renderer; spritesheet : PSDL_Texture; state : game.State) : drawables.DrawObjectList;
var
	die: game.Die;
begin
	SetLength(Draw, 0);

	for die in state.dice do
	begin
		DrawDie(renderer, spritesheet, @dice.sprite, die.x, die.y, die.r, die.value);
	end;
	Insert(DrawCharacter(renderer, state.c), Draw, Length(Draw));
	Insert(DrawCosts(renderer, spritesheet, state.payments, 10, 30), Draw, Length(Draw));
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

procedure MouseButtonDown(var state : game.State; _ : Integer; x, y : Single);
var
	dieIndex     : Integer;
	die          : game.Die;
	paymentIndex : Integer;
begin
	for dieIndex := Low(state.dice) to High(state.dice) do
	begin
		die := state.dice[dieIndex];

		if (x > die.x) and (x < die.x + 32)
			and (y > die.y) and (y < die.y + 32) then
		begin
			for paymentIndex := High(state.payments) downto Low(state.payments) do
			begin
				if state.payments[paymentIndex].value = 0 then
				begin
					state.dice[dieIndex] := state.payments[paymentIndex];
					state.payments[paymentIndex] := die;
					break;
				end;
			end;
		end;
	end;
end;

end.
