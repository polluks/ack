93000              (*    COPYRIGHT 1983 C.H.LINDSEY,  UNIVERSITY OF MANCHESTER  *)
93010 (*+82()
93020 (**)
93030                 (*PARSING*)
93040                 (***********)
93050 (**)
93060 FUNCTION ACTIONROUTINE(ARTN: RTNTYPE): BOOLEAN;
93070   LABEL 9;
93080   VAR STB: PSTB;
93090       M: MODE;
93100       OPL, OPR: PSTB;
93110       PREVLX: LXIOTYPE; INPT: PLEX;
93120       HEAD, PTR, PTR1: PLEXQ;
93130       LEV: INTEGER;
93140       PL, PR, I: INTEGER;
93150   PROCEDURE FORCEMATCH(LEX: PLEX);
93160   (*FORCES SRPLSTK[PLSTKP]=LEX*)
93170     LABEL 100;
93180     VAR TSTKP: 0..SRPLSTKSIZE;
93190         SLEX: PLEX;
93200       BEGIN TSTKP := PLSTKP;
93210  100: SLEX := SRPLSTK[TSTKP];
93220       IF SLEX^.LXV.LXCLASS2=1 THEN (*.FOR, ..., .WHILE*) SLEX := LEXWHILE;
93230       WITH SLEX^.LXV DO
93240         IF (LXCLASS2<>1) AND (LXCLASS2<>2)  AND (LXIO<>LXIOSTART) OR (SLEX<>LEX) AND (TSTKP=PLSTKP) THEN
93250           BEGIN TSTKP := TSTKP+1; GOTO 100 END;
93260       IF SLEX=LEX THEN (*LEAVE ALONE OR POP*) PLSTKP := TSTKP
93270       ELSE (*PUSH*) BEGIN PLSTKP := PLSTKP-1; SRPLSTK[PLSTKP] := LEX END
93280       END; (*OF FORCEMATCH*)
93290     BEGIN
93300 (*+21()
93310     MONITORSEMANTIC(ARTN);
93320 ()+21*)
93330     CASE ARTN OF
93340 (**)
93350       1: (*AR1*)
93360       (*FUNCTION: INVOKED AFTER OPERAND SURROUNDED BY DYADIC-OPERATORS.
93370           DECIDES WHICH OPERATORS TAKE PRECEDENCE.
93380           TRUE IFF OPERATOR TO LEFT OF OPERAND TAKES PRECEDENCE;
93390           I.E. LEFT PRIORITY IS GREATER THAN OR EQUAL TO RIGHT PRIORITY.
93400       *)
93410         BEGIN
93420         OPL := SRPLSTK[PLSTKP+1]^.LXV.LXPSTB; OPR := INP^.LXV.LXPSTB;
93430       IF OPL<>NIL THEN PL := OPL^.STDYPRIO ELSE PL := 10;
93440       IF OPR<>NIL THEN PR := OPR^.STDYPRIO ELSE PR := 10;
93450       IF PL>=PR THEN
93460           BEGIN
93470           IF (ERRS-SEMERRS)=0 THEN SEMANTICROUTINE(79) (*SR45*);
93480           ACTIONROUTINE := TRUE
93490           END
93500         ELSE ACTIONROUTINE := FALSE
93510         END;
93520 (**)
93530       2: (*AR2*)
93540       (*INVOKED: AFTER OPEN FOLLOWED BY HEAD SYMBOL OF A DECLARER.
93550         FUNCTION: DECIDE WHETHER THIS IS START OF FORMAL-DECLARATIVE OF A
93560             ROUTINE-TEXT OR START OF A CLOSED-CLAUSE
93562         VALUE: TRUE IFF ROUTINE-TEXT*)
93570         BEGIN
93580         LEV := 0; PREVLX := LXIOERROR; NEW(HEAD); PTR := HEAD;
93590         WHILE TRUE DO
93600           BEGIN
93610           INPT := PARSIN; PTR^.DATA1 := INPT;
93620           WITH INPT^.LXV DO
93630             IF LXIO<LXIOBUS THEN (*NOT TAG OR PART OF A FORMAL-DECLARER*)
93640               BEGIN ACTIONROUTINE := FALSE; GOTO 9 END
93650             ELSE IF LXIO=LXIOOPEN THEN
93670               LEV := LEV+1
93700             ELSE IF LXIO=LXIOCLOSE THEN
93710               IF LEV<>0 THEN LEV := LEV-1
93720               ELSE
93730                 BEGIN ACTIONROUTINE := TRUE; GOTO 9 END;
93740           PREVLX := INPT^.LXV.LXIO;
93750           NEW(PTR1); PTR^.LINK := PTR1; PTR := PTR1;
93760           END;
93770      9: PTR^.LINK := PLINPQ;
93780         PLINPQ := HEAD
93790         END;
93800 (**)
93810 (**)
93820 (**)
93830       3: (*AR3A*)
93840       (*FUNCTION: INVOKED AFTER APPLIED-MODE-INDICATION.
93850           DETERMINES IF ASCRIBED MODE IS NON-ROWED NON-VOID MODE.
93860           TRUE IFF MODE IS NON-ROWED NON-VOID.
93870       *)
93880           BEGIN
93890           STB := APPMI(SRPLSTK[PLSTKP]);
93900         WITH STB^ DO IF STBLKTYP>STBDEFOP THEN STB := STDEFPTR;
93910           SRSEMP := SRSEMP+1; SRSTK[SRSEMP].MD := STB^.STMODE;
93920           IF STB^.STMODE=MDVOID THEN ACTIONROUTINE := FALSE
93930           ELSE IF STB^.STOFFSET=0 THEN ACTIONROUTINE := TRUE
93940           ELSE ACTIONROUTINE := FALSE
93950           END;
93960 (**)
93970       4: (*AR3B*)
93980       (*FUNCTION: INVOKED AFTER ROWED OR VOID APPLIED-MODE-INDICATION.
93990           DETERMINES IF ASCRIBED MODE IS VOID.
94000           TRUE IFF MODE IS VOID.
94010       *)
94020         IF SRSTK[SRSEMP].MD=MDVOID THEN ACTIONROUTINE := TRUE
94030         ELSE ACTIONROUTINE := FALSE;
94040 (**)
94050       5: (*AR5*)
94060       (*INVOKED: AFTER ENQUIRY-CLAUSE OF BRIEF-CHOICE-CLAUSE.
94070         FUNCTION: DECIDE MORE SPECIFICALLY WHAT KIND OF CLAUSE THE BRIEF CLAUSE REPRESENTS.
94080           THE LEGAL POSSIBILITIES ARE CONDITIONAL-CLAUSE AND CASE-CLAUSE.
94090           A THIRD POSSIBILITY IS THAT THE SERIAL-CLAUSE PRESUMED TO BE AN ENQUIRY-CLAUSE
94100           IN FACT DOES NOT YIELD THE REQUIRED MODE AND HENCE IS IN ERROR.
94110         VALUE: TRUE IFF CONDITIONAL-CLAUSE OR ERROR.
94120       *)
94130         BEGIN
94140         IF (ERRS-SEMERRS)=0 THEN M := MEEK ELSE M := MDERROR;
94150         IF M=MDINT THEN ACTIONROUTINE := FALSE
94160         ELSE IF M=MDBOOL THEN ACTIONROUTINE := TRUE
94170         ELSE BEGIN MODERR(M, ESE+37); ACTIONROUTINE := TRUE END
94180         END;
94190 (**)
94200       6: (*AR6*)
94210       (*INVOKED: AFTER MODE-DEFINITION AND COMMA FOLLOWED BY MODE-INDICATION.
94220         FUNCTION: DETERMINE IF TAB IS START OF ANOTHER MODE-DEFINITION OR START OF
94230           VARIABLE- OR IDENTITY-DEFINITION-LIST.
94240         VALUE: TRUE IFF TAB IS START OF MODE-DEFINITION.
94250       *)
94260         BEGIN
94270         INPT := PARSIN;
94280         PTR := PLINPQ; NEW(PLINPQ);
94290         WITH PLINPQ^ DO
94300           BEGIN LINK := PTR; DATA1 := INPT END;
94310         ACTIONROUTINE := INPT^.LXV.LXIO = LXIOEQUAL
94320         END;
94330 (**)
94340       7: (*AR7*)
94350       (*TRUE IFF SEMANTIC CHECKING IS OFF*)
94360         ACTIONROUTINE := ERRS>SEMERRS;
94370 (**)
94380       8: (*ERRX*)
94390       (*INVOKED AFTER ERROR CORRECTING PRODUCTIONS HAVE FLUSHED THE SYNTAX STACK AND
94400           INPUT STREAM TO A POINT WHERE IT IS DEEMED POSSIBLE TO CONTINUE NORMAL PARSING.
94410       *)
94420         BEGIN
94430         FOR I := ERRPTR+1 TO ERRLXPTR DO ERRBUF[I] := ERRCHAR;
94440         ERRPTR := ERRLXPTR;
94450         ERRCHAR := ' ';
94460         (*FIXUP BRACKET MISMATCHES*)
94470         WITH INP^.LXV DO
94480           IF (LXIO=LXIOOUSE) OR (LXIO=LXIOOUT) OR (LXIO=LXIOESAC) THEN FORCEMATCH(LEXCASE)
94490           ELSE IF LXIO IN [LXIOELIF,LXIOELSE,LXIOFI] THEN FORCEMATCH(LEXIF)
94500           ELSE IF (LXIO IN [LXIOCSTICK,LXIOAGAIN]) OR (LXIO=LXIOCSTICK) THEN
94510             (*LXIONIL AND ABOVE ARE NOT ACCEPTABLE SET ELEMENTS IN CDC PASCAL*)
94520             IF SRPLSTK[PLSTKP]^.LXV.LXIO<>LXIOBRINPT THEN FORCEMATCH(LEXBRTHPT)
94530             ELSE (*NO ACTION*)
94540           ELSE IF LXIO=LXIOCLOSE THEN FORCEMATCH(LEXOPEN)
94550           ELSE IF LXIO=LXIOEND THEN FORCEMATCH(LEXBEGIN)
94560           ELSE IF LXIO=LXIOOD THEN FORCEMATCH(LEXWHILE);
94570         ACTIONROUTINE := TRUE
94580         END;
94590 (**)
94622       9: (*INVOKED: AFTER A PRIMARY FOLLOWED BY OPEN.
94624            FUNCTION: DETERMINES WHETHER IT IS START OF CALL OR SLICE.
94626            VALUE: TRUE IFF CALL*)
94628         IF (ERRS-SEMERRS)=0 THEN
94630           BEGIN
94632           M := COMEEK(BALANCE(STRMEEK));
94634           IF M^.MDV.MDID IN [MDIDPASC,MDIDPROC] THEN
94635             BEGIN SEMANTICROUTINE(76); ACTIONROUTINE := TRUE END
94636           ELSE ACTIONROUTINE := FALSE;
94637           END
94638         ELSE ACTIONROUTINE := FALSE;
94640       END;
94642     END;
94650 (**)
94660 (**)
94670 PROCEDURE INITPR;
94680 (*FUNCTION: PERFORMS PER-COMPILATION INITIALIZATION REQUIRED BY
94690   THE PARSING ROUTINES.
94700 *)
94710     BEGIN
94720     PLINPQ := NIL;
94730     PLPTR := 1;
94740     SRPLSTK[SRPLSTKSIZE] := LEXSTOP;
94750     SRPLSTK[SRPLSTKSIZE-1] := LEXSTOP;
94760     PLSTKP := SRPLSTKSIZE-1;
94770     ENDOFPROG := FALSE;
94780     INP := LEXSTART
94790     END;
94800 (**)
94810 (**)
94820 PROCEDURE PARSER;
94830 (*FUNCTION: THIS IS THE PRODUCTION LANGUAGE PARSER. IT PERFORMS THE
94840     SYNTAX ANALYSIS BY INTERPRETING PRODUCTION RULES FOR THE ALGOL 68 SUBLANGUAGE.
94850 *)
94860   VAR MATCH: BOOLEAN;
94870   STK: PLEX;
94880   I: INTEGER;
94890   MATCHES, UNMATCHES: INTEGER;
94900   (*HISTO: ARRAY [1..PRODLEN] OF INTEGER;*)
94910     BEGIN
94920 (*+22()   PARSCLK := PARSCLK-CLOCK;   ()+22*)
94930     MATCHES := 0; UNMATCHES := 0;
94940     WHILE NOT ENDOFPROG DO
94950      BEGIN
94960       WITH PRODTBL[PLPTR] DO
94970         BEGIN
94980         (*HISTO[PLPTR] := HISTO[PLPTR]+1;*)
94990         MATCH := TRUE;
95000         IF PRSTKA<3 THEN   (*I.E. NOT ANY*)
95010           BEGIN
95020           STK := SRPLSTK[PLSTKP+PRSTKA];
95030           CASE PRSTKC OF
95040             S:  MATCH := SYLXV.LX1IO  = STK^.LXV.LXIO;
95050             C0: MATCH := SYLXV.LX1CL0 = STK^.LXV.LXCLASS0;
95060             C1: MATCH := SYLXV.LX1CL1 = STK^.LXV.LXCLASS1;
95070             C2: MATCH := SYLXV.LX1CL2 = STK^.LXV.LXCLASS2
95080             END
95090           END;
95100         IF MATCH THEN
95110           CASE PRINPC OF
95120             A:  (*NO ACTION*);
95130             S:  MATCH := SYLXV.LX2IO  = INP^.LXV.LXIO;
95140             C0: MATCH := SYLXV.LX2CL0 = INP^.LXV.LXCLASS0;
95150             C1: MATCH := SYLXV.LX2CL1 = INP^.LXV.LXCLASS1;
95160             C2: MATCH := SYLXV.LX2CL2 = INP^.LXV.LXCLASS2;
95170            SSA: MATCH := SYLXV.LX2IO = SRPLSTK[PLSTKP+1]^.LXV.LXIO
95180             END;
95190         IF MATCH THEN
95200           IF RTN>FINISH THEN
95210             IF ((ERRS-SEMERRS)=0) OR (RTN>=119 (*SR81*) ) THEN
95220               BEGIN
95230               (*PARSCLKS := PARSCLKS+1; SEMCLK := SEMCLK-CLOCK;*)
95240               SEMANTICROUTINE(RTN);
95250               (*SEMCLK := SEMCLK+CLOCK; SEMCLKS := SEMCLKS+1*)
95260               END
95270             ELSE (*NOTHING*)
95280           ELSE IF RTN<>DUMMY THEN
95290             MATCH := ACTIONROUTINE(RTN);
95300         IF MATCH THEN
95310           BEGIN
95320           MATCHES := MATCHES+1;
95330                       (*
95340                       WRITELN(PLPTR:3, PLSTKP:3, ERRLXPTR:3);
95350                       *)
95360           PLSTKP := PLSTKP+PRPOP;
95370           IF PRPUSH<>LXIODUMMY THEN
95380             BEGIN PLSTKP := PLSTKP-1; SRPLSTK[PLSTKP] := PUSHTBL[PRPUSH] END;
95390           IF PRSKIP THEN
95400             BEGIN IF LEXLINE <> PREVLINE THEN CGFLINE;
95410             INP := PARSIN END;
95420           FOR I := 1 TO PRSCAN DO
95430             BEGIN PLSTKP := PLSTKP-1; SRPLSTK[PLSTKP] := INP;
95440             IF LEXLINE <> PREVLINE THEN CGFLINE;
95450             INP := PARSIN END;
95460           PLPTR := SEXIT
95470           END
95480         ELSE
95490           BEGIN PLPTR := FEXIT; UNMATCHES := UNMATCHES+1 END
95500         END
95510      END
95520 (*+22()   ; PARSCLK := PARSCLK+CLOCK; PARSCLKS := PARSCLKS+1;   ()+22*)
95530     (*WRITELN('MATCHES', MATCHES, ' UNMATCHES', UNMATCHES);*)
95540     (*FOR I := 1 TO PRODLEN DO WRITELN(REMARKS, I, HISTO[I]);*)
95550     END;
95560 (**)
95570 ()+82*)
95580 (**)
95590 (**)
95592 PROCEDURE ABORT; EXTERN;
95600 (**)
95610 (*+80()
95620 (**)
95630 (*+01()
95640 FUNCTION PFL: INTEGER;
95650 (*OBTAIN FIELD LENGTH FROM GLOBAL P.FL*)
95660 EXTERN;
95670 (**)
95680 (**)
95690 FUNCTION PFREE: PINTEGER;
95700 (*OBTAIN ADDRESS OF GLOBAL P.FREE*)
95710 EXTERN;
95720 (**)
95730 (**)
95740 (*$T-+)
95750 (*+25()   (*$T-+)   ()+25*)
95760 FUNCTION RESTORE(VAR START: INTEGER): INTEGER;
95770 (*RESTORES STACK AND HEAP FROM FILE A68INIT.
95780         START IS FIRST VARIABLE ON STACK TO BE RESTORED*)
95790   CONST TWO30=10000000000B;
95800   VAR STACKSTART, STACKLENGTH, HEAPLENGTH: INTEGER;
95810       FRIG: RECORD CASE INTEGER OF
95820                    1:(INT: INTEGER); 2:(POINT: PINTEGER) END;
95830       D: DUMPOBJ;
95840       MASKM,MASKL: INTEGER;
95850       I: INTEGER;
95860     BEGIN
95870     STACKSTART := GETX(0);
95880     RESET(A68INIT);
95890     IF EOF(A68INIT) THEN BEGIN WRITELN(' A68INIT NOT AVAILABLE, OR WRONG RFL'); RESTORE := 1 END
95900     ELSE
95910       BEGIN
95920       READ(A68INIT, D.INT, D.MASK); STACKLENGTH := D.INT; HEAPLENGTH := D.MASK;
95930       FIELDLENGTH := PFL-LOADMARGIN;  (*BECAUSE THE LOADER CANNOT LOAD RIGHT UP TO THE FIELDLENGTH*)
95940       HEAPSTART := FIELDLENGTH-HEAPLENGTH;
95950       FOR I := STACKSTART TO STACKSTART+STACKLENGTH-1 DO
95960         BEGIN
95970         READ(A68INIT, D.INT, D.MASK);
95980           (*NOW WE HAVE TO MULTIPLY D.MASK BY HEAPSTART*)
95990         MASKM := D.MASK DIV TWO30; MASKL := D.MASK-MASKM*TWO30;
96000         MASKM := MASKM*HEAPSTART; MASKL := MASKL*HEAPSTART;
96010         D.INT := D.INT+MASKM*TWO30+MASKL;
96020         FRIG.INT := I; FRIG.POINT^ := D.INT
96030         END;
96040       FOR I := HEAPSTART TO HEAPSTART+HEAPLENGTH-1 DO
96050         BEGIN
96060         READ(A68INIT, D.INT, D.MASK);
96070         MASKM := D.MASK DIV TWO30; MASKL := D.MASK-MASKM*TWO30;
96080         MASKM := MASKM*HEAPSTART; MASKL := MASKL*HEAPSTART;
96090         D.INT := D.INT+MASKM*TWO30+MASKL;
96100         FRIG.INT := I; FRIG.POINT^ := D.INT
96110         END;
96120       FRIG.POINT := PFREE; FRIG.POINT^ := START;
96130       RESTORE := 0
96140       END
96150     END;
96160 (**)
96170 (**)
96190 PROCEDURE ACLOSE(VAR F: FYL); EXTERN;
96200 (**)
96210 (**)
96220 FUNCTION INITINIT: INTEGER;
96230   VAR WORD101: RECORD CASE INTEGER OF
96240           1: (INT: INTEGER);
96250           2: (REC: PACKED RECORD
96260                   WCS: 0..777777B;
96270                   FILLER: 0..77777777777777B
96280                   END)
96290           END;
96300       HWORD: RECORD CASE INTEGER OF
96310           1: (INT: INTEGER);
96320           2: (REC: PACKED RECORD
96330                   TABLE: 0..7777B; WC: 0..7777B;
96340                   FILLER: 0..777777777777B
96350                   END)
96360           END;
96370       I, J: INTEGER;
96380       P: PINTEGER;
96390     BEGIN
96400     IF DUMPED=43 THEN (*WE ARE OBEYING THE DUMPED VERSION OF THE COMPILER*)
96410       BEGIN
96420       IF PFL-LOADMARGIN-ABSMARGIN>FIELDLENGTH THEN (*FIELDLENGTH HAS CHANGED SINCE DUMP*)
96430         INITINIT := RESTORE(FIRSTSTACK)
96440       ELSE INITINIT := 0;
96450       SETB(4, HEAPSTART)
96460       END
96470     ELSE
96480       BEGIN (*A DUMP MUST BE MADE*)
96490       DUMPED := 43;
96500       INITINIT := RESTORE(FIRSTSTACK);
96510       REWRITE(LGO);
96520       GETSEG(A68INIT);  (*START OF A68SB*)
96530       HWORD.INT := A68INIT^;
96540       WHILE HWORD.REC.TABLE<>5400B DO
96550         BEGIN GET(A68INIT);
96560         WRITE(LGO, HWORD.INT);
96570         FOR I := 1 TO HWORD.REC.WC DO (*COPY PRFX/LDSET TABLE*)
96580           BEGIN READ(A68INIT, J); WRITE(LGO, J) END;
96590         HWORD.INT := A68INIT^;
96600         END;
96610       WITH WORD101 DO (*MODIFY WORD 1 OF EACPM TABLE*)
96620         BEGIN
96630         P := ASPTR(101B);
96640         INT := FIELDLENGTH;
96650         REC.WCS := FIELDLENGTH-101B-LOADMARGIN;
96660         P^ := INT;
96670         P := ASPTR(104B);
96680         P^ := FIELDLENGTH
96690         END;
96700       P := ASPTR(100B);
96710       FOR I := 0 TO 8 DO (*WRITE EACPM TABLE FROM CORE*)
96720         BEGIN
96730         WRITE(LGO, P^);
96740         P := ASPTR(ORD(P)+1);
96750         GET(A68INIT)
96760         END;
96770       WHILE NOT EOS(A68INIT) DO (*COPY PROGRAM*)
96780         BEGIN
96790         READ(A68INIT, J); WRITE(LGO, J);
96800         P := ASPTR(ORD(P)+1)
96810         END;
96820       WHILE ORD(P)<FIELDLENGTH DO (*WRITE STACK-HEAP*)
96830         BEGIN
96840         WRITE(LGO, P^);
96850         P := ASPTR(ORD(P)+1)
96860         END;
96870       ABORT
96880       END
96890     END;
96900 (**)
96910 (**)
96920 PROCEDURE LOADGO(VAR LGO: LOADFILE); EXTERN;
96930 (**)
96940 (**)
96950 (*$E++)
96960 PROCEDURE PASCPMD(VAR A: INTEGER; J,K,L,M: INTEGER; N: BOOLEAN;
96970                   VAR F: TEXT; VAR MSG: MESS);
96980 (*TO CATCH NOS- AND PASCAL-DETECTED ERRORS*)
96990   VAR I: INTEGER;
97000     BEGIN
97010     WRITELN(F);
97020     I := 1;
97030     REPEAT
97040       WRITE(F, MSG[I]); I := I+1
97050     UNTIL ORD(MSG[I])=0;
97060     WRITELN(F);
97070     ABORT
97080     END;
97090   ()+01*)
97100 (**)
97110 (**)
97120 (**)
97130 ()+80*)
97140 (**)
97150 (*-01() (*-03() (*-04()
97160 FUNCTION GETADDRESS(VAR VARIABLE:INTEGER): ADDRINT; EXTERN;
97170 (**)
97180 PROCEDURE RESTORE(VAR START,FINISH: INTEGER);
97190   VAR  STACKSTART,STACKEND,GLOBALLENGTH,HEAPLENGTH,
97191         HEAPSTART(*+19(),LENGTH,POINTER()+19*): ADDRINT;
97195         I:INTEGER;
97200         P: PINTEGER;
97210         FRIG: RECORD CASE SEVERAL OF
97220                        1: (INT: ADDRINT);
97221                        2: (POINT: PINTEGER);
97222                        3: (PLEXP: PLEX);
97223                (*+19() 4: (APOINT: ^ADDRINT); ()+19*)
97230           (*-19()4,()-19*)5,6,7,8,9,10: ()
97240                     END;
97250        D: RECORD INT,MASK: INTEGER END;
97270     BEGIN
97280 (*+05() OPENLOADFILE(A68INIT, 4, FALSE); ()+05*)
97285 (*+02() RESET(A68INIT); ()+02*)
97290     STACKSTART := GETADDRESS(START);
97300     IF NOT EOF(A68INIT) THEN
97310       BEGIN
97320       READ(A68INIT,GLOBALLENGTH,HEAPLENGTH);
97330       ENEW(FRIG.PLEXP, HEAPLENGTH);
97340       HEAPSTART := FRIG.INT;
97350       FRIG.INT := STACKSTART;
97355 (*-19()
97360       FOR I := 1 TO GLOBALLENGTH DIV SZWORD DO
97370         BEGIN
97380         READ(A68INIT,D.INT,D.MASK);
97390         IF D.MASK=SZREAL THEN (*D.INT IS A POINTER OFFSET FROM HEAPSTART*)
97400            D.INT := D.INT+HEAPSTART;
97410         FRIG.POINT^ := D.INT;
97420         FRIG.INT := FRIG.INT+SZWORD;
97430         END;
97440       FRIG.INT := HEAPSTART;
97450       FOR I := 1 TO HEAPLENGTH DIV SZWORD DO
97460         BEGIN
97462          READ(A68INIT,D.INT,D.MASK);
97464          IF D.MASK=SZREAL THEN
97466            D.INT := D.INT+HEAPSTART;
97468          FRIG.POINT^ := D.INT;
97470          FRIG.INT := FRIG.INT+SZWORD
97472          END
97474 ()-19*)
97479 (*+19()
97480          LENGTH:=GLOBALLENGTH DIV SZWORD;
97482          I:=1;
97484          WHILE I<=LENGTH DO
97486          BEGIN
97488             READ(A68INIT,D.MASK);
97490             IF D.MASK=SZADDR+SZWORD THEN (*IT IS A POINTER*)
97492             BEGIN
97494                READ(A68INIT,POINTER);
97496                POINTER:=POINTER+HEAPSTART;
97498                FRIG.APOINT^:=POINTER;
97500                FRIG.INT:=FRIG.INT+SZWORD+SZWORD; (*POINTER IS 2 WORDS *)
97502                I:=I+2
97504             END
97506             ELSE
97508             BEGIN
97510               READ(A68INIT,D.INT);
97511               FRIG.POINT^:=D.INT;
97512               FRIG.INT:=FRIG.INT+SZWORD;
97513               I:=I+1
97514             END
97515          END;
97516          LENGTH:=HEAPLENGTH DIV SZWORD;
97517          FRIG.INT:=HEAPSTART;
97518          I:=1;
97519          WHILE I<=LENGTH DO
97520          BEGIN
97521             READ(A68INIT,D.MASK);
97522             IF D.MASK=SZADDR+SZWORD THEN (*IT IS A POINTER*)
97523             BEGIN
97524                READ(A68INIT,POINTER);
97525                POINTER:=POINTER+HEAPSTART;
97526                FRIG.APOINT^:=POINTER;
97527                FRIG.INT:=FRIG.INT+SZWORD+SZWORD; (*POINTER IS 2 WORDS *)
97528                I:=I+2
97529             END
97530             ELSE
97531             BEGIN
97532               READ(A68INIT,D.INT);
97533               FRIG.POINT^:=D.INT;
97534               FRIG.INT:=FRIG.INT+SZWORD;
97535               I:=I+1
97536             END
97537          END
97538 ()+19*)
97539        END
97540     END;
97550 ()-04*) ()-03*) ()-01*)
97560 (**)
97570 (*+82()
97580 (**)
97590                 (*THE COMPILER*)
97600                 (**************)
97610 (**)
97630 PROCEDURE ALGOL68;
97640     BEGIN
97650 (*+01()
97660     CPUCLK := -CLOCK;
97670 (*+22() CPUCLK := -CLOCK; PARSCLK := 0; LXCLOCK := 0; SEMCLK := 0; EMITCLK := 0;
97680     CPUCLKS := 0; PARSCLKS := 0; LXCLOCKS := 0; SEMCLKS := 0; EMITCLKS := 0; ()+22*)
97690     WARNS := INITINIT;
97700  ()+01*)
97710  (*+25()   WARNS := INITINIT;  ()+25*)
97720     ERRS := 0; SEMERRS := 0;
97730 (*+03()
97740     CLOSE(SOURCDECS);
97750     CLOSE(LSTFILE);
97760     CLOSE(OUTPUT);
97770     RESTARTHERE;
97780     CPUTIME(CPUCLK);
97790 ()+03*)
97800 (*-01() (*-03() (*-04() (*-25() RESTORE(FIRSTSTACK,LASTSTACK); ()-25*) ()-04*) ()-03*) ()-01*)
97810     INITIO;
97820     INITLX;
97830     INITPR;
97840     INITSR;
97850 (*+01()
97860     SETPARAM('          ', 0);  (*FOR DEFAULT GO*)
97870  ()+01*)
97880     PARSER;
97890 (*+01()   (*+22() EMITCLK := EMITCLK-EMITCLKS DIV 6;
97900     SEMCLK := SEMCLK-(SEMCLKS+EMITCLKS) DIV 6;
97910     LXCLOCK := LXCLOCK-LXCLOCKS DIV 6;
97920     PARSCLK := PARSCLK-(PARSCLKS+LXCLOCKS+SEMCLKS+EMITCLKS) DIV 6;
97930     CPUCLK := CPUCLK-(PARSCLKS+LXCLOCKS+SEMCLKS+EMITCLKS) DIV 6;
97940     WRITELN(' CPU', (CPUCLK+CLOCK)/1000:6:3,
97950             ' PAR', (PARSCLK-LXCLOCK-SEMCLK)/1000:6:3,
97960             ' LEX', LXCLOCK/1000:6:3,
97970             ' SEM', (SEMCLK-EMITCLK)/1000:6:3,
97980             ' EMIT', EMITCLK/1000:6:3); ()+22*)  ()+01*)
97990 (*+01()
98000     IF LSTPAGE<>0 THEN
98010       IF ONLINE THEN WRITELN(LSTFILE, ' ', 'CPU', (CPUCLK+CLOCK)/1000:6:3)
98020       ELSE WRITELN(' ', 'CPU', (CPUCLK+CLOCK)/1000:6:3);
98030     IF ERRS<>0 THEN BEGIN MESSAGE('BAD PROGRAM - ABORTED'); ACLOSE(OUTPUT); ABORT END
98040     ELSE IF PRGGO IN PRAGFLGS THEN
98050       BEGIN
98060       PUTSEG(LGO);
98070       IF ONLINE AND (LSTPAGE<>0) THEN ACLOSE(LSTFILE);
98080       IF (WARNS<>0) OR NOT ONLINE AND (LSTPAGE<>0) THEN ACLOSE(OUTPUT);
98090       LOADGO(LGO)
98100       END
98110     ELSE MESSAGE('NO ERRORS');
98120 ()+01*)
98130 (*+03()
98140     CPUTIME(CPUCLK);
98150     IF LSTPAGE<>0 THEN
98160       IF ONLINE THEN WRITELN(LSTFILE, ' ', 'CPU', CPUCLK:4, 'SECS')
98170       ELSE WRITELN(' ', 'CPU', CPUCLK:4, ' SECS');
98180     IF ERRS<>0 THEN WRITELN(' ', 'ERRORS DETECTED')
98190                ELSE WRITELN(' ', 'NO ERRORS');
98200     CLOSE(SOURCDECS);
98210     CLOSE(LSTFILE);
98220     CLOSE(OUTPUT);
98230 ()+03*)
98232 (*+05()
98234     IF ERRS<>0 THEN BEGIN WRITELN(ERROR); WRITELN(ERROR, 'BAD PROGRAM - ABORTED'); ABORT END;
98236 ()+05*)
98237 (*+02()
98238	  IF ERRS<>0 THEN BEGIN WRITELN; WRITELN('BAD PROGRAM - ABORTED'); ABORT END;
98239 ()+02*)
98240     END;
98260 (**)
98270 (**)
98280 (*+01()   (*$P++) (*SO THAT IT KNOWS ABOUT PASCPMD*)   ()+01*)
98290 (*+04() PROCEDURE S1; ()+04*)
98300 (*+25() (*$P++) ()+25*)
98310 (*-03()(*+71()
98320 BEGIN
98330 ALGOL68
98340 (*+01()   (*-31()   (*$P-+)   ()-31*)   ()+01*)
98350 (*+25()   (*-31()   (*$P-+)   ()-31*)   ()+25*)
98360 END (*+01()   (*$G-+)   ()+01*)(*+25()  (*$G-+)   ()+25*).
98370 ()+71*)()-03*)
98380 ()+82*)
