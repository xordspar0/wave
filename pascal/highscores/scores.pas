unit scores;

interface

uses
  sdl2,

  phases;

type State = record
  renderer : PSDL_Renderer;
  back     : Boolean;
end;

function New(renderer : PSDL_Renderer) : scores.State;
function Update(var state : scores.State) : phases.Phase;
procedure Draw(state : scores.State);

procedure KeyDown(var state : scores.State; key : TSDL_Keycode);

implementation

uses
  game,
  running;

function New(renderer : PSDL_Renderer) : scores.State;
begin
  New.renderer := renderer;
  New.back := False;
end;

function Update(var state : scores.State) : phases.Phase;
begin
  if state.back then
  begin
    Update := phases.Phase.mainmenu;
    state.back := False;
  end
  else
    Update := phases.Phase.scores;
end;

procedure Draw(state : scores.State);
var
  i   : Integer;
  gem : game.Gem;
begin
  gem.visible := True;
  gem.x := 50;

  for i := 1 to 5 do
  begin
    gem.y := 10 * i;
    gem.hue := 10 * i;

    running.DrawGem(state.renderer, gem);
  end;
end;

procedure KeyDown(var state : scores.State; key : TSDL_Keycode);
begin
	case key of
		SDLK_ESCAPE: state.back := True;
	end;
end;

end.
