unit states;

interface

uses
	sdl2,
	
	game,
	log,
	mainMenu,
	phases,
	scores;

type 
	State = record
		logger   : log.Logger;
		window   : PSDL_Window;
		renderer : PSDL_Renderer;
		phase    : phases.Phase;
		game     : game.State;
		menu     : mainMenu.State;
		scores   : scores.State;
	end;

implementation

end.
