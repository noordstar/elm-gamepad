module Internal.Button exposing (Button, buttonDecoder, empty, pressed, touched, value)

{-| This module represents a (relatively) simple button.
-}

import Json.Decode as D


type Button
    = Button { isPressed : Bool, isTouched : Bool, buttonValue : Float }


buttonDecoder : D.Decoder Button
buttonDecoder =
    D.map3
        (\p t v -> Button { isPressed = p, isTouched = t, buttonValue = v })
        (D.field "pressed" D.bool)
        (D.field "touched" D.bool)
        (D.field "value" D.float)


{-| As a default value, buttons are non-pressed by default.
In case a button doesn't exist, this button can be shown.
-}
empty : Button
empty =
    Button { isPressed = False, isTouched = False, buttonValue = 0.0 }


{-| Most buttons are a simple press/don't press switch.
This value lets you know whether the button is being pressed.
-}
pressed : Button -> Bool
pressed (Button { isPressed }) =
    isPressed


{-| Some buttons notice if they're being touched by the user,
often through the use of a touchscreen. Effectively,
some buttons let you see whether the user touches the button without pressing it.

Keep in mind that most controllers also set this value to true when the button
is being pressed.

-}
touched : Button -> Bool
touched (Button { isTouched }) =
    isTouched


{-| Some buttons notice how firmly they're being pressed.

If the button supports this, this value shows how firmly, on a scale from 0 to 1.
If the button doesn't support this, the value will always be 0 (when not pressed) or 1 (when pressed).

-}
value : Button -> Float
value (Button { buttonValue }) =
    buttonValue
