unit text;

interface

uses
	SDL3;

type
	State = record
		fontSheet : PSDL_Texture;
	end;

function New(renderer : PSDL_Renderer) : text.State;
procedure RenderText(renderer : PSDL_Renderer; state : text.State; text : String);

implementation

uses
	SDL3_image;

const
	charWidth  : integer = 16;
	charHeight : integer = 32;

function New(renderer : PSDL_Renderer) : State;
begin
	New.fontSheet := IMG_LoadTexture(renderer, 'font.png');
end;

function GetCharCoords(c : Char) : TSDL_Rect;
var
	asciiVal : integer;
begin
	asciiVal := ord(c);

	with GetCharCoords do
	begin
		x := asciiVal mod 16 * charWidth;
		y := Trunc(asciiVal / 16) * charHeight;
		w := charWidth;
		h := charHeight;
	end;
end;

procedure RenderText(renderer : PSDL_Renderer; state : text.State; text : String);
var
	c     : Char;
	src   : TSDL_Rect;
	dest  : TSDL_Rect;
begin
	with dest do
	begin
		x := 0;
		y := 0;
		w := charWidth;
		h := charHeight;
	end;
	
	for c in text do
	begin
		src := GetCharCoords(c);

		SDL_RenderTexture(renderer, state.fontSheet, @src, @dest);
		dest.x += charWidth + 2;
	end;
end;

end.
