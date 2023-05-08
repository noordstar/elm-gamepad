module Demo.Gamepad exposing (..)

{-| This module represents the card that helps test a gamepad.
-}

import Demo.Colors as C
import Demo.Ports
import Element exposing (Element)
import Element.Border
import Element.Font
import Gamepad exposing (Gamepad)
import Internal.Gamepad exposing (id)
import Internal.Mapping as Mapping exposing (ButtonMap)
import Matrix.Webhooks
import Widget
import Widget.Material as Material



-- MODEL


type alias Model =
    { gamepad : Gamepad, state : TestingState }


type TestingState
    = NewGamepad
    | Testing
        { presses : List (Maybe Int)
        , lastPush : Maybe Int
        }
    | SendingData ButtonMap
    | Done


type Msg
    = Finish
    | OnWebhook (Result Matrix.Webhooks.Error ())
    | ResetTest
    | SendButtonMap ButtonMap
    | SkipButton
    | UpdateGamepad Gamepad


init : Gamepad -> ( Model, Cmd Msg )
init g =
    ( { gamepad = g, state = NewGamepad }, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateGamepad g ->
            case model.state of
                Testing data ->
                    let
                        btn : Maybe Int
                        btn =
                            buttonPressed g
                    in
                    ( { gamepad = g
                      , state =
                            Testing
                                { data
                                    | lastPush = btn
                                    , presses =
                                        case ( data.lastPush, btn ) of
                                            ( Nothing, Just _ ) ->
                                                List.append data.presses [ btn ]

                                            ( Just old, Just new ) ->
                                                if old == new then
                                                    data.presses

                                                else
                                                    List.append data.presses [ btn ]

                                            _ ->
                                                data.presses
                                }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model | gamepad = g }, Cmd.none )

        ResetTest ->
            ( { model
                | state =
                    Testing
                        { lastPush = buttonPressed model.gamepad, presses = [] }
              }
            , Cmd.none
            )

        SkipButton ->
            case model.state of
                Testing data ->
                    ( { model
                        | state =
                            Testing { data | presses = List.append data.presses [ Nothing ] }
                      }
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none )

        SendButtonMap map ->
            ( { model | state = SendingData map }, sendButtonMap model.gamepad map )

        Finish ->
            ( { model | state = Done }, Cmd.none )

        OnWebhook (Ok ()) ->
            ( { model | state = Done }, Cmd.none )

        OnWebhook (Err e) ->
            case e of
                Matrix.Webhooks.NotJoinedToRoom ->
                    ( { model | state = Done }, Cmd.none )

                Matrix.Webhooks.Unauthorized ->
                    ( { model | state = Done }, Cmd.none )

                Matrix.Webhooks.WebhookMissingInput ->
                    ( { model | state = Done }, Cmd.none )

                Matrix.Webhooks.WebhookReturnedInvalidJSON ->
                    ( { model | state = Done }, Cmd.none )

                Matrix.Webhooks.BadUrl _ ->
                    ( { model | state = Done }, Cmd.none )

                _ ->
                    ( model
                    , case model.state of
                        SendingData map ->
                            sendButtonMap model.gamepad map

                        _ ->
                            Cmd.none
                    )


{-| Return a button if it's the only one being pressed.
Otherwise, return Nothing.
-}
buttonPressed : Gamepad -> Maybe Int
buttonPressed =
    Gamepad.buttons
        >> List.indexedMap Tuple.pair
        >> List.filterMap
            (\( i, btn ) ->
                if Gamepad.pressed btn then
                    Just i

                else
                    Nothing
            )
        >> (\l ->
                case l of
                    [ head ] ->
                        Just head

                    _ ->
                        Nothing
           )


sendButtonMap : Gamepad -> ButtonMap -> Cmd Msg
sendButtonMap gamepad map =
    Demo.Ports.sendToWebhook
        { text =
            "# elm-gamepad\n"
                ++ "A user has tested their gamepad and sent you their results!\n"
                ++ "\n"
                ++ "<pre><code class=\"language-elm\">\n"
                ++ "        , ( \""
                ++ Internal.Gamepad.id gamepad
                ++ "\""
                ++ ([ ( "south", .south )
                    , ( "primary", .primary )
                    , ( "west", .west )
                    , ( "secondary", .secondary )
                    , ( "east", .east )
                    , ( "tertiary", .tertiary )
                    , ( "north", .north )
                    , ( "quaternary", .quaternary )
                    , ( "leftBumper", .leftBumper )
                    , ( "rightBumper", .rightBumper )
                    , ( "leftTrigger", .leftTrigger )
                    , ( "rightTrigger", .rightTrigger )
                    , ( "select", .select )
                    , ( "start", .start )
                    , ( "leftJoystickButton", .leftJoystickButton )
                    , ( "rightJoystickButton", .rightJoystickButton )
                    , ( "arrowUp", .arrowUp )
                    , ( "arrowLeft", .arrowLeft )
                    , ( "arrowRight", .arrowRight )
                    , ( "homeButton", .homeButton )
                    , ( "touchpad", .touchpad )
                    ]
                        |> List.filterMap (judgeMapping map)
                        |> (\items ->
                                case items of
                                    [] ->
                                        ", standardController )\n"

                                    _ ->
                                        "\n          , { standardController\n            | "
                                            ++ String.join "\n            , " items
                                            ++ "\n            }\n          )"
                           )
                   )
                ++ "</code></pre>\n"
                ++ "\n"
                ++ "I hope this will be helpful to you!"
        , toMsg = OnWebhook
        }


judgeMapping : ButtonMap -> ( String, ButtonMap -> Maybe Int ) -> Maybe String
judgeMapping map ( field, toValue ) =
    if toValue map /= toValue Mapping.standardController then
        Just (field ++ " = " ++ toString toValue map)

    else
        Nothing


toString : (ButtonMap -> Maybe Int) -> ButtonMap -> String
toString toVal map =
    case toVal map of
        Just i ->
            "Just " ++ String.fromInt i

        Nothing ->
            "Nothing"



-- VIEW


view : Model -> Element Msg
view model =
    (case model.state of
        NewGamepad ->
            [ Element.paragraph [] [ Element.text "New gamepad detected!" ]
            , Element.paragraph [] [ Element.text "Press the button below to start!" ]
            , { text = "START", onPress = Just ResetTest }
                |> Widget.textButton (Material.outlinedButton C.primaryPalette)
                |> Element.el [ Element.centerX ]
            ]
                |> Element.column []
                |> gamepadBox model.gamepad

        Testing { presses } ->
            [ case testingView presses of
                PressButton { paragraph, nintendo, playstation, xbox } ->
                    Element.column [ Element.width Element.fill, Element.spacing 20 ]
                        [ Element.paragraph [] paragraph
                        , Element.text "Usually, that's the following button:"
                        , Element.table [ Element.Border.width 1 ]
                            { data = [ { nintendo = nintendo, playstation = playstation, xbox = xbox } ]
                            , columns =
                                [ { header = Element.el [ Element.Border.width 1 ] (Element.text "Nintendo")
                                  , width = Element.fill
                                  , view = \data -> Element.el [ Element.Border.width 1 ] (Element.text data.nintendo)
                                  }
                                , { header = Element.el [ Element.Border.width 1 ] (Element.text "PlayStation")
                                  , width = Element.fill
                                  , view = \data -> Element.el [ Element.Border.width 1 ] (Element.text data.playstation)
                                  }
                                , { header = Element.el [ Element.Border.width 1 ] (Element.text "Xbox")
                                  , width = Element.fill
                                  , view = \data -> Element.el [ Element.Border.width 1 ] (Element.text data.xbox)
                                  }
                                ]
                            }
                        , Element.row
                            [ Element.width Element.fill, Element.spaceEvenly ]
                            [ Widget.textButton (Material.containedButton C.secondaryPalette)
                                { text = "Button doesn't exist", onPress = Just SkipButton }
                            , Widget.textButton (Material.outlinedButton C.secondaryPalette)
                                { text = "Reset", onPress = Just ResetTest }
                            ]
                        ]

                ConfirmPrompt map ->
                    Element.column [ Element.width Element.fill, Element.spacing 20 ]
                        [ Element.paragraph []
                            [ Element.el [ Element.Font.bold ] (Element.text "You finished the test! ")
                            , Element.text "Would you mind sending your test to the developer of this library? "
                            , Element.text "Not every controller works the same, "
                            , Element.text "and this helps make sure all buttons are mapped correctly in the library. "
                            , Element.text "The test only includes your game controller type and your button configuration, nothing else. "
                            ]
                        , Element.row [ Element.width Element.fill, Element.spaceEvenly ]
                            [ Widget.textButton (Material.outlinedButton C.secondaryPalette)
                                { text = "YES", onPress = Just (SendButtonMap map) }
                            , Widget.textButton (Material.outlinedButton C.secondaryPalette)
                                { text = "NO", onPress = Just Finish }
                            ]
                        ]
            ]
                |> Element.column [ Element.width Element.fill, Element.spacing 20 ]
                |> gamepadBox model.gamepad

        SendingData _ ->
            [ Element.text "Sending config..."
            , Widget.circularProgressIndicator
                (Material.progressIndicator C.secondaryPalette)
                Nothing
            ]
                |> Element.row [ Element.centerX, Element.width Element.fill ]
                |> gamepadBox model.gamepad

        Done ->
            "You're all set! Thanks for testing your gamepad. :)"
                |> Element.text
                |> List.singleton
                |> Element.column []
                |> gamepadBox model.gamepad
    )
        |> Element.el [ Element.width Element.fill, Element.spacing 20 ]
        |> Element.el
            (Material.cardAttributes Material.defaultPalette)
        |> Element.el
            [ Element.width <| Element.maximum 750 <| Element.fill ]


gamepadBox : Gamepad -> Element msg -> Element msg
gamepadBox g content =
    [ g
        |> id
        |> (++) "Controller "
        |> Element.text
        |> Element.el
            [ Element.Font.bold
            , Element.centerX
            ]
    , content
    ]
        |> Element.column [ Element.width Element.fill, Element.spacing 10 ]


type TestingView msg
    = PressButton
        { paragraph : List (Element msg)
        , nintendo : String
        , playstation : String
        , xbox : String
        }
    | ConfirmPrompt ButtonMap


testingView : List (Maybe Int) -> TestingView Msg
testingView buttons =
    case buttons of
        [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "SOUTH ")
                    , Element.text "button. "
                    ]
                , xbox = "A button"
                , nintendo = "B button"
                , playstation = "X button"
                }

        _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "EAST ")
                    , Element.text "button. "
                    ]
                , xbox = "B button"
                , nintendo = "A button"
                , playstation = "Circle button"
                }

        _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "WEST ")
                    , Element.text "button. "
                    ]
                , xbox = "X button"
                , nintendo = "Y button"
                , playstation = "Square button"
                }

        _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "NORTH ")
                    , Element.text "button. "
                    ]
                , xbox = "Y button"
                , nintendo = "X button"
                , playstation = "Triangle button"
                }

        _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "PRIMARY ")
                    , Element.text "button. "
                    ]
                , xbox = "A button"
                , nintendo = "A button"
                , playstation = "X button"
                }

        _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "SECONDARY ")
                    , Element.text "button. "
                    ]
                , xbox = "B button"
                , nintendo = "B button"
                , playstation = "Circle button"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "TERTIARY ")
                    , Element.text "button. "
                    ]
                , xbox = "X button"
                , nintendo = "X button"
                , playstation = "Square button"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "QUATERNARY ")
                    , Element.text "button. "
                    ]
                , xbox = "Y button"
                , nintendo = "Y button"
                , playstation = "Triangle button"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "START ")
                    , Element.text "button. "
                    ]
                , xbox = "Start"
                , nintendo = "START"
                , playstation = "Options"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "SELECT ")
                    , Element.text "button. "
                    ]
                , xbox = "Back"
                , nintendo = "SELECT"
                , playstation = "Share"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "Left bumper ")
                    , Element.text "button. "
                    , Element.text "This should be the (smaller) button on the front of the controller. "
                    ]
                , xbox = "LT"
                , nintendo = "L"
                , playstation = "L1"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "Right bumper ")
                    , Element.text "button. "
                    , Element.text "This should be the (smaller) button on the front of the controller. "
                    ]
                , xbox = "RT"
                , nintendo = "R"
                , playstation = "R1"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "Left trigger ")
                    , Element.text "button. "
                    , Element.text "This should be the larger button on the front of the controller. "
                    ]
                , xbox = "LB"
                , nintendo = "ZL"
                , playstation = "L2"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "Right trigger ")
                    , Element.text "button. "
                    , Element.text "This should be the larger button on the front of the controller. "
                    ]
                , xbox = "RB"
                , nintendo = "ZR"
                , playstation = "R2"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "Up arrow ")
                    , Element.text "button. "
                    , Element.text "If the button doesn't work, "
                    , Element.text "it might be that your controller picks it up as a joystick. "
                    , Element.text "In that case, skip this button. "
                    ]
                , xbox = "Up"
                , nintendo = "Up"
                , playstation = "Up"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "Left arrow ")
                    , Element.text "button. "
                    , Element.text "If the button doesn't work, "
                    , Element.text "it might be that your controller picks it up as a joystick. "
                    , Element.text "In that case, skip this button. "
                    ]
                , xbox = "Left"
                , nintendo = "Left"
                , playstation = "Left"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "Right arrow ")
                    , Element.text "button. "
                    , Element.text "If the button doesn't work, "
                    , Element.text "it might be that your controller picks it up as a joystick. "
                    , Element.text "In that case, skip this button. "
                    ]
                , xbox = "Right"
                , nintendo = "Right"
                , playstation = "Right"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Please press the "
                    , Element.el [ Element.Font.bold ] (Element.text "Down arrow ")
                    , Element.text "button. "
                    , Element.text "If the button doesn't work, "
                    , Element.text "it might be that your controller picks it up as a joystick. "
                    , Element.text "In that case, skip this button. "
                    ]
                , xbox = "Down"
                , nintendo = "Down"
                , playstation = "Down"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Some controllers allow you to press on the middle of a joystick. "
                    , Element.text "If you do so, you'll hear a soft clicking sound. "
                    , Element.text "Please press on your "
                    , Element.el [ Element.Font.bold ] (Element.text "Left joystick ")
                    , Element.text "button. "
                    ]
                , xbox = "LJ"
                , nintendo = "JL"
                , playstation = "L3"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Some controllers allow you to press on the middle of a joystick. "
                    , Element.text "If you do so, you'll hear a soft clicking sound. "
                    , Element.text "Please press on your "
                    , Element.el [ Element.Font.bold ] (Element.text "Right joystick ")
                    , Element.text "button. "
                    ]
                , xbox = "RJ"
                , nintendo = "JR"
                , playstation = "R3"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Some controllers have a home button in the middle "
                    , Element.text "of the controller to turn it on or off. "
                    , Element.text "If it does, please press this "
                    , Element.el [ Element.Font.bold ] (Element.text "Home ")
                    , Element.text "button. "
                    ]
                , xbox = "Xbox logo"
                , nintendo = "House logo"
                , playstation = "PlayStation logo"
                }

        _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: _ :: [] ->
            PressButton
                { paragraph =
                    [ Element.text "Some controllers have a touch pad "
                    , Element.text "in the middle of the controller "
                    , Element.text "to allow for mouse movements."
                    , Element.text "If it does, please press this "
                    , Element.el [ Element.Font.bold ] (Element.text "Touchpad ")
                    , Element.text "button. "
                    ]
                , xbox = "Touchpad"
                , nintendo = "Touchpad"
                , playstation = "Touchpad"
                }

        south :: east :: west :: north :: primary :: secondary :: tertiary :: quaternary :: start :: select :: leftBumper :: rightBumper :: leftTrigger :: rightTrigger :: up :: left :: right :: down :: leftJoystick :: rightJoystick :: home :: touchpad :: _ ->
            ConfirmPrompt
                { south = south
                , east = east
                , west = west
                , north = north
                , primary = primary
                , secondary = secondary
                , tertiary = tertiary
                , quaternary = quaternary
                , start = start
                , select = select
                , leftBumper = leftBumper
                , rightBumper = rightBumper
                , leftTrigger = leftTrigger
                , rightTrigger = rightTrigger
                , arrowUp = up
                , arrowLeft = left
                , arrowRight = right
                , arrowDown = down
                , leftJoystickButton = leftJoystick
                , rightJoystickButton = rightJoystick
                , homeButton = home
                , touchpad = touchpad
                }
