#define RCSID5 "$Header$"

/*
 * Motorola 6809 special routines
 */

branch(opc, exp)
register int	opc;
expr_t		exp;
{
	register int	sm, dist;
	int		saving;

	dist = exp.val - (DOTVAL + 2);
	if (pass == PASS_2 && dist > 0 && !(exp.typ & S_DOT))
		dist -= DOTGAIN;
	sm = fitb(dist);
	if ((exp.typ & ~S_DOT) != DOTTYP)
		sm = 0;
	if (opc == 0x8D || opc == 0x20)
		saving = 1;
	else
		saving = 2;
	if ((sm = small(sm,saving)) == 0) {
		dist--;
		if (opc == 0x8D)	/* bsr */
			opc = 0x17;
		else if (opc == 0x20)	/* bra */
			opc = 0x16;
		else {
			emit1(0x10);
			dist--;
		}
	}
	emit1(opc);
	if (sm == 0) {
#ifdef RELOCATION
		newrelo(exp.typ, RELPC|RELO2|RELBR);
#endif
		emit2(dist);
	} else
		emit1(lowb(dist));
}

regno(r) register r; {
	switch (r) {
	case X:	return 0;
	case Y:	return 0x20;
	case U:	return 0x40;
	case S:	return 0x60;
	}
	return -1;
}

emit1or2(n) {
	if (n & ~0xFF)
		emit1(n >> 8);
	emit1(n);
}

offset(reg, exp, ind)
register int	reg, ind;
expr_t		exp;
{
	if (reg == PC) {
		int	sm, dist;

		dist = exp.val - (DOTVAL + 2);
		if (pass == PASS_2 && dist > 0 && !(exp.typ & S_DOT))
			dist -= DOTGAIN;
		sm = fitb(dist);
		if ((exp.typ & S_TYP) != DOTTYP)
			sm = 0;
		if (small(sm,1)) {
			emit1(0x8C + ind);
			emit1(dist);
		} else {
			emit1(0x8D + ind);
			emit1((dist-1)>>8);
			emit1(dist - 1);
		}
	} else if ((reg = regno(reg)) < 0)
		serror("register error");
	else if ((exp.typ & S_TYP) == S_ABS && exp.val == 0)
		emit1(0x84 + reg + ind);	/* XOP 0, REG == XOP , REG */
	else if (ind == 0 && (exp.typ & S_TYP) == S_ABS &&
		 -16 <= exp.val && exp.val <= 15
		)
		emit1(reg + ind + (exp.val & 037));
	else if ((exp.typ&S_TYP)==S_ABS && -256<=exp.val && exp.val<=255) {
		emit1(0x88 + reg + ind);
		emit1(exp.val);
	} else {
		emit1(0x89 + reg + ind);
#ifdef RELOCATION
		newrelo(exp.typ, RELO2|RELBR);
#endif
		emit2(exp.val);
	}
}
