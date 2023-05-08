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

## Tested

The following controllers have been tested and confirmed on the browsers Chrome, Firefox and MS Edge:

- PS4 controller
- 1 off-brand PS4 controller
- Xbox 360 controller **[since v1.0.1]**
- SNES controller **[since v1.0.1]**

All controllers should work on all versions, but some browsers might switch the A and B buttons, and this library fixes that for you. You can help contribute to this list
by testing other controller in the [live demo](https://elm-gamepad.noordstar.me/)!
