port module Demo.Ports exposing (..)

{-| The port module defines all commands that can be sent.
-}

import Json.Decode
import Matrix.Webhooks as W


{-| This function is used to request the latest gamepad state.
-}
port requestGamepadState : () -> Cmd msg


{-| This subscription is used to receive the latest gamepad state.
-}
port receiveGamepadState : (Json.Decode.Value -> msg) -> Sub msg


{-| Send a request to the webhook to inform us about the gamepad's state.
-}
sendToWebhook : { text : String, toMsg : Result W.Error () -> msg } -> Cmd msg
sendToWebhook { text, toMsg } =
    W.sendMessage
        toMsg
        (W.toWebhook
            "https://relay.noordstar.me"
            "7zWZ6z7PzGMMypgXXhwRP"
            "!lksTkPXzmEHvXwxwCk:noordstar.me"
        )
        text
