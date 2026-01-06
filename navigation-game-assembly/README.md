# Navigation Game – x86 Assembly

This project implements a simple navigation game written in x86 Assembly,
developed as part of the **Microprocessors and Assembly** course.

The game runs in 80×25 text mode and interacts directly with hardware
components such as the keyboard, real-time clock (RTC), and timer interrupts.

## Game Description
- The player starts at the center of the screen, represented by the character `0`.
- Movement is controlled using the **W, A, S, D** keys.
- Points appear on the screen as letters (`A`, `B`, `C`, …).
- Each collected point increases the score and spawns a new point at a random location.
- The game ends when:
  - The player reaches 9 points
  - The player hits a wall or screen border
  - The user presses **T**

At the end of the game, a message displaying the final score is printed.

## Implemented Features
- Direct screen manipulation via video memory (`0xB800`)
- Keyboard input using I/O ports `0x60` and `0x64`
- Randomized object placement using the **RTC**
- Collision detection with walls and screen borders
- Automatic movement using **PIT timer interrupt (INT 08h)**
- Time-based point aging:
  - Color change after a timeout
  - Automatic removal if not collected

## Technical Notes
- Written for **x86 real mode**
- No BIOS/DOS keyboard routines are used for input
- Interrupt Vector Table (IVT) is modified and restored properly
- The code is modular and documented with clear subroutine responsibilities

## Files
- `src/ex4.asm` – main game implementation
- `images/` – screenshots from gameplay

## Environment
- DOSBox / real-mode emulator
- Compatible with MASM/TASM-style assemblers
