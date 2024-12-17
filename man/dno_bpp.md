% DNO_BPP(1) 0.5.1 | User Commands
% Marc Munro
% December 2024

# NAME

dno_bpp -  Board and platform files parser for the dno Arduino build system.

# SYNOPSIS
 **dno_bpp** [OPTION]...

# DESCRIPTION
Parses Arduino boards.txt and platform.txt files to create
inclusion-files for dno (a make-based build system), to identify the
available boards, and to help create dno BOARD_TYPE and BOARD_INFO files.

This is part of the dno Arduino software builder package.

# OPTIONS

**-b board, --board board**

    Specify a board to be searched for in the boards.txt file(s) If
    board is in the form x.y, then cpu will be determined from y, and
    board from x.  If the board is not completely specified, a list of
    possible boards will be printed.
    
**-c cpu, --cpu cpu**

    Specify a cpu to be searched for in the boards.txt file(s)

**-d dir, --dir dir**

    Specify a directory to search for boards.txt This may be specified
    multiple times to allow for multiple boards.txt files.

**-f, --friendly**

    Friendly-format the output.  This is mostly useful when not fully
    specifying the board that we are interested in.  This makes the
    board listing output more human-friendly.
    
**-h, --help**

    Provide help.

**-n, --no, --nodefaults**

    Do not use the system default dno paths for the boards.txt files.
    You must provide at least one explicit --dir option in this case.

**-p, --params**

    Print build parameters for inclusion into a makefile, etc.  This
    is used to create a BOARD_INFO file for dno.

**-q, --quiet**

    Be silent

**-t, --type**

    Print the board type definition in a format suitable for a dno
    BOARD_TYPE file.
    
**-v, --version**

    Print version information and exit

**-x**

    Provide directory path discovery services to an inferior version
    of this executable that is determining build parameters. 

# FILES
By default, **dno_bpp** looks for platforms.txt and boards.txt files in
the paths specified in:

    ~/.dno_boards_paths

If your OS has an Arduino package installed it may additionally be
able to find those files in their standard installation directory.  If
it cannot, then add the path of the packages platforms.txt file into
~/.dno_boards_paths. 

Note that if the specified board can be found in multiple boards.txt
files, the one that is specified last in ~/.dno_boards_paths is the
one that will be used.

# EXIT STATUS

The program returns a success code only if a single matching board is
found in in our searched boards.txt files.

# EXAMPLES
Provide a human readable list of all board types from the boards.txt
file in a given board-path:

    $ **dno_bpp** -d /usr/share/arduino/hardware/arduino/avr -f

List the set of arduino pro board types, in a form suitable for a
dno BOARD_TYPE file:

    $ **dno_bpp** -d /usr/share/arduino/hardware/arduino/avr -b pro -t

List the full set of board parameters, for inclusion into a dno
BOARD_INFO file, for an Arduino pro 8MHzatmega328:

    $ **dno_bpp** -d /usr/share/arduino/hardware/arduino/avr \
    	    -b pro -c 8MHzatmega328 -p


# SEE ALSO
  **dno**(1) **BOARD_INFO**(5) **BOARD_TYPE**(5)

# LICENSE

**dno_bpp** is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

**dno_bpp** is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with dno. If not, see <https://www.gnu.org/licenses/>.

