# dno.mk
# Makefile inclusion for dno to enable dno to build the
# bootloader directly.

# Need the board.mcu definition for the next definitions to work.
#
include ../BOARD_INFO

# This makes the boot target run our explicit build target below.
#
BOOT_DEPS := optiboot_atmega328_$(build.mcu).hex

# Burn is also dependent on the same target.
#
BURN_DEPS := optiboot_atmega328_$(build.mcu).hex

# Make the boot target do nothing useful itself.  Its dependencies
# will cause the actual build to be done.
#
BOOT_BUILDER := @echo "Bootloader successfully built."

optiboot_atmega328_$(build.mcu).hex: boot.h optiboot.c pin_defs.h stk500.h
	$(AT) echo Imagine $@ being built here!


$(info LOADING DNO.MK)
