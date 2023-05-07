module Gamepad.Button exposing
    ( Button, pressed, touched, value
    , primary, secondary, tertiary, quaternary
    , up, left, right, down
    , leftBumper, rightBumper, leftTrigger, rightTrigger
    , leftStick, rightStick
    , start, select, home, touchpad
    , north, east, south, west
    )

{-| This module represents buttons on a game controller.


# Button type

@docs Button, pressed, touched, value


# Button index

This library looks at what your controller looks like, and indexes each button for you.
This way, you can simply check if any button is being pressed.


## A, B, X, Y buttons

Different controllers use different letters (A, B, X, Y or X, O, square and triangle) in different configurations

  - which can get very confusing! That's why this library doesn't bother with the exact letters,
    and simply labels them as **primary**, **secondary**, **tertiary** and **quaternary**.
    The library will automatically link them to the relevant buttons for each controller.

@docs primary, secondary, tertiary, quaternary


## Directional buttons

Most controllers have a bunch of directional buttons that can be used for a directional menu.
Usually, these are used for things like quick slots from a player's inventory.

@docs up, left, right, down


## Buttons on the front

Whether you call it the top or the front of the controllers,
there's always a few buttons up there.

@docs leftBumper, rightBumper, leftTrigger, rightTrigger


## Joystick buttons

Some joystick buttons allow you to press on them. As a result, you will hear a soft clicking noise.
These buttons are usually used for actions that should be executed very rarely,
like switching camera perspective, as not all controllers have these buttons.

@docs leftStick, rightStick


## Menu buttons

The menu buttons are usually used to pause games, open in-game (or out-of-game) menus,
and change settings.

@docs start, select, home, touchpad


## A,B,X,Y in order

In some rare cases, you do not care about the actual buttons and you just want them in their directions.
In that case, you can access the right button by their orientation.
Note that these buttons will likely overlap with the [`primary`](Gamepad.Button#primary), [`secondary`](Gamepad.Button#secondary), [`tertiary`](Gamepad.Button#tertiary) and [`quaternary`](Gamepad.Button#quaternary) buttons.

@docs north, east, south, west

-}

import Internal.Button
import Internal.Gamepad exposing (Gamepad)
import Internal.Mapping


{-| The most common type on any controller. Most buttons can only be pressed and released,
but some are a little bit more advanced.
-}
type alias Button =
    Internal.Button.Button


{-| Most buttons are a simple press/don't press switch.
This value lets you know whether the button is being pressed.
-}
pressed : Button -> Bool
pressed =
    Internal.Button.pressed


{-| Some buttons notice if they're being touched by the user,
often through the use of a touchscreen. Effectively,
some buttons let you see whether the user touches the button without pressing it.

Keep in mind that most controllers also set this value to true when the button
is being pressed.

-}
touched : Button -> Bool
touched =
    Internal.Button.touched


{-| Some buttons notice how firmly they're being pressed.

If the button supports this, this value shows how firmly, on a scale from 0 to 1.
If the button doesn't support this, the value will always be 0 (when not pressed) or 1 (when pressed).

-}
value : Button -> Float
value =
    Internal.Button.value


{-| The primary and most important button on the controller.
This button is used for actions like:

  - Jumping in a platformer
  - Pressing "OK" in menus
  - Serving as a "click" button to confirm actions

-}
primary : Gamepad -> Button
primary =
    Internal.Mapping.primary


{-| The secondary button is the secondary button that is second-most important.
For some controllers, it can be used as an complementing button to the primary button.
This button is used for actions like:

  - Using a special action in a platformer
  - Pressing "CANCEL" in menus
  - Serving as a cancel button to reverse actions

-}
secondary : Gamepad -> Button
secondary =
    Internal.Mapping.secondary


{-| The tertiary button is the button that is used rather infrequently,
but is still placed near the player's finger because the action is still used quite frequently.
This button is used for actions like:

  - Reloading in a shooter game
  - Using a special ability in a platformer
  - Hiding in a stealth game

-}
tertiary : Gamepad -> Button
tertiary =
    Internal.Mapping.tertiary


{-| The fourth button is the least accessible button and should effectively be used the least.
This button is used for actions like:

  - Opening a quick menu
  - Opening a settings menu
  - Activating a rare ability with a long cooldown

-}
quaternary : Gamepad -> Button
quaternary =
    Internal.Mapping.quaternary


{-| The up arrow button.
-}
up : Gamepad -> Button
up =
    Internal.Mapping.arrowUp


{-| The left arrow button.
-}
left : Gamepad -> Button
left =
    Internal.Mapping.arrowLeft


{-| The right arrow button.
-}
right : Gamepad -> Button
right =
    Internal.Mapping.arrowRight


{-| The down arrow button.
-}
down : Gamepad -> Button
down =
    Internal.Mapping.arrowDown


{-| The small button on the left front of the game controller.
-}
leftBumper : Gamepad -> Button
leftBumper =
    Internal.Mapping.leftBumper


{-| The small button on the right front of the game controller.
-}
rightBumper : Gamepad -> Button
rightBumper =
    Internal.Mapping.rightBumper


{-| The large button on the left front of the game controller.
-}
leftTrigger : Gamepad -> Button
leftTrigger =
    Internal.Mapping.leftTrigger


{-| The large button on the right front of the game controller.
-}
rightTrigger : Gamepad -> Button
rightTrigger =
    Internal.Mapping.rightTrigger


{-| Button by pressing down the left joystick.
-}
leftStick : Gamepad -> Button
leftStick =
    Internal.Mapping.leftJoystickButton


{-| Button by pressing down the right joystick.
-}
rightStick : Gamepad -> Button
rightStick =
    Internal.Mapping.rightJoystickButton


{-| The start button usually serves as a pause button to interrupt a game and open a menu.
Here, players can alter settings, change the window, or leave a game.
-}
start : Gamepad -> Button
start =
    Internal.Mapping.start


{-| The select button usually serves as an in-game button to interrupt a game and open an in-game menu.
For example, users might open their inventory this way, or look at a map of their surroundings.
-}
select : Gamepad -> Button
select =
    Internal.Mapping.select


{-| The home button is an unpredictable one, for some programs might interpret the button beyond your control.
The button usually serves as a method of turning a controller on/off, or changing the state of the game.
-}
home : Gamepad -> Button
home =
    Internal.Mapping.homeButton


{-| The touchpad button is a button that doesn't exist on most controllers.
It is often used for controlling the mouse, but it can also be used as a simple button.
-}
touchpad : Gamepad -> Button
touchpad =
    Internal.Mapping.touchpad


{-| Button in the north position.
-}
north : Gamepad -> Button
north =
    Internal.Mapping.north


{-| Button in the east position.
-}
east : Gamepad -> Button
east =
    Internal.Mapping.east


{-| Button in the south position.
-}
south : Gamepad -> Button
south =
    Internal.Mapping.south


{-| Button in the west position.
-}
west : Gamepad -> Button
west =
    Internal.Mapping.west
