# elm-gamepad

Did you know that the browser supports **the use of game controllers?**

It's pretty simple, all you need to do is run

```js
navigator.getGamepads();
```

And you will get a JSON value that reports on all gamepads that are connected to your computer. [Try it with this live demo!](https://elm-gamepad.noordstar.me/)

## Port setup

You can use this information by passing it into a port:

**Elm side:**
```elm
port receiveGamepadState : (Json.Decode.Value -> msg) -> Sub msg
```

**JavaScript side:**
```js
app.ports.receiveGamepadState.send(navigator.getGamepads());
```

And then you're good to go. This library can decode the `Json.Decode.Value` for you and help you get the info you need.

## Usage

The `Gamepad` module helps you decode the `Json.Decode.Value`. Then, you can use `Gamepad.Button` and `Gamepad.Joystick` to decode the state of each button.

```elm
pressesHomeButton : Gamepad -> Bool
pressesHomeButton gamepad =
    gamepad
        |> Gamepad.Button.home
        |> Gamepad.Button.pressed
```
