/*
 * Author: Hans van Eck. 
 */

typedef struct label_list *lblst_p;

struct label_list {
    lblst_p	ll_next;	/* pointer to next label in the list */
    num_p	ll_num;		/* pointer to label definition */
    short	ll_height;	/* the height of the stack at this label */
    char	ll_fallthrough;	/* is the label reached by fallthrough ? */
};

typedef struct label_list lblst_t;

extern lblst_p est_list;
extern int state;
#define	KNOWN		1
#define	NOTREACHED	2
#define NO_STACK_MES	3