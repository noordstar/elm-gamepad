module Demo.Main exposing (main)

import Browser
import Browser.Events
import Demo.Colors as C
import Demo.Gamepad as DG
import Demo.Ports
import Element
import Gamepad exposing (Gamepad)
import Json.Decode
import Json.Encode


main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    List DG.Model


type Msg
    = GamepadUpdate Int DG.Msg
    | OnGamepadState Json.Encode.Value
    | Tick


init : () -> ( Model, Cmd Msg )
init _ =
    ( [], Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GamepadUpdate i subMsg ->
            let
                data : List ( DG.Model, Cmd DG.Msg )
                data =
                    model
                        |> List.indexedMap
                            (\j pad ->
                                if i /= j then
                                    ( pad, Cmd.none )

                                else
                                    DG.update subMsg pad
                            )
            in
            ( data
                |> List.map Tuple.first
            , data
                |> List.map Tuple.second
                |> List.indexedMap (\j -> Cmd.map (GamepadUpdate j))
                |> Cmd.batch
            )

        OnGamepadState state ->
            case Json.Decode.decodeValue Gamepad.decoder state of
                Ok pads ->
                    let
                        data : List ( DG.Model, Cmd DG.Msg )
                        data =
                            updateZip pads model
                    in
                    ( data
                        |> List.map Tuple.first
                    , data
                        |> List.map Tuple.second
                        |> List.indexedMap (\j -> Cmd.map (GamepadUpdate j))
                        |> Cmd.batch
                    )

                Err e ->
                    e
                        |> Json.Decode.errorToString
                        |> Debug.log "Failed to decode gamepads: "
                        |> always ( model, Cmd.none )

        Tick ->
            ( model, Demo.Ports.requestGamepadState () )


updateZip : List Gamepad -> List DG.Model -> List ( DG.Model, Cmd DG.Msg )
updateZip padState pads =
    case ( padState, pads ) of
        ( [], _ ) ->
            List.map (\p -> ( p, Cmd.none )) pads

        ( _, [] ) ->
            List.map DG.init padState

        ( state :: tailStates, pad :: tailPads ) ->
            DG.update (DG.UpdateGamepad state) pad :: updateZip tailStates tailPads



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Browser.Events.onAnimationFrame (always Tick)
        , Demo.Ports.receiveGamepadState OnGamepadState
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Gamepad test"
    , body =
        model
            |> List.indexedMap (\i -> DG.view >> Element.map (GamepadUpdate i))
            |> Element.column [ Element.centerX ]
            |> Element.layout [ C.background C.noordstarWhite ]
            |> List.singleton
    }
