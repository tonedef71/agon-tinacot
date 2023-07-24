# agon-tinacot
TINACOT, a recursive acronym which stands for "TINACOT is not a clone of Tetris", is an action strategy game written in [BBC BASIC v3](https://en.wikipedia.org/wiki/BBC_BASIC) and inspired by [tower defense games](https://en.wikipedia.org/wiki/Tower_defense) and [*Tetris*](https://en.wikipedia.org/wiki/Tetris).

* Originally created for the [4th Olimex AgonLight Week Programming Challenge 2023](https://olimex.wordpress.com/2023/07/14/agonlight-week-programming-challenge-issue-4/)
* TINACOT may be played on an [AgonLight retro-computer](https://www.olimex.com/Products/Retro-Computers/AgonLight2/open-source-hardware), the [AgonLight Emulator](https://github.com/astralaster/agon-light-emulator/releases), the upcoming [Agon Console8](https://heber.co.uk/agon-console8/), or the [BBC BASIC SDL](http://www.bbcbasic.co.uk/bbcsdl/).

## HOW TO PLAY

The object of TINACOT is to replicate a randomly generated sequence of colored game pieces by allowing colored game pieces that are advancing from the four orthogonal sides of the playing field to reach the center of the playing field.  

Advancing game pieces which reach the center of the playing field need to match the color and shape of the current target position in the sequence of game pieces shown at the top of the screen.  

If a non-matching game piece reaches the center of the playing field, the game ends as a loss.  

Advancing game pieces which do not match the color and shape of the current target piece may be repelled.  

Non-matching game pieces advancing toward the center may be repelled by pressing the arrow key on the keyboard which opposes the direction of the offending game piece (i.e. if the game piece is moving down towards the center, then press the up arrow key to repel it).

If by mistake a game piece is repelled which matches the current target piece in the sequence, then the game ends as a loss; so care should be taken when multiple matching pieces are advancing simultaneously toward the center of the playing field not to repel any of those matching pieces until the closest one of them reaches the center of the playing field.  

Five levels worth of sequences must be completed for the game to end as a win.

## Display
TINACOT supports multiple display modes on the AgonLight.  The game should be played in a mode that supports a minimum of 16 colors and minimum screen dimensions of 40 columns by 24 rows.  It is best played in 40-column mode as the game becomes quite easy and feels more tedious in higher resolution display modes.

On BBC BASIC SDL, one display mode (MODE 9) is supported.

## Controls
The four arrow keys (up, down, left, and right) are used to repel incoming game pieces which do not match the current target piece in the sequence being replicated.  

## High Scores
* The default high score is twenty-five hundred points.
* High scores will be saved to a file named `tinacot.hi` in the same folder as the `tinacot.bas` file.
* TINACOT must be run from the exact folder where the `tinacot.hi` file resides in order for the saved high scores to be read-in by the game.

## Demo Playthrough
https://github.com/tonedef71/agon-tinacot/assets/3978924/176c97d5-36e8-4b75-9b59-d8155c76f6f9
