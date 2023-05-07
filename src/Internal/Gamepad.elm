module Internal.Gamepad exposing (..)

{-| Internal module for the Gamepad type.
-}

import Internal.Button as Button exposing (Button)
import Internal.Joystick as Joystick exposing (Joystick)
import Json.Decode as D


{-| The Gamepad type represents a given type of game controller
that may be connected to the browser.
-}
type Gamepad
    = Gamepad
        { buttons : List Button
        , connected : Bool
        , gamepadId : String
        , joysticks : List Joystick
        }


{-| Empty Gamepad type. Mostly used for testing purposes.
-}
empty : Gamepad
empty =
    Gamepad
        { buttons = [], connected = True, gamepadId = "testing-gamepad", joysticks = [] }


{-| Get the gamepad's id.
-}
id : Gamepad -> String
id (Gamepad { gamepadId }) =
    gamepadId


{-| Get a list of buttons.

Mostly used for debugging of manual rewiring of controllers.

-}
buttons : Gamepad -> List Button
buttons (Gamepad data) =
    data.buttons


{-| Get all connected joysticks.
-}
joysticks : Gamepad -> List Joystick
joysticks (Gamepad data) =
    data.joysticks


{-| Get a joystick based on its index.
-}
getJoystick : Int -> Gamepad -> Joystick
getJoystick i (Gamepad data) =
    let
        getIndex : Int -> List Joystick -> Maybe Joystick
        getIndex j sticks =
            case sticks of
                [] ->
                    Nothing

                head :: tail ->
                    if i <= 0 then
                        Just head

                    else
                        getIndex (j - 1) tail
    in
    getIndex i data.joysticks |> Maybe.withDefault Joystick.empty


{-| Get a numbered button based on its index.
-}
getButton : Int -> Gamepad -> Button
getButton i (Gamepad data) =
    let
        getIndex : Int -> List Button -> Maybe Button
        getIndex j btns =
            case btns of
                [] ->
                    Nothing

                head :: tail ->
                    if i <= 0 then
                        Just head

                    else
                        getIndex (j - 1) tail
    in
    getIndex i data.buttons |> Maybe.withDefault Button.empty


{-| Whether the Gamepad is connected.
-}
connected : Gamepad -> Bool
connected (Gamepad data) =
    data.connected


{-| Decode a list of gamepads.
-}
decoder : D.Decoder (List Gamepad)
decoder =
    D.list gamepadDecoder


gamepadDecoder : D.Decoder Gamepad
gamepadDecoder =
    D.oneOf
        [ { buttons = [], connected = False, gamepadId = "", joysticks = [] }
            |> Gamepad
            |> D.null
        , D.field "connected" D.bool
            |> D.andThen
                (\conn ->
                    if not conn then
                        { buttons = [], connected = False, gamepadId = "", joysticks = [] }
                            |> Gamepad
                            |> D.succeed

                    else
                        D.map4
                            (\b c i j -> Gamepad { buttons = b, connected = c, gamepadId = i, joysticks = j })
                            (D.field "buttons" (D.list Button.buttonDecoder))
                            (D.field "connected" D.bool)
                            (D.field "id" D.string)
                            (D.list D.float
                                |> D.field "axes"
                                |> D.map Joystick.fromAxes
                            )
                )
        ]
