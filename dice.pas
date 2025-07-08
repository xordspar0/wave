unit dice;

interface

uses
  SDL3;

const
  sprite : TSDL_FRect = (
    x: 0; y: 0;
    w: 32; h: 32;
  );

  shadowSprite : TSDL_FRect = (
    x: 32; y: 0;
    w: 32; h: 32;
  );

  dotSprite : TSDL_FRect = (
    x: 64; y: 0;
    w: 6; h: 6;
  );

  dotsPos : array[1..6] of array of TSDL_FRect = (
    (
  		(x: 16; y: 16; w: 6; h: 6)
    ),
    (
  		(x:  7; y: 25; w: 6; h: 6),
  		(x: 25; y:  7; w: 6; h: 6)
    ),
    (
  		(x:  7; y: 25; w: 6; h: 6),
  		(x: 16; y: 16; w: 6; h: 6),
  		(x: 25; y:  7; w: 6; h: 6)
    ),
    (
  		(x:  7; y:  7; w: 6; h: 6),
  		(x: 25; y:  7; w: 6; h: 6),
  		(x:  7; y: 25; w: 6; h: 6),
  		(x: 25; y: 25; w: 6; h: 6)
    ),
    (
  		(x:  7; y:  7; w: 6; h: 6),
  		(x: 25; y:  7; w: 6; h: 6),
  		(x:  7; y: 25; w: 6; h: 6),
  		(x: 25; y: 25; w: 6; h: 6),
  		(x: 16; y: 16; w: 6; h: 6)
    ),
    (
  		(x:  7; y:  7; w: 6; h: 6),
  		(x: 25; y:  7; w: 6; h: 6),
  		(x:  7; y: 16; w: 6; h: 6),
  		(x: 25; y: 16; w: 6; h: 6),
  		(x:  7; y: 25; w: 6; h: 6),
  		(x: 25; y: 25; w: 6; h: 6)
    )
  );

implementation

end.
