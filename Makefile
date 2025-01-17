# 
#       Makefile for building and installing dno, the Arduino build
#       system
# 
#       Copyright (c) 2024, 2025 Marc Munro
#       Author:  Marc Munro
# 	License: GPL-3.0
#  
#

# To publish documentation to github pages do the following:
#   (the pages will appear under  https://marcmunro.github.io/dno/docs/html)
#
# We use a special branch to contain the html as we don't want it in
# our main branch.  This is gh-pages.  The way to generate the pages
# is as follows:
#  make clean
#  git commit -a
#  git checkout gh-pages
#  git marge main
#  make docs
#  git commit -a
#  git push github gh-pages
#  git checkout main

# TODO:
# - add links between man pages?

# Do not use make's built-in rules
# (this improves performance and avoids hard-to-debug behaviour).
#
MAKEFLAGS += -r

# Need bash for pipefail option
#
SHELL = bash


###########
# General definitions
#
MAKEFILEPATH := $(realpath $(call lastword,$(MAKEFILE_LIST)))
ROOT_MAKEFILE := $(firstword $(MAKEFILE_LIST))
ROOTDIR := $(realpath $(dir $(MAKEFILEPATH)))


###########
# Helper definitions
#

# empty definition.  Needed by the succeeding definition for "space".
empty =

# An explicit space definition for use in macros.  Generally macros
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

ifdef VERBOSE
    FEEDBACK = @true
    FEEDBACK_RAW = true
    VERBOSEP = VERBOSE=y
    AT =
else
    FEEDBACK = @echo " "
    FEEDBACK_RAW = echo " "
    AT = @
endif


################################################################
# default target
#

.PHONY: all 

all: configure bin man docs 


################################################################
# Build-specific settings
#

SCRIPT_INPUTS = $(wildcard bin/*.in)
SCRIPT_TARGETS = $(SCRIPT_SOURCES:%.in=%)

MAN_INPUTS = $(wildcard man/*.md.in)
MAN_INTERMEDIATES = $(MAN_INPUTS:%.md.in=%.md)

MAN_1_TARGETS = $(patsubst %.md.in,%.1,$(wildcard man/dno*.md.in))
MAN_5_TARGETS = $(patsubst %.md.in,%.5,$(wildcard man/BOARD*.md.in))
MAN_TARGETS = $(MAN_1_TARGETS) $(MAN_5_TARGETS)

EXECUTABLE_SOURCES = src/dno_requote.c
EXECUTABLE_TARGETS = bin/dno_requote

CONFIGURE_INPUTS := Makefile.global.in $(SCRIPT_INPUTS) $(MAN_INPUTS)
CONFIGURE_TARGETS := Makefile.global $(SCRIPT_TARGETS) $(MAN_INTERMEDIATES)
CONFIGURE_OUTPUTS := config.status


################################################################
# autoconf targets

# Run configure when any of the configure input files have been
# updated.
# Note that this makes the configure-generated files read-only to
# discourage accidentally editing them.  Note also the use of "grouped
# targets" ("&:").  This tells make that running this recipe updates
# *all* of the targets at once.
# The chmod below is used to mke it harder to accidentally edit
# generated files.
#
$(CONFIGURE_TARGETS) &: configure $(CONFIGURE_INPUTS)
	$(FEEDBACK) CONFIGURE...
	$(AT) set -o pipefail; ./configure | sed -e 's/^/    /'
	$(AT) chmod -w -f $(CONFIGURE_TARGETS)

# Recreate configure
#
# We only recreate configure if:
#   - configure.ac exists; and
#   - it is more up to date than configure; and
#   - config.log exists, or configure is an explicit target.
#
# This odd-seeming set of rules is so that we can safely build from a
# fresh git clone or a tarball without trying to run autoconf.
# Autoconf should only be run if configure.ac has actually been
# updated.  With a fresh git clone this is not possible to tell, as
# git may give configure.ac a more recent timestamp than it gives
# configure (I see no guarantees around this).
# We get around this by only assuming that the configure timestamp is
# reliable if config.log exists, which means that configure has been
# run at least once.  If you want to rebuild your configure script
# using autoconf, you either need to have a config.log file in place
# (which would normally be the case), or explicitly specify configure
# as a target when you run make.
#
.PHONY: FORCE
CONFIGURE_DEP := $(if $(filter configure,$(MAKECMDGOALS)),\
		     $(if $(MAKE_RESTARTS),,FORCE),\
	           $(and $(wildcard config.log),\
		         $(wildcard configure.ac)))

configure: $(CONFIGURE_DEP)
	$(FEEDBACK) RECONFIGURING DNO
	$(AT)set -e; if [ -f $(ROOTDIR)/configure.ac ]; then \
	    if [ ! -d aclocal.m4 ]; then \
	        $(FEEDBACK_RAW) " " ACLOCAL; \
	        aclocal; \
	    fi; \
	    $(FEEDBACK_RAW) " " AUTOCONF; \
	    autoconf; \
	    touch $@; \
	else \
	    echo "Cannot find configure.ac" 1>&2; \
	    false; \
	fi

# Certain targets do not need the dependency files.  In fact those files can
# get in the way (eg for the clean targets).  This definition allows those
# targets to work without attempting to refresh the dependency files.
#
NO_DEP_TARGETS = clean tidy distclean 

HAVE_NODEP_GOALS = $(strip \
	             $(foreach target,$(NO_DEP_TARGETS),\
                       $(filter $(target),$(MAKECMDGOALS))))

ifeq "$(HAVE_NODEP_GOALS)" ""
  include Makefile.global
endif


################################################################
# dno_requote
#
.PHONY: bin


bin: bin/dno_requote configure $(CONFIGURE_TARGETS)

bin/dno_requote: src/dno_requote.c
	$(FEEDBACK)  CC, LD [$(notdir $@)]
	$(AT) $(CC) $(LDFLAGS) -o $@ $<


################################################################
# man targets
#
.PHONY: man

# This filter modifies the title to make it better fit our
# documentation requirements.
#
MAN_FILTER = xsltproc docs/man2db.xsl -

ifdef PANDOC
  PANDOC2MAN = set -o pipefail; $(PANDOC) $< -s -t man | \
	           sed -e 's/<h1>/<h3>/' > $@ || (rm $@; false)
  PANDOC2DOCBOOK = set -o pipefail; \
		   $(PANDOC) $< -s -t man -w docbook5 \
			     --top-level-division=section \
		             --id-prefix="$(basename $(notdir $<))-" | \
		     $(MAN_FILTER) >$@ || (rm $@; false)
  PANDOC_FEEDBACK = $(FEEDBACK)
else
  PANDOC_FEEDBACK = @\#
  PANDOC2MAN = $(if $(wildcard $@),\
		   touch $@; echo "    Using distributed version of $@",\
		   echo "pandoc not installed.  Baling out..." 1>&2; false)
  PANDOC2DOCBOOK = $(PANDOC2MAN)
endif

man: $(MAN_1_TARGETS) $(MAN_5_TARGETS)

# Man page from markdown.
# If we are building from a tarball and do not have pandoc we will
# use the man pages from the tarball and touch them to bring them up
# to date.
#
%.1 %.5: %.md
	$(PANDOC_FEEDBACK) PANDOC $@
	$(AT) $(PANDOC2MAN)


################################################################
# Documentation targets
# 
.PHONY: docs

# TODO: core stylesheet should not be distributed in tarball.

HTMLDIR = html
DOC_SOURCES = docs/dno_doc.xml docs/installation.xml \
	      docs/toolsets.xml docs/getting_started.xml \
	      docs/a_little_exploration.xml docs/directory_system.xml \
	      docs/libraries.xml docs/documentation.xml \
	      docs/other.xml
DOC_IMAGES = $(wildcard docs/*.png)

COMBINED_DOC = docs/full_doc.xml
BASE_STYLESHEET = $(DOCBOOK_STYLESHEETS)/html/chunkfast.xsl
DNO_LOCAL_STYLESHEET =  docs/html_stylesheet.xsl
DNO_STYLESHEET = docs/html_stylesheet.xsl
DNO_CORE_STYLESHEET = docs/core-stylesheet.xsl
DOC_MANPAGES = $(patsubst man/%.md,docs/parts/%.xml,$(wildcard man/*.md))
DOC_TARGETS = $(DNO_CORE_STYLESHEET) $(DOC_MANPAGES) $(COMBINED_DOC)

CAN_BUILD_DOCBOOK = $(and $(DOCBOOK_STYLESHEETS), $(XSLTPROC), $(XMLLINT))

ifneq "$(CAN_BUILD_DOCBOOK)" ""

docs: $(HTMLDIR)/index.html configure $(DNO_CORE_STYLESHEET)

$(COMBINED_DOC): $(DOC_SOURCES) $(DOC_MANPAGES) docs/man2db.xsl
	$(FEEDBACK) XMLLINT $@
	$(AT) xmllint --xinclude --output $@ docs/dno_doc.xml || \
	    (rm -f $@; false)

$(HTMLDIR)/index.html: $(COMBINED_DOC) \
		       $(VERSION_FILE) $(DNO_LOCAL_STYLESHEET) \
		       $(DNO_CORE_STYLESHEET) $(DOC_IMAGES)
	$(FEEDBACK) $(XSLTPROC) "<docbook sources>.xml -->" $@
	@mkdir -p html
	$(AT) cp -f $(DOC_IMAGES) html
	$(AT) $(XSLTPROC) $(XSLTPROCFLAGS) --output html/ \
		$(DNO_LOCAL_STYLESHEET) $(COMBINED_DOC)

# docbook version of manpage from markdown
#
docs/parts/%.xml: man/%.md
	$(PANDOC_FEEDBACK) PANDOC $@
	$(AT) mkdir -p $(dir $@)
	$(AT) $(PANDOC2DOCBOOK)

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

docs_target = $(wildcard $(HTMLDIR)/index.html)
ifeq "$(docs_target)" ""
docs:
	@echo "unable to build docs: "
	@echo "  xsltproc and the docbook stylesheets must be installed"
else
docs: $(docs_target)

$(docs_target): $(CONFIGURE_OUTPUTS)
	@$(and $(docs_target),touch $(docs_target))
	@echo "    Using distributed version of docs"
endif
endif

# Create html from markdown.  This enables us to test the formatting
# of markdown files such as our README.md
#
%.html: %.md
	$(PANDOC) --shift-heading-level-by=-1 $*.md \
	       --standalone --to=html >$*.html



# TODO: deal with docbook and xslt being unavailable


################################################################
# Cleanup targets
# 

.PHONY: clean tidy distclean

# Emacs temp and backup files
#
garbage += \\\#*  .\\\#*  *~ 

# Remove tmp files
#
tidy:
	$(FEEDBACK) TIDYING...
	$(AT) find . -type d | grep -v .git | while read dir; do \
	    ( cd $${dir}; rm -f $(garbage) ); done

# Remove generated files
#
clean: tidy
	$(AT) rm -f docs/parts/*
	$(AT) rm -f html/*
	$(AT) rm -f $(CONFIGURE_TARGETS) $(CONFIGURE_OUTPUTS) \
		    $(EXECUTABLE_TARGETS) $(MAN_TARGETS) \
		    $(DOC_TARGETS) config.log

distclean: clean
	$(AT) rm -rf configure autom4te.cache config.log


################################################################
# tarball
# The tarball contains everything needed for a dno installation
# without having to build anything.
#
.PHONY: tarball
tarball: dno_$(DNO_VERSION).tgz

GENERATED_FILES = $(CONFIGURE_TARGETS) $(MAN_1_TARGETS) \
		  $(MAN_5_TARGETS) $(DOC_MANPAGES) \
		  $(DNO_CORE_STYLESHEET) $(SCRIPT_TARGETS) \
		  bin/dno_requote $(HTMLDIR)/index.html

dno_$(DNO_VERSION).tgz: $(GENERATED_FILES) | tidy all
	$(FEEDBACK) TAR $@
	$(AT) touch dno_$(DNO_VERSION).tgz
	$(AT) cd ..; tar czf dno/dno_$(DNO_VERSION).tgz \
		  --exclude dno/releases \
		  --exclude dno/.git \
	          --exclude dno/dno_$(DNO_VERSION).tgz \
		  --exclude Makefile.global \
		  --exclude bin/dno_requote dno


################################################################
# Install targets
# 
.PHONY: install uninstall

DNO_EXECUTABLES = $(patsubst man/%.1,%,$(MAN_1_TARGETS))
DNO_EXECUTABLE_FILES = $(patsubst %,bin/%, $(DNO_EXECUTABLES))
DNO_INSTALLABLES = $(patsubst %,$(INSTALL_BINDIR)/%, $(DNO_EXECUTABLES))

install: docs bin
	@echo Installing dno executables in $(INSTALL_BINDIR)
	$(AT) mkdir -p $(INSTALL_BINDIR)
	$(AT) cp $(DNO_EXECUTABLE_FILES) $(INSTALL_BINDIR)
	$(AT) chmod 755 $(DNO_INSTALLABLES)
	@echo Install dno man pages in $(INSTALL_MANDIR)
	$(AT) mkdir -p $(INSTALL_MANDIR)/man1 $(INSTALL_MANDIR)/man5
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

release: check_tarball check_commit check_remote check_tag 
	@echo RELEASE APPEARS OK

# Check that there are no uncomitted changes.
check_commit:
	$(FEEDBACK) Checking commit...
	@git status -s | wc -l | grep '^0$$' >/dev/null || \
	    (echo "    UNCOMMITTED CHANGES FOUND"; exit 2)

# Check that we have pushed the latest changes
check_remote:
	$(FEEDBACK) Checking remote...
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
	$(FEEDBACK) Checking tag...
	@echo VERSION = $(DNO_VERSION)
	@tag=`git tag --points-at HEAD`; \
	if [ "x$${tag}" = "x" ]; then \
	    echo "    NO GIT TAG IN PLACE"; \
	    exit 2; \
	fi

check_tarball: 
	$(FEEDBACK) Checking tarball...
	$(AT) if [ ! -f releases/dno_$(DNO_VERSION).tgz ]; then \
	    echo "TARBALL FOR DNO $(DNO_VERSION) DOES NOT EXIST" 1>&2; \
	    echo "  try \"make release_tarball\"" 1>&2; \
	    false; \
	fi

release_tarball: 
	$(AT) if [ -f releases/dno_$(DNO_VERSION).tgz ]; then \
	    (echo "Release for dno $(DNO_VERSION) already exists."); \
	else \
	    $(FEEDBACK_RAW) Copying tarfile...; \
	    $(MAKE) dno_$(DNO_VERSION).tgz; \
	    cp dno_$(DNO_VERSION).tgz releases; \
	fi


# Local Variables:
# mode: makefile
# End:
