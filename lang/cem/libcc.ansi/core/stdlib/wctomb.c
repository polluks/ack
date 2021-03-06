/*
 * (c) copyright 1987 by the Vrije Universiteit, Amsterdam, The Netherlands.
 * See the copyright notice in the ACK home directory, in the file "Copyright".
 */
/* $Id$ */

#include <stdlib.h>
#include <limits.h>

int wctomb(char* s, wchar_t wchar)
{
	if (!s)
		return 0; /* no state dependent codings */

	*s = wchar;
	return 1;
}
