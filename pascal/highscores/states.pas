unit states;

interface

uses
	sdl2,
	
	game,
	log,
	mainMenu,
	phases;

type 
	State = record
		logger   : log.Logger;
		window   : PSDL_Window;
		renderer : PSDL_Renderer;
		phase    : phases.Phase;
		game     : game.State;
		menu     : mainMenu.State;
	end;

implementation

end.
