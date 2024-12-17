% BOARD_TYPE(5) 0.5.1 | dno Configuration Files
% Marc Munro
% December 2024

# NAME

BOARD_TYPE - identify an Arduino board type for dno

# DESCRIPTION
BOARD_TYPE files are used to identify the type of Arduino board that a
dno board directory is going to be used to compile and build for.

It consists of a single line that identifies an Arduino board.  Some
boards with CPU-variants are further identified by a cpu-variant name
in the form BOARD.CPU_VARIANT, eg pro.8MHzatmega168.

The board names are derived from boards.txt files that are distributed
with Arduino software.

To see the list of possible boards use:

    $ dno_bpp -t

To create a BOARD_TYPE file use:

    $ dno BOARD_TYPE BOARD=<BOARD_NAME>

eg:

    $ dno BOARD_TYPE BOARD=uno	

# SEE ALSO
  **dno**(1) **dno_bpp**(1)

