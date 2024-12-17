% DNO_CHECKSIZE(1) 0.5.1 | User Commands
% Marc Munro
% December 2024

# NAME

**dno_checksize** - Arduino image size checker for dno

# SYNOPSIS
 avr-size | **dno_checksize** MAX_DATA=max_data_size MAX_UPLOAD=max_upload_size

# DESCRIPTION
This filter takes image size information from avr-size as stdin,
formats it into a friendlier output format and ensures that the size
is within the limits identified on the command line.

This is part of the dno Arduino software builder package.

# EXIT STATUS

Returns success as long as the image fits within the specified limits,
else an error code is returned.

# SEE ALSO
  **dno**(1)

# LICENSE

**dno_checksize** is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

**dno_checksize** is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with dno. If not, see <https://www.gnu.org/licenses/>.

