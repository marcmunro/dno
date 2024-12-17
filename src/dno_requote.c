/**
 *      dno_requote
 *
 *      Copyright (c) 2024 Marc Munro
 *      Author:  Marc Munro
 *	License: GPL-3.0
 *
 * This reads a strangely quoted (your author is baffled by the
 * quoting style used in the Arduino platform.txt files) string from
 * BOARD_INFO, and updates it into a form that should be executable as
 * a shell command.  This mostly means escaping quotes that appear
 * within quotes, but not all of them.  If anyone can make sense of
 * the quoting within platform.txt files, and provide a simple set of
 * rules that are guaranteed to work when running the commands through
 * a shell, then please let the author know.
 *
 * This is implemented in C rather than as a regexp as the C-code tyo
 * do this is very straightforward, and the regexp would not be.
 */ 


#include <stdio.h>
#include <stdbool.h>
#include <ctype.h>

#define ESCAPE '\\'
#define QUOTE '\"'

int main(int argc, char *argv[])
{
    bool in_whitespace = true;  // Start of inout is considered whitespace
    bool in_quotes = false;
    bool escaped = false;
    bool escaping_quotes = false;
    char c;
    
    while ((c = getchar()) != EOF) {
	if (escaped) {
	    escaped = false;
	}
	else if (c == ESCAPE) {
	    escaped = true;
	}
	if (c == QUOTE) {
	    if (in_quotes) {
		if (escaping_quotes) {
		    putchar(ESCAPE);
		    escaping_quotes = false;
		}
		in_quotes = false;
	    }
	    else {
		if (!in_whitespace) {
		    // We are opening a new quote within an argument.
		    // This is where we'll escape the quotes.
		    escaping_quotes = true;
		    putchar(ESCAPE);
		}
		in_quotes = true;
	    }
	}
	else if (isspace(c)) {
	    in_whitespace = true;
	    if ((c == '\r') || (c == '\n')) {
		// Newline: reset our state variables in case quotes
		// were not matched in the input.
		escaped = false;
		escaping_quotes = false;
	    }
	}
	else {
	    in_whitespace = false;
	}
        putchar(c);
    }
}
