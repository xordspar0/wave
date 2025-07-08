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
procedure MouseButtonDown(var state : game.State; _ : Integer; x, y : Single);

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

	if die.value > 0 then
	begin
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
end;

procedure DrawCosts(r : PSDL_Renderer; spritesheet: PSDL_Texture; payments : Array of game.Die; x : Integer; y : Integer);
var
	menuPos : TSDL_FRect;
	fishPos : TSDL_FRect;
	diePos  : TSDL_FRect;
	dotPos  : TSDL_FRect;
	dot     : TSDL_FRect;

	i : Integer;
begin
	for i := Low(payments) to High(payments) do
	begin
		menuPos.x := x;
		menuPos.y := y + i * (dice.shadowSprite.h + 10);
		menuPos.w := 64;
		menuPos.h := dice.shadowSprite.h;

		SDL_SetRenderDrawColor(r, 180, 180, 180, SDL_ALPHA_OPAQUE);
		SDL_RenderFillRect(r, @menuPos);

		SDL_SetRenderDrawColor(r, 255, 255, 255, SDL_ALPHA_OPAQUE);

		with diePos do
		begin
			x := menuPos.x + menuPos.w + 10;
			y := menuPos.y;
			w := dice.shadowSprite.w;
			h := dice.shadowSprite.h;
		end;
	
		if payments[i].value > 0 then
		begin
			SDL_RenderTexture(
				r, spritesheet,
				@dice.sprite, @diePos
			);

			for dot in dice.dotsPos[payments[i].value] do
			begin
				with dotPos do
				begin
					x := diePos.x + dot.x - dot.w/2;
					y := diePos.y + dot.y - dot.w/2;
					w := dot.w;
					h := dot.h;
				end;

				SDL_RenderTexture(
					r, spritesheet,
					@dice.dotSprite, @dotPos
				);
			end;
		end
		else begin
			SDL_RenderTexture(
				r, spritesheet,
				@dice.shadowSprite, @diePos
			);
		end;

		diePos.x += dice.shadowSprite.w + 10;

		SDL_RenderTexture(
			r, spritesheet,
			@dice.shadowSprite, @diePos
		);

		if payments[i].value > 0 then
		begin
			for dot in dice.dotsPos[i + 1 - payments[i].value] do
			begin
				with dotPos do
				begin
					x := diePos.x + dot.x - dot.w/2;
					y := diePos.y + dot.y - dot.w/2;
					w := dot.w;
					h := dot.h;
				end;

				SDL_RenderTexture(
					r, spritesheet,
					@dice.dotSprite, @dotPos
				);
			end;
		end;
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
	DrawCosts(renderer, spritesheet, state.payments, 10, 30);
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

		Writeln(x, y);

		if (x > die.x) and (x < die.x + 32)
			and (y > die.y) and (y < die.y + 32) then
		begin
			Writeln('match');
			for paymentIndex := High(state.payments) downto Low(state.payments) do
			begin
				Writeln('Value of ', paymentIndex, ': ', state.payments[paymentIndex].value);
				if state.payments[paymentIndex].value = 0 then
				begin
					state.dice[dieIndex] := state.payments[paymentIndex];
					state.payments[paymentIndex] := die;
					Writeln('set ', paymentIndex, ' to ', die.value);

					break;
				end;
			end;
		end;
	end;
end;

end.
