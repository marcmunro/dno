% DNO_REQUOTE(1) dno 0.5.1 | User Commands
% Marc Munro
% December 2024

# NAME

dno_requote - Process the quotes in an Arduino recipe command into a
format suitable for bash

# SYNOPSIS
 echo 'COMMAND' | **dno_requote** 

# DESCRIPTION

**dno_requote** is a filter that takes Arduino recipe commands as
stdin, and converts the quoting within these commands to be compatible
with bash.

It is not clear to the author what the original quoting is compatible
with.

This is part of the dno Arduino software builder package.

# SEE ALSO
  **dno**(1) **BOARD_INFO**(5)

# LICENSE

**dno_requote** is free software: you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation, version 3 of the License.

**dno_requote** is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with dno. If not, see <https://www.gnu.org/licenses/>.

