# ----------
#  configure.ac
# 
#       Autoconf definitions for dno.
# 
#       Copyright (c) 2024, 2025
#       Author:  Marc Munro
# 	License: GPL V3
#  
#  ----------
#
AC_INIT([dno], [0.7.2])

[DNO_RELEASE_DATE="January 2025"]
AC_SUBST([DNO_RELEASE_DATE])

# Arduino dir.  Try to find an installed Arduino system.
#
AC_ARG_WITH([arduino-dir],
    AS_HELP_STRING([--with-arduino-dir], [Where to find arduino files]),
    [ARDUINO_DIR=${withval}],[ARDUINO_DIR="/usr/share/arduino"])

# Make this definition available to all config files.
# It might be worth making this a config option at some point.
#
DNO_EXTRA_BOARDS_FILE=${HOME}/.dno_boards_paths
AC_SUBST([DNO_EXTRA_BOARDS_FILE])

# We need sed and gawk, so fail configure step if they are not
# available.
AC_CHECK_PROG(SED, ['sed'],[yes],[no])
if test x"${SED}" = x"no" ; then
  AC_MSG_ERROR([sed not found: it is a required dependency of dno])
fi

AC_CHECK_PROG(GAWK, ['gawk'],[yes],[no]) 
if test x"${GAWK}" = x"no" ; then
  AC_MSG_ERROR([gawk not found: it is a required dependency of dno])
fi

# Find a command-line menu program
AC_PATH_PROG([DIALOG], ['dialog'])
AC_PATH_PROG([WHIPTAIL], ['whiptail'])
AS_IF([test x"${DIALOG}" = "x"],
      [DIALOG=${WHIPTAIL}])

AC_MSG_CHECKING([Checking terminal-based menu command])
if test -f "${DIALOG}"; then
  AC_MSG_RESULT([${DIALOG}])
else
  AC_MSG_RESULT([not found])
  AC_MSG_WARN([Unable to find menu command])
fi

# Convert the package version into DNO_IDE_VERSION.  This has 2 digits
# per (non-major) part and has the dots removed.
#
AC_DEFUN([DNO_IDE_VERSION2],
    [`echo "AC_PACKAGE_VERSION" | \
    	   [sed -e 's/\./.0/g' \
	        -e 's/[0-9]*\([0-9][0-9]\)/\\1/g' \
		-e 's/\.//g'`]])

ide_version=`echo "AC_PACKAGE_VERSION" | \
    	   [sed -e 's/\./.0/g' \
	        -e 's/[0-9]*\([0-9][0-9]\)/\\1/g' \
		-e 's/\.//g'`]

DNO_VERSION=AC_PACKAGE_VERSION
AC_SUBST([DNO_VERSION])

[DNO_IDE_VERSION=${ide_version}]
AC_SUBST([DNO_IDE_VERSION])

AC_PATH_PROG(PANDOC, ['pandoc'])
test -f "${PANDOC}" || \
    AC_MSG_WARN([pandoc not found.  Man pages cannot be created]) 

# Check for xslt - needed to build html docs
AC_PATH_PROG(XSLTPROC, ['xsltproc'])

test -f "${XSLTPROC}" || \
    AC_MSG_WARN([xsltproc not found.  User guide cannot be created]) 

# Check for xslt - needed to build html docs
AC_PATH_PROG(XMLLINT, ['xmllint'])

test -f "${XMLLINT}" || \
    AC_MSG_WARN([xmllint not found.  User guide cannot be created]) 

dnl Find docbook fastchunk stylesheet
AC_DEFUN([DNO_PATH_DOCBOOK_STYLESHEETS],
[AC_ARG_VAR(DOCBOOKSS, [location of Docbook stylesheet])
AC_MSG_CHECKING([for DocBook stylesheet])
AC_CACHE_VAL([pgac_cv_path_entities],
[if test -n "$DOCBOOKSS"; then
  dno_path=$DOCBOOKSS
else
  dno_path=
  for dno_prefix in /usr /usr/local /opt /sw /usr/share; do
    for dno_infix in share lib; do
      for dno_postfix in \
        xml/docbook/stylesheet/docbook-xsl-ns \
	sgml/docbook/stylesheet/docbook-xsl-ns 
      do
        dno_candidate=$dno_prefix/$dno_infix/$dno_postfix
        if test -r "$dno_candidate/xhtml/chunk.xsl" 
        then
          dno_path=$dno_candidate
          break 3
        fi
      done
    done
  done
fi])

DOCBOOKSS=$dno_path

AC_SUBST([DOCBOOKSS])
if test -n "$DOCBOOKSS"; then
  AC_MSG_RESULT([$DOCBOOKSS])
else
  AC_MSG_RESULT(no)
fi])

DNO_PATH_DOCBOOK_STYLESHEETS

# Identify host OS.  Currently only linux and macos are supported, so
# if it's not linux...
AC_CANONICAL_HOST
if ( echo "${host_os}" | grep -q -i linux ); then
    HOST_OS=linux
else
    HOST_OS=macosx
fi
AC_SUBST([HOST_OS])

AC_MSG_CHECKING([Checking arduino installation dir])
if test -d "${ARDUINO_DIR}"; then
  AC_MSG_RESULT([${ARDUINO_DIR}])
  AC_SUBST(ARDUINO_DIR)
else
  AC_MSG_RESULT([not found])
  AC_MSG_WARN([Unable to find installed arduinodir])
fi

[mm_ac_boards="${ARDUINO_DIR}/hardware/arduino/avr/boards.txt"]

AC_CHECK_FILE([${mm_ac_boards}],,
  AC_MSG_WARN([Unable to find boards.txt]))

BOARDS_TXT=${mm_ac_boards}
AC_SUBST(BOARDS_TXT)

AC_CONFIG_FILES([Makefile.global])
AC_CONFIG_FILES([bin/dno_commands_for])
AC_CONFIG_FILES([bin/dno_bpp])
AC_CONFIG_FILES([bin/dno_dirinfo])
AC_CONFIG_FILES([bin/dno_menu])
AC_CONFIG_FILES([bin/dno])
AC_CONFIG_FILES([man/BOARD_INFO.md])
AC_CONFIG_FILES([man/BOARD_OPTIONS.md])
AC_CONFIG_FILES([man/BOARD_TYPE.md])
AC_CONFIG_FILES([man/dno.md])
AC_CONFIG_FILES([man/dno_bpp.md])
AC_CONFIG_FILES([man/dno_checksize.md])
AC_CONFIG_FILES([man/dno_commands_for.md])
AC_CONFIG_FILES([man/dno_dirinfo.md])
AC_CONFIG_FILES([man/dno_menu.md])
AC_CONFIG_FILES([man/dno_requote.md])
AC_CONFIG_FILES([README.md])
AC_OUTPUT
 
