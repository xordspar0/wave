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
	scoredgames,
	sprites;

function DrawCharacter(c : Character) : drawables.DrawObject;
begin
	DrawCharacter := drawables.NewFilledRect(c.x, c.y, 10, 10, drawables.NewColor(255, 0, 0));
end;

function DrawDie(
	x, y  : Integer;
	r     : Double;
	value : Byte
) : DrawObjectList;
var
	dot : TSDL_FRect;
begin
	DrawDie := [];

	if value > 0 then
	begin
		SetLength(DrawDie, value+1);

		Insert(
			drawables.NewTexture(
				sprites.DieFace,
				x, y, r,
				drawables.Origin.Center,
				drawables.NewColor(255, 255, 255)
			),
			DrawDie,
			Length(DrawDie)
		);

		for dot in dice.dotsPos[value] do
		begin
			Insert(
				drawables.NewTexture(
					sprites.DieDot,
					Trunc(x + dot.x - dot.w/2),
					Trunc(y + dot.y - dot.w/2),
					0,
					drawables.Origin.Center,
					drawables.NewColor(255, 255, 255)
				),
				DrawDie,
				Length(DrawDie)
			);
		end;
	end;
end;

function shadow(die : drawables.DrawObjectList) : drawables.DrawObjectList;
var
	i : Integer;
begin
	for i := Low(die) to High(die) do
	begin
		if die[i].sprite = sprites.DieFace then
			die[i].sprite := sprites.DieFaceShadow;
	end;

	shadow := die;
end;

function DrawCosts(payments : Array of game.Die; x : Integer; y : Integer) : DrawObjectList;
const
	rowHeight  : Integer = 32;
	rowPadding : Integer = 10;
var
	i          : Integer;
	{ TODO: Remove dependency on SDL. }
	menuPos    : TSDL_FRect;
	diePos     : TSDL_FRect;
begin
	DrawCosts := [];

	for i := Low(payments) to High(payments) do
	begin
		menuPos.x := x;
		menuPos.y := y + i * (rowHeight + rowPadding);
		menuPos.w := 64;
		menuPos.h := rowHeight;

		Insert(
			drawables.NewFilledRect(
				Trunc(menuPos.x),
				Trunc(menuPos.y),
				Trunc(menuPos.w),
				Trunc(menuPos.h),
				drawables.NewColor(180, 180, 180)
			),
			DrawCosts,
			Length(DrawCosts)
		);

		with diePos do
		begin
			x := menuPos.x + menuPos.w + 10;
			y := menuPos.y;
		end;
	
		if payments[i].value > 0 then
		begin
			Insert(
				DrawDie(Trunc(diePos.x), Trunc(diePos.y), 0, payments[i].value),
				DrawCosts,
				Length(DrawCosts)
			);
		end
		else begin
			Insert(
				drawables.NewTexture(
					sprites.DieFaceShadow,
					Trunc(diePos.x), Trunc(diePos.y), 0,
					drawables.Origin.Center,
					drawables.NewColor(255, 255, 255)
				),
				DrawCosts,
				Length(DrawCosts)
			);
		end;

		{ TODO: 32 is a magic number that represents the width of a dice sprite. }
		{ Replace this with something smarter. }
		diePos.x += 32 + 10;

		if payments[i].value > 0 then
		begin
			Insert(
				shadow(DrawDie(Trunc(diePos.x), Trunc(diePos.y), 0, i + 1 - payments[i].value)),
				DrawCosts,
				Length(DrawCosts)
			);
		end
		else begin
			Insert(
				drawables.NewTexture(
					sprites.DieFaceShadow,
					Trunc(diePos.x), Trunc(diePos.y), 0,
					drawables.Origin.Center,
					drawables.NewColor(255, 255, 255)
				),
				DrawCosts,
				Length(DrawCosts)
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
	Draw := [];

	for die in state.dice do
	begin
		Insert(DrawDie(die.x, die.y, die.r, die.value), Draw, Length(Draw));
	end;

	Insert(DrawCharacter(state.c), Draw, Length(Draw));
	Insert(DrawCosts(state.payments, 10, 30), Draw, Length(Draw));
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
