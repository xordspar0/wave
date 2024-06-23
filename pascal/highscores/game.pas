unit game;

interface

uses
	sdl2,

	log;

type
	Character = record
		x,y : Smallint;
	end;

	Gem = record
		x,y     : Smallint;
		hue     : Byte;
		visible : Boolean;
	end;

	State = record
		logger   : Logger;
		window   : PSDL_Window;
		renderer : PSDL_Renderer;
		c        : Character;
		gems     : Array [0..19] of Gem;
		loot     : Array [0..4] of Gem;
		lootNum  : Smallint;
	end;

	Phase = (mainmenu, running, score, quit);

function New() : State;

implementation

function New() : State;
var
	i : Smallint;
	g : State;
begin
	g.c.x := 0;
	g.c.y := 0;

	for i := Low(g.gems) to High(g.gems) div 2 do
	with g.gems[i] do
	begin
		x := i * 10 + 20;
		y := 30;
		hue := i * 25;
		visible := true;
	end;
	for i := High(g.gems) div 2 + 1 to High(g.gems) do
	with g.gems[i] do
	begin
		x := (i - (High(g.gems) div 2 + 1)) * 10 + 20;
		y := 40;
		hue := Random(256);
		visible := true;
	end;

	g.lootNum := 0;

	New := g;
end;

end.
