unit gametypes;

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

	GameState = record
		logger   : Logger;
		window   : PSDL_Window;
		renderer : PSDL_Renderer;
		c        : Character;
		gems     : Array [0..19] of Gem;
		loot     : Array [0..4] of Gem;
		lootNum  : Smallint;
	end;

	GamePhase = (running, score, quit);

implementation

end.
