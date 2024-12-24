# 
#       Makefile for building and installing dno, the Arduino build
#       system
# 
#       Copyright (c) 2024 Marc Munro
#       Author:  Marc Munro
# 	License: GPL-3.0
#  
#

# TODO:
#  release stuff:
#    - ensure version is bumped
#    - ensure release date is bumped
#    - check dates (copyright) in headers

# Do not use make's built-in rules
# (this improves performance and avoids hard-to-debug behaviour).
#
MAKEFLAGS += -r

SHELL = bash

###########
# General definitions
#

# Figure out the path to this makefile, and to the makefile that we
# initially invoked.
#
MAKEFILEPATH := $(realpath $(call lastword,$(MAKEFILE_LIST)))
ROOT_MAKEFILE := $(firstword $(MAKEFILE_LIST))
ROOTDIR := $(realpath $(dir $(MAKEFILEPATH)))
BINDIR :=  $(realpath $(ROOTDIR)/../bin)


###########
# Helper definitions
#

# empty definition.  Needed by the succeeding definition for "space".
empty =

# An explicit space definition for use in macros.  Generally, macros
# eliminate leading spaces.  Using this definition will prevent that.
space = $(empty) $(empty)


###########
# Verbosity control.  Define VERBOSE on the command line to show the
# full compilation, etc commands.  If VERBOSE is defined $(FEEDBACK)
# will do nothing and $(AT) will have no effect, otherwise $(FEEDBACK)
# will perform an echo and $(AT) will make the command that follows it
# execute quietly.
# FEEDBACK_RAW may be used in multi-line shell commands where part of the
# command can usefully provide feedback.
#

# QUIET is used to prevent the automatic display of object size
# information.  VERBOSE can be used to force a more full display of
# object size info.

# Try to make the output of the avr-size executable a little more
# helpful.
#
ifndef VERBOSE
  ifdef QUIET
    # Make avr_size do nothing.  This breaks the verify_size target if
    # QUIET is defined but that seems acceptable.
    avr_size = true
  else
    # Define avr_size to handle parameters based on capability
    ifeq ($(SIZE_FOR_AVR),yes)
      ifeq ($(notdir $(avr_size)),$(notdir $(AVR_SIZE_CMD)))
        # There is a patched version of size that handles AVR with
        # prettier output.
        avr_flags = --format=avr
      endif
    endif
  endif
endif

ifdef VERBOSE
    FEEDBACK = @true
    FEEDBACK_RAW = true
    VERBOSEP = VERBOSE=y
    QUIET = 
    AT =
else
    FEEDBACK = @echo " "
    FEEDBACK_RAW = echo " "
    QUIET = 2>/dev/null
    AT = @
endif


CONFIGURE_TARGETS := $(ROOTDIR)/Makefile.global
CONFIGURE_DEPENDENCIES := $(ROOTDIR)/Makefile.global.in

include $(ROOTDIR)/Makefile.global


################################################################
# default target
#

.PHONY: all 

all: configure bin man docs 


################################################################
# dno_requote
#
.PHONY: bin

SCRIPT_SOURCES = $(wildcard bin/*.in)
SCRIPT_TARGETS = $(SCRIPT_SOURCES:%.in=%)
CONFIGURE_TARGETS += $(SCRIPT_TARGETS)
CONFIGURE_DEPENDENCIES += $(SCRIPT_SOURCES)

bin: bin/dno_requote configure $(CONFIGURE_TARGETS)

EVERYTHING := bin/dno_requote configure $(CONFIGURE_TARGETS)

bin/dno_requote: src/dno_requote.c
	$(FEEDBACK)  CC, LD [$(notdir $@)]
	$(AT) $(CC) $(LDFLAGS) -o $@ $<


################################################################
# man targets
#

.PHONY: man

MAN_DEPS = $(wildcard man/*.md.in)
MAN_SOURCES = $(MAN_DEPS:%.md.in=%.md)
MAN_1_TARGETS = $(patsubst %.md.in,%.1,$(wildcard man/dno*.md.in))
MAN_5_TARGETS = $(patsubst %.md.in,%.5,$(wildcard man/BOARD*.md.in))
CONFIGURE_TARGETS += $(MAN_SOURCES)
CONFIGURE_DEPENDENCIES += $(MAN_DEPS)

EVERYTHING += $(MAN_1_TARGETS) $(MAN_5_TARGETS)

ifneq "$(PANDOC)" ""
man: $(MAN_1_TARGETS) $(MAN_5_TARGETS)
else
man:
	@echo "UNABLE TO CREATE MAN PAGES; pandoc is not available." 1>&2
endif

man: $(MAN_1_TARGETS) $(MAN_5_TARGETS)

# Man page from markdown.
#
%.1: %.md
	$(FEEDBACK) PANDOC $@
	$(AT) set -o pipefail; $(PANDOC) $< -s -t man | \
	    sed -e 's/<h1>/<h3>/' > $@ || ( rm $@; false )

# Man page from markdown.
#
%.5: %.md
	$(FEEDBACK) PANDOC $@
	$(AT) set -o pipefail; $(PANDOC) $< -s -t man  | \
	    sed -e 's/<h1>/<h3>/' > $@ || ( rm $@; false )


################################################################
# Documentation targets
# 
.PHONY: docs


HTMLDIR = html
DOC_SOURCES = docs/dno_doc.xml
DOC_MANPAGES = $(patsubst man/%.md,docs/parts/%.xml,$(wildcard man/*.md))
BASE_STYLESHEET = $(DOCBOOK_STYLESHEETS)/html/chunkfast.xsl
DNO_CORE_STYLESHEET = docs/core-stylesheet.xsl
DNO_LOCAL_STYLESHEET =  docs/html_stylesheet.xsl
DNO_STYLESHEET = docs/html_stylesheet.xsl

# Figure out if we are able to build docs and try to provide useful
# feedback if not.
#
MISSING := $(if $(PANDOC),,.pandoc) \
	   $(if $(XSLTPROC),,.xlstproc) \
	   $(if $(DOCBOOK_STYLESHEETS),,.docbook stylesheets)

ifeq "$(strip $(MISSING))" ""

docs: $(HTMLDIR)/index.html configure $(DNO_CORE_STYLESHEET)

EVERYTHING += $(HTMLDIR)/index.html $(DNO_CORE_STYLESHEET)

$(DNO_CORE_STYLESHEET): $(BASE_STYLESHEET) Makefile
	@echo "Creating importer for system base stylesheet for docs..."
	@{ \
	  echo "<?xml version='1.0'?>"; \
	  echo "<xsl:stylesheet"; \
	  echo "   xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\""; \
	  echo "   version=\"1.0\">"; \
	  echo "  <xsl:import"; \
	  echo "     href=\"$(BASE_STYLESHEET)\"/>"; \
	  echo "</xsl:stylesheet>"; \
	} > $@

else
    MISSING := $(shell echo "$(MISSING)" |\
		       sed -e 's/^\.//' \
		           -e 's/\.\([^.]*\)$$/and \1/' \
			   -e 's/ \./, /')
    CONJ := $(if $(findstring and ,$(MISSING)),are,is)


docs: 
	@echo -e "Unable to build docs:\n"\
	         "  $(strip $(MISSING)) $(CONJ) not available." 1>&2
endif



# docbook version of manpage from markdown
#
docs/parts/%.xml: man/%.md
	$(FEEDBACK) PANDOC $@
	$(AT) $(PANDOC) $< -s -t man --top-level-division=section \
	    -w docbook4 | tail -n +4 >$@


#$(AT) pandoc $< -s -t man -w docbook4 -o $@

$(HTMLDIR)/index.html: $(DOC_SOURCES) $(DOC_MANPAGES) \
		       $(VERSION_FILE) $(DNO_LOCAL_STYLESHEET) \
		       $(DNO_CORE_STYLESHEET)
	$(FEEDBACK) $(XSLTPROC) "<docbook sources>.xml -->" $@
	@mkdir -p html
	$(AT) $(XSLTPROC) $(XSLTPROCFLAGS) --output html/ \
		$(DNO_LOCAL_STYLESHEET) docs/dno_doc.xml

# Create html from markdown.  This enables us to test the formatting
# of markdown files such as our README.md
#
%.html: %.md
	$(PANDOC) --shift-heading-level-by=-1 $*.md \
	       --standalone --to=html >$*.html


################################################################
# autoconf targets

# Run configure when any of the configure input files have been
# updated.
# Note that this makes the configure-generated files read-only to
# discourage accidentally editing them.  Note also the use of "grouped
# targets" ("&:").  This tells make that running this recipe updates
# *all* of the targets at once.
#

configure: $(CONFIGURE_TARGETS)

$(CONFIGURE_TARGETS) &: $(ROOTDIR)/configure $(CONFIGURE_DEPENDENCIES)
	$(FEEDBACK) CONFIGURE $(CONFIGURE_TARGETS)
	$(AT) (cd $(ROOTDIR); ./configure || exit 2) | sed -e 's/^/    /'
	$(AT) echo
	$(AT) chmod -w -f $(CONFIGURE_TARGETS)


# Recreate configure
#
# Automatically regenerate configure when configure.ac has been
# updated.  This rule allows for the non-existence of configure.ac and
# aclocal.m4, which could be the case with a distributed tarball
# (packaged release), allowing builds in the absence of autotools.
#
$(ROOTDIR)/configure: $(ROOTDIR)/configure.ac
	$(FEEDBACK) RECONFIGURING DNO
	$(AT)if [ -f $(ROOTDIR)/configure.ac ]; then \
	    if [ ! -d $(ROOTDIR)aclocal.m4 ]; then \
	        $(FEEDBACK_RAW) " " ACLOCAL; \
	        (cd $(ROOTDIR); aclocal); \
	    fi; \
	    $(FEEDBACK_RAW) " " AUTOCONF; \
	    (cd $(ROOTDIR); autoconf); \
	else \
	    echo "Canot find configure.ac" 1>&2; \
	    false; \
	fi

# Do nothing.  This allows make to work in the absence of configure.ac
# and autoconf, which will be the case for a packaged release.
#
$(ROOTDIR)/configure.ac $(ROOTDIR)/configure_board.ac :
	@>/dev/null


################################################################
# Cleanup targets
# 

.PHONY: clean distclean

garbage += \\\#*  .\\\#*  *~ 
GENERATED_FILES = $(CONFIGURE_TARGETS) $(MAN_1_TARGETS) \
		  $(MAN_5_TARGETS) $(DOC_MANPAGES) \
		  $(DNO_CORE_STYLESHEET) $(SCRIPT_TARGETS) \
		  $(wildcard dno*.tgz) bin/dno_requote
clean:
	$(AT) rm -f $(garbage) $(GENERATED_FILES)
	$(AT) cd docs; rm -f $(garbage) 
	$(AT) cd man; rm -f $(garbage) 
	$(AT) rm -rf html

distclean: clean
	$(AT) rm -rf configure config.log config.status \
		Makefile.global autom4te.cache


################################################################
# Install targets
# 
.PHONY: install uninstall

DNO_EXECUTABLES = $(patsubst man/%.1,%,$(MAN_1_TARGETS))
DNO_EXECUTABLE_FILES = $(patsubst %,bin/%, $(DNO_EXECUTABLES))
DNO_INSTALLABLES = $(patsubst %,$(INSTALL_BINDIR)/%, $(DNO_EXECUTABLES))

install: docs bin
	@echo Installing dno executables in $(INSTALL_BINDIR)
	$(AT) cp $(DNO_EXECUTABLE_FILES) $(INSTALL_BINDIR)
	$(AT) chmod 755 $(DNO_INSTALLABLES)
	@echo Install dno man pages in $(INSTALL_MANDIR)
	$(AT) cp $(MAN_1_TARGETS) $(INSTALL_MANDIR)/man1
	$(AT) cp $(MAN_5_TARGETS) $(INSTALL_MANDIR)/man5

uninstall:
	@echo Uninstalling dno man pages from $(INSTALL_MANDIR)
	$(AT) -cd $(INSTALL_MANDIR)/man1; rm -f $(notdir $(MAN_1_TARGETS))
	$(AT) -cd $(INSTALL_MANDIR)/man5; rm -f $(notdir $(MAN_5_TARGETS))
	@echo Uninstalling dno executables from $(INSTALL_BINDIR)
	$(AT) @-rm $(DNO_INSTALLABLES)


################################################################
# Release targets
# 

.PHONY: release tarball check_commit check_remote check_tag \
	check_tarball release_tarball

GIT_UPSTREAM = github origin

release: check_commit check_tarball check_remote check_tag 

# Check that there are no uncomitted changes.
check_commit:
	$(FEEDBACK) CHECKING COMMIT
	@git status -s | wc -l | grep '^0$$' >/dev/null || \
	    (echo "    UNCOMMITTED CHANGES FOUND"; exit 2)

# Check that we have pushed the latest changes
check_remote:
	$(FEEDBACK) CHECKING REMOTE
	@err=0; \
	 for origin in $(GIT_UPSTREAM); do \
	    git remote show $${origin} 2>/dev/null | \
	    grep "^ *main.*up to date" >/dev/null || \
	    { echo "    UNPUSHED UPDATES FOR $${origin}"; \
	      err=2; }; \
	done; exit $$err

$(eval $(shell grep "DNO_VERSION[[:space:]]*=" bin/dno))

# Check that head has been tagged.  We assume that if it has, then it
# has been tagged correctly.
check_tag:
	$(FEEDBACK) CHECKING TAG
	@echo VERSION = $(DNO_VERSION)
	@tag=`git tag --points-at HEAD`; \
	if [ "x$${tag}" = "x" ]; then \
	    echo "    NO GIT TAG IN PLACE"; \
	    exit 2; \
	fi

check_tarball: 
	$(FEEDBACK) CHECKING TARBALL
	$(AT) if [ ! -f releases/dno_$(DNO_VERSION).tgz ]; then \
	    echo "TARBALL FOR DNO $(DNO_VERSION) DOES NOT EXIST" 1>&2; \
	    echo "  try \"make release_tarball\"" 1>&2; \
	    false; \
	fi

release_tarball: 
	$(AT) if [ -f releases/dno_$(DNO_VERSION).tgz ]; then \
	    (echo "Release for dno $(DNO_VERSION) already exists."); \
	else \
	    $(FEEDBACK_RAW) COPYING TARFILE; \
	    $(MAKE) dno_$(DNO_VERSION).tgz; \
	    cp dno_$(DNO_VERSION).tgz releases; \
	fi

tarball: 
	$(FEEDBACK) CLEANING
	@$(MAKE) clean
	@$(MAKE) 
	@$(MAKE) dno_$(DNO_VERSION).tgz

dno_$(DNO_VERSION).tgz: 
	$(FEEDBACK) TAR $@
	$(AT) touch configure
	$(AT) tar czf dno_$(DNO_VERSION).tgz --exclude releases \
	          --exclude config.log --exclude dno_$(DNO_VERSION).tgz *


# Local Variables:
# mode: makefile
# End:
