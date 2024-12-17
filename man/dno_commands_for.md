% DNO_COMMANDS_FOR(1) 0.5.1 | User Commands
% Marc Munro
% December 2024

# NAME

dno_commands_for -  retrieve hook commands from BOARD_INFO for dno

# SYNOPSIS
 **dno_commands_for** hook_name

 **dno_commands_for** [OPTION]

# DESCRIPTION
Searches BOARD_INFO files, in the current directory, for hook commands
matching a hook name, and minimally pre-parses those commands before
writing them to stdout.

This is part of the dno Arduino software builder package.

# OPTIONS

**-h, --help**

    Provide help.

**-v, --version**

    Print version information and exit

# AVAILABLE HOOKS

According to the Arduino platform specification the following pre and
post build hooks exist:

  - sketch.prebuild;
  - sketch.postbuild;
  - libraries.prebuild;
  - libraries.postbuild;
  - core.prebuild;
  - core.postbuild;
  - linking.prelink;
  - linking.postlink;
  - objcopy.preobjcopy;
  - objcopy.postobjcopy;
  - savehex.presavehex;
  - savehex.postsavehex.

# COMMAND ORDERING

Each command hook line is of the form: 

    recipe.hooks.NAME.NUMBER.pattern=COMMAND

The commands returned by **dno_commands_for** are returned in their
numerical order.  Note that this is different from the Arduino IDE in
which NUMBER is sorted as an alphabetic field.

Since it was easier (and less offensive to the author's sense of what
is right) to sort "properly" **dno_commands_for** sorts the commands
returned numerically rather than alphabetically.

# EXIT STATUS

The program normally returns success.

# EXAMPLES
Retrieve the commands for the "prebuild" hook:

    $ **dno_commands_for** core.prebuild

# SEE ALSO
  **dno**(1) **BOARD_INFO**(5)

# LICENSE

**dno_commands_for** is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

**dno_commands_for** is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with dno. If not, see <https://www.gnu.org/licenses/>.

