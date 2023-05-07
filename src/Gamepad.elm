module Gamepad exposing
    ( Gamepad, decoder, connected
    , buttons, getButton, getJoystick
    )

{-| The Gamepad module exposes a type that lets you classify gamepads.


# Common gamepad

@docs Gamepad, decoder, connected


## Debugging values

This library aims to offer you all the functions you need.
If it somehow doesn't, however, you may use the following functions to find what you need.

@docs buttons, getButton, getJoystick

-}

import Internal.Button
import Internal.Gamepad as Internal
import Internal.Joystick
import Json.Decode


{-| The Gamepad type represents a player's game controller.
Every gamepad type is a separate device that is handled by a different player.
-}
type alias Gamepad =
    Internal.Gamepad


{-| This decoder directly takes a JSON value and decodes it into a list of gamepads.
-}
decoder : Json.Decode.Decoder (List Gamepad)
decoder =
    Internal.decoder


{-| Whether the gamepad is currently connected.
-}
connected : Gamepad -> Bool
connected =
    Internal.connected


{-| Gets all available buttons on the controller as one list of buttons.
-}
buttons : Gamepad -> List Internal.Button.Button
buttons =
    Internal.buttons


{-| Get a given button at a specific location in the array of buttons.

If the button doesn't exist, the function returns a fake button that is never pressed.

-}
getButton : Int -> Gamepad -> Internal.Button.Button
getButton =
    Internal.getButton


{-| Get a given joystick at a specific location in the array of joysticks.

If the joystick doesn't exist, the function returns a fake joystick that is never pressed.

-}
getJoystick : Int -> Gamepad -> Internal.Joystick.Joystick
getJoystick =
    Internal.getJoystick
