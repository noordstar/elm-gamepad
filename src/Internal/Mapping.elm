module Internal.Mapping exposing (..)

{-| Not every controller maps to the Gamepad API the same way.
To correctly map as many controllers as possible, this module aims to
rewire the buttons so that they may automatically work.
-}

import Dict exposing (Dict)
import Internal.Button as Button exposing (Button)
import Internal.Gamepad as Gamepad exposing (Gamepad)


type alias ButtonMap =
    -- The buttons on the right that usually indicate A, B, X, Y or other symbols.
    { north : Maybe Int
    , east : Maybe Int
    , south : Maybe Int
    , west : Maybe Int

    -- The buttons on the right that usually indicate A, B, X and Y.
    -- These buttons might not always be in the same configuration,
    -- and they might not always be these four letters.
    -- For this reason, the buttons are labeled as primary, secondary, tertiary and quaternary.
    , primary : Maybe Int
    , secondary : Maybe Int
    , tertiary : Maybe Int
    , quaternary : Maybe Int

    -- The buttons that are usually on the top left (SELECT) and the top right (START)
    , start : Maybe Int
    , select : Maybe Int

    -- Pressing joysticks usually count as buttons
    , leftJoystickButton : Maybe Int
    , rightJoystickButton : Maybe Int

    -- The arrows that are usually located on the left of the controller.
    -- Keep in mind that these are sometimes remapped as a joystick for controllers
    -- that do not have any joysticks.
    , arrowUp : Maybe Int
    , arrowLeft : Maybe Int
    , arrowRight : Maybe Int
    , arrowDown : Maybe Int

    -- Trigger and bumpers on the sides of the controller.
    -- The trigger is the small button on top, and the bumper is usually a larger
    -- button that is a bit lower on the controller.
    , leftTrigger : Maybe Int
    , leftBumper : Maybe Int
    , rightTrigger : Maybe Int
    , rightBumper : Maybe Int

    -- Home button. A lot of controllers can have a large button in the middle
    -- that allows them to turn on or off.
    , homeButton : Maybe Int
    , touchpad : Maybe Int
    }


buttonMapping : Dict String ButtonMap
buttonMapping =
    Dict.fromList
        [ ( "054c-05c4-Wireless Controller", standardController )
        , ( "Wireless Controller (STANDARD GAMEPAD Vendor: 054c Product: 05c4)", standardController )
        , ( "xinput"
          , { standardController
                | west = Just 2
                , east = Just 1
                , homeButton = Nothing
            }
          )
        , ( "Xbox 360 Controller (XInput STANDARD GAMEPAD)"
          , { standardController
                | west = Just 2
                , east = Just 1
                , homeButton = Nothing
            }
          )
        ]


getButtonMap : Gamepad -> ButtonMap
getButtonMap gamepad =
    Dict.get (Gamepad.id gamepad) buttonMapping
        |> Maybe.withDefault standardController


getButton : (ButtonMap -> Maybe Int) -> Gamepad -> Button
getButton f gamepad =
    case f <| getButtonMap gamepad of
        Just i ->
            Gamepad.getButton i gamepad

        Nothing ->
            Button.empty


standardController : ButtonMap
standardController =
    { south = Just 0
    , primary = Just 0
    , east = Just 1
    , secondary = Just 1
    , west = Just 2
    , tertiary = Just 2
    , north = Just 3
    , quaternary = Just 3
    , leftBumper = Just 4
    , rightBumper = Just 5
    , leftTrigger = Just 6
    , rightTrigger = Just 7
    , select = Just 8
    , start = Just 9
    , leftJoystickButton = Just 10
    , rightJoystickButton = Just 11
    , arrowUp = Just 12
    , arrowDown = Just 13
    , arrowLeft = Just 14
    , arrowRight = Just 15
    , homeButton = Just 16
    , touchpad = Just 17
    }


dummyController : ButtonMap
dummyController =
    { south = Just 0
    , primary = Just 0
    , west = Just 0
    , secondary = Just 0
    , east = Just 0
    , tertiary = Just 0
    , north = Just 0
    , quaternary = Just 0
    , leftTrigger = Just 0
    , rightTrigger = Just 0
    , leftBumper = Just 0
    , rightBumper = Just 0
    , select = Just 0
    , start = Just 0
    , leftJoystickButton = Just 0
    , rightJoystickButton = Just 0
    , arrowUp = Just 0
    , arrowLeft = Just 0
    , arrowRight = Just 0
    , arrowDown = Just 0
    , homeButton = Just 0
    , touchpad = Just 0
    }


north : Gamepad -> Button
north =
    getButton .north


east : Gamepad -> Button
east =
    getButton .east


south : Gamepad -> Button
south =
    getButton .south


west : Gamepad -> Button
west =
    getButton .west


primary : Gamepad -> Button
primary =
    getButton .primary


secondary : Gamepad -> Button
secondary =
    getButton .secondary


tertiary : Gamepad -> Button
tertiary =
    getButton .tertiary


quaternary : Gamepad -> Button
quaternary =
    getButton .quaternary


leftTrigger : Gamepad -> Button
leftTrigger =
    getButton .leftTrigger


rightTrigger : Gamepad -> Button
rightTrigger =
    getButton .rightTrigger


leftBumper : Gamepad -> Button
leftBumper =
    getButton .leftBumper


rightBumper : Gamepad -> Button
rightBumper =
    getButton .rightBumper


start : Gamepad -> Button
start =
    getButton .start


select : Gamepad -> Button
select =
    getButton .select


leftJoystickButton : Gamepad -> Button
leftJoystickButton =
    getButton .leftJoystickButton


rightJoystickButton : Gamepad -> Button
rightJoystickButton =
    getButton .rightJoystickButton


arrowUp : Gamepad -> Button
arrowUp =
    getButton .arrowUp


arrowDown : Gamepad -> Button
arrowDown =
    getButton .arrowDown


arrowLeft : Gamepad -> Button
arrowLeft =
    getButton .arrowLeft


arrowRight : Gamepad -> Button
arrowRight =
    getButton .arrowRight


homeButton : Gamepad -> Button
homeButton =
    getButton .homeButton


touchpad : Gamepad -> Button
touchpad =
    getButton .touchpad
