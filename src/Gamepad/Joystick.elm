module Gamepad.Joystick exposing
    ( Joystick
    , abs, direction, directionRad, toXY
    )

{-| This module is about showing joysticks.

@docs Joystick

The joystick's value can be read in multiple ways that might suit your needs.

@docs abs, direction, directionRad, toXY

-}

import Internal.Joystick


{-| A joystick is a representation of a stick that can move in all directions.
-}
type alias Joystick =
    Internal.Joystick.JoyStick


{-| On a scale from 0 to 1, return how intensely the button is being pushed.

Keep in mind that this is not always 0, especially for older devices who might have a tiny drift.

-}
abs : Joystick -> Float
abs =
    Internal.Joystick.abs


{-| Starting from the top, get a direction in terms of degress,
starting at 0 from the top and going to 360 clockwise.
-}
direction : Joystick -> Int
direction =
    Internal.Joystick.direction


{-| Same as direction, except the value is now a number between 0 and 1.
-}
directionRad : Joystick -> Float
directionRad =
    Internal.Joystick.directionRad


{-| Convert a joystick's direction to an x and y value.
The coordinates are defined as is starting from the top left, so:

  - Top means negative y
  - Left means negative x
  - Right means positive x
  - Bottom means positive y

Both values go from -1 to 1, so (-1, -1) and (1, 1) are the top left and bottom right respectively.

-}
toXY : Joystick -> { x : Float, y : Float }
toXY =
    Internal.Joystick.toXY
