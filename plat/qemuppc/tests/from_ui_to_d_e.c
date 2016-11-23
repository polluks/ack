#include "test.h"

/* Constants in globals to defeat constant folding. */
unsigned int one_u = 1;
unsigned int zero_u = 0;
unsigned int big_u = 0xffffffff;

/* Bypasses the CRT, so there's no stdio or BSS initialisation. */
void _m_a_i_n(void)
{
    ASSERT((double)zero_u == 0.0);
    ASSERT((double)one_u == 1.0);
    ASSERT((double)big_u == 4294967295.0);

    finished();
}