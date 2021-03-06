29100 #include "rundecs.h"
29110     (*  COPYRIGHT 1983 C.H.LINDSEY, UNIVERSITY OF MANCHESTER  *)
29120 (**)
29130 PROCEDURE GARBAGE (ANOBJECT: OBJECTP); EXTERN;
29140 PROCEDURE ERRORR(N :INTEGER); EXTERN;
29150 (**)
29160 (**)
29170 FUNCTION DREFS(REFER: OBJECTP): A68INT;
29180 (*PDEREF*)
29190   VAR PTR: UNDRESSP;
29200     BEGIN WITH REFER^ DO
29210       CASE SORT OF
29220         REF1: DREFS := VALUE;
29230         CREF: DREFS := IPTR^.FIRSTINT;
29240         REFSL1: BEGIN PTR := INCPTR(ANCESTOR^.PVALUE, OFFSET); DREFS := PTR^.FIRSTINT END;
29250         UNDEF: ERRORR(RDEREF);
29260         NILL: ERRORR(RDEREFNIL);
29270       END;
29280     IF FPTST(REFER^) THEN GARBAGE(REFER)
29290     END;
29300 (**)
29310 (**)
29320 (*-01()
29330 FUNCTION DREFS2(REFER: OBJECTP): A68LONG;
29340 (*PDEREF+1*)
29350   VAR PTR: UNDRESSP;
29360     BEGIN WITH REFER^ DO
29370       CASE SORT OF
29380         REF2: DREFS2 := LONGVALUE;
29390         CREF: DREFS2 := IPTR^.FIRSTLONG;
29400         REFSL1: BEGIN PTR := INCPTR(ANCESTOR^.PVALUE, OFFSET); DREFS2 := PTR^.FIRSTLONG END;
29410         UNDEF: ERRORR(RDEREF);
29420         NILL: ERRORR(RDEREFNIL);
29430       END;
29440     IF FPTST(REFER^) THEN GARBAGE(REFER)
29450     END;
29460 (**)
29470 (**)
29480 ()-01*)
29490 (**)
29500 (**)
29510 FUNCTION DREFPTR(REFER: OBJECTP): OBJECTP;
29520 (*PDEREF+2*)
29530   VAR RESULT: OBJECTP;
29540       PTR: UNDRESSP;
29550     BEGIN
29560     WITH REFER^ DO
29570       BEGIN
29580       CASE SORT OF
29590         RECN, REFN: RESULT := PVALUE;
29600         CREF: RESULT := IPTR^.FIRSTPTR;
29610         REFSL1: BEGIN PTR := INCPTR(ANCESTOR^.PVALUE, OFFSET); RESULT := PTR^.FIRSTPTR END;
29620         UNDEF: ERRORR(RDEREF);
29630         NILL: ERRORR(RDEREFNIL);
29640       END;
29650       IF SORT<>CREF THEN WITH RESULT^ DO
29660         BEGIN
29670         FINC;
29680         IF FPTST(REFER^) THEN GARBAGE(REFER);
29690         FDEC
29700         END
29710       ELSE IF FPTST(REFER^) THEN GARBAGE(REFER);
29720       DREFPTR := RESULT;
29730       END
29740     END;
29750 (**)
29760 (**)
29770 (*-02()
29780   BEGIN
29790   END;
29800 ()-02*)
29810 (*+01()
29820 BEGIN (*OF MAIN PROGRAM*)
29830 END  (*OF EVERYTHING*).
29840 ()+01*)
