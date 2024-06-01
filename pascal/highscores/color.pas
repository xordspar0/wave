unit color;

interface

type
  RGB = record
  	r, g, b : byte;
  end;

function HueToRGB(hue : byte) : RGB;

implementation

function HueToRGB(hue : byte) : RGB;
const
	primary : Byte = 255;
	oneSixth : Byte = 42;
var
	color : RGB;
	secondary : Byte;
begin
	secondary := Abs(primary - Abs((hue - oneSixth) mod (oneSixth * 2) * 6));
	case hue div oneSixth of
	0: begin
		color.r := primary;
		color.g := secondary;
		color.b := 0;
	end;
	1: begin
		color.r := secondary;
		color.g := primary;
		color.b := 0;
	end;
	2: begin
		color.r := 0;
		color.g := primary;
		color.b := secondary;
	end;
	3: begin
		color.r := 0;
		color.g := secondary;
		color.b := primary;
	end;
	4: begin
		color.r := secondary;
		color.g := 0;
		color.b := primary;
	end;
	5: begin
		color.r := primary;
		color.g := 0;
		color.b := secondary;
	end;
	end;

	HueToRGB := color;
end;

end.
