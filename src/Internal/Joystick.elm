module Internal.Joystick exposing (Joystick, abs, direction, directionRad, empty, fromAxes, toXY)

{-| A joystick is a little button that players can use for more precise directions.
-}


{-| The joystick type.
-}
type Joystick
    = Joystick { x : Float, y : Float }


{-| An empty joystick.
-}
empty : Joystick
empty =
    Joystick { x = 0, y = 0 }


{-| Map a list of axes into a list of joysticks
-}
fromAxes : List Float -> List Joystick
fromAxes axes =
    case axes of
        x :: y :: rest ->
            Joystick { x = x, y = y } :: fromAxes rest

        _ ->
            []


{-| On a scale from 0 to 1, return how intensely the button is being pushed.

Keep in mind that this is not always 0, especially for older devices who might have a tiny drift.

-}
abs : Joystick -> Float
abs (Joystick { x, y }) =
    max (Basics.abs x) (Basics.abs y)


{-| Starting from the top, get a direction in terms of degress,
starting at 0 from the top and going to 360 clockwise.
-}
direction : Joystick -> Int
direction (Joystick { x, y }) =
    atan2 y x
        |> (*) -180
        |> (/) pi
        |> round
        |> modBy 360


{-| Same as direction, except the value is now a number between 0 and 1.
-}
directionRad : Joystick -> Float
directionRad (Joystick { x, y }) =
    let
        tau : Float
        tau =
            2 * pi
    in
    atan2 y x
        |> (+) tau
        |> (/) (-2 * tau)


{-| Convert a joystick's direction to an x and y value.
The coordinates are defined as is starting from the top left, so:

  - Top means negative y
  - Left means negative x
  - Right means positive x
  - Bottom means positive y

-}
toXY : Joystick -> { x : Float, y : Float }
toXY (Joystick data) =
    data
