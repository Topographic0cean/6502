# 6502
A 6502 emulator based on fake6502 and Ben Eater's hardware design.   The object is to create a simple test harness to prototype and debug BASIC and 6502 assembly programs.

The code generated here can alos be used as is on the Ben Eater hardware.  I also include scripts and information to make it easier to connect to the hardware.

# Dependencies
On Mac, install popt with "brew install popt".  

Install cc65 from https://cc65.github.io/

# Directory Structure

## basic
The basic directory contains various games from the classic Basic Games book.   They should all run as in on the emulator and the 6502 computer.

## programs
The programs folder contains assembly programs that can be entered into the computer or emulator using Wozman.  The .prg file is in a format that can be simply pasted into the terminal.

### pi.s
Compute the digits of pi and display them on the LCD.

## rom
Contains the rom code.  When compiled, it produces a rom.bin file that should be burned into the eprom.  This rom contains the following.

### wozmon
When the computer is reset, it will start running Wozmon allowing viewing and editing of RAM, loading and executing of assembly code, and running MS Basic, which is stored at addres $8000.

###

## src

# Hardware

## scripts
The scripts directory has various helpers to update and connect to the hardware

### mini 
Connect to the hardward with minicom.
