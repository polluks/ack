# $Header$

#PARAMS		do not remove this line!

SRC_DIR = $(SRC_HOME)/util/cpp

MODULES=$(TARGET_HOME)/modules
UMODULES=$(UTIL_HOME)/modules
MODULESLIB=$(MODULES)/lib
UMODULESLIB=$(UMODULES)/lib
BIN=$(TARGET_HOME)/lib.bin
MANDIR=$(TARGET_HOME)/man

# Libraries
SYSLIB = $(MODULESLIB)/libsystem.$(LIBSUF)
STRLIB = $(MODULESLIB)/libstring.$(LIBSUF)
PRTLIB = $(MODULESLIB)/libprint.$(LIBSUF)
ALLOCLIB = $(MODULESLIB)/liballoc.$(LIBSUF)
ASSERTLIB = $(MODULESLIB)/libassert.$(LIBSUF)
MALLOC = $(MODULESLIB)/malloc.$(SUF)
LIBS = $(PRTLIB) $(STRLIB) $(ALLOCLIB) $(MALLOC) $(ASSERTLIB) $(SYSLIB)
LINTLIBS = \
	$(UMODULESLIB)/$(LINTPREF)print.$(LINTSUF) \
	$(UMODULESLIB)/$(LINTPREF)string.$(LINTSUF) \
	$(UMODULESLIB)/$(LINTPREF)alloc.$(LINTSUF) \
	$(UMODULESLIB)/$(LINTPREF)assert.$(LINTSUF) \
	$(UMODULESLIB)/$(LINTPREF)system.$(LINTSUF)
INCLUDES = -I$(MODULES)/h -I$(MODULES)/pkg -I. -I$(SRC_DIR)

CFLAGS = $(INCLUDES) $(COPTIONS)
LDFLAGS = $(LDOPTIONS)
LINTFLAGS = $(INCLUDES) $(LINTOPTIONS)

# Where to install the preprocessor
CEMPP = $(BIN)/cpp

# Grammar files and their objects
LSRC =	tokenfile.g $(SRC_DIR)/expression.g
LCSRC = tokenfile.c expression.c Lpars.c
LOBJ =	tokenfile.$(SUF) expression.$(SUF) Lpars.$(SUF)

# Objects of hand-written C files
CSRC =	$(SRC_DIR)/LLlex.c $(SRC_DIR)/LLmessage.c $(SRC_DIR)/ch7bin.c  \
	$(SRC_DIR)/ch7mon.c $(SRC_DIR)/domacro.c $(SRC_DIR)/error.c \
	$(SRC_DIR)/idf.c $(SRC_DIR)/init.c $(SRC_DIR)/input.c \
	$(SRC_DIR)/main.c $(SRC_DIR)/options.c $(SRC_DIR)/Version.c \
	$(SRC_DIR)/preprocess.c $(SRC_DIR)/replace.c $(SRC_DIR)/scan.c \
	$(SRC_DIR)/skip.c $(SRC_DIR)/tokenname.c $(SRC_DIR)/next.c \
	$(SRC_DIR)/expr.c
COBJ =	LLlex.$(SUF) LLmessage.$(SUF) ch7bin.$(SUF) ch7mon.$(SUF) \
	domacro.$(SUF) error.$(SUF) idf.$(SUF) init.$(SUF) input.$(SUF) \
	main.$(SUF) options.$(SUF) Version.$(SUF) \
	preprocess.$(SUF) replace.$(SUF) scan.$(SUF) skip.$(SUF) \
	tokenname.$(SUF) next.$(SUF) expr.$(SUF)

PRFILES = $(SRC_DIR)/proto.make $(SRC_DIR)/Parameters \
	$(SRC_DIR)/make.hfiles $(SRC_DIR)/make.tokcase $(SRC_DIR)/make.tokfile \
	$(SRC_DIR)/LLlex.h $(SRC_DIR)/bits.h $(SRC_DIR)/file_info.h \
	$(SRC_DIR)/idf.h $(SRC_DIR)/input.h $(SRC_DIR)/interface.h \
	$(SRC_DIR)/macro.h \
	$(SRC_DIR)/class.h $(SRC_DIR)/char.tab $(SRC_DIR)/expression.g $(CSRC)

# Objects of other generated C files
GOBJ =	char.$(SUF) symbol2str.$(SUF)

# generated source files
GSRC =	char.c symbol2str.c

# .h files generated by `make hfiles'; PLEASE KEEP THIS UP-TO-DATE!
GHSRC =	errout.h idfsize.h ifdepth.h lapbuf.h \
	nparams.h numsize.h obufsize.h \
	parbufsize.h pathlength.h strsize.h textsize.h \
	botch_free.h debug.h inputtype.h dobits.h line_prefix.h

# Other generated files, for 'make clean' only
GENERATED = tokenfile.g Lpars.h LLfiles LL.output lint.out \
	Xref hfiles cfiles

all:	cc

cc:	hfiles LLfiles
	make cpp

hfiles: Parameters char.c
	$(SRC_DIR)/make.hfiles Parameters
	@touch hfiles

Parameters:	$(SRC_DIR)/Parameters
	cp $(SRC_DIR)/Parameters Parameters

char.c:	$(SRC_DIR)/char.tab
	tabgen -f$(SRC_DIR)/char.tab > char.c

LLfiles: $(LSRC)
	LLgen $(LLGENOPTIONS) $(LSRC)
	@touch LLfiles

tokenfile.g:	$(SRC_DIR)/tokenname.c $(SRC_DIR)/make.tokfile
	<$(SRC_DIR)/tokenname.c $(SRC_DIR)/make.tokfile >tokenfile.g

symbol2str.c:	$(SRC_DIR)/tokenname.c $(SRC_DIR)/make.tokcase
	<$(SRC_DIR)/tokenname.c $(SRC_DIR)/make.tokcase >symbol2str.c

# Objects needed for 'cpp'
OBJ =	$(COBJ) $(LOBJ) $(GOBJ)
SRC =	$(CSRC) $(LCSRC) $(GSRC)

cpp:	$(OBJ)
	$(CC) $(LDFLAGS) $(OBJ) $(LIBS) -o cpp 

cfiles: hfiles LLfiles $(GSRC)
	@touch cfiles

install: all
	cp cpp $(CEMPP)
	if [ $(DO_MACHINE_INDEP) = y ] ; \
	then cp $(SRC_DIR)/cpp.6 $(MANDIR)/cpp.6 ; \
	fi

cmp:	all
	-cmp cpp $(CEMPP)
	-cmp $(SRC_DIR)/cpp.6 $(MANDIR)/cpp.6

pr: 
	@pr $(PRFILES)

opr:
	make pr | opr

tags:	cfiles
	ctags $(SRC)

depend:	cfiles
	sed '/^#DEPENDENCIES/,$$d' Makefile >Makefile.new
	echo '#DEPENDENCIES' >>Makefile.new
	for i in $(SRC) ; do \
		echo "`basename $$i .c`.$$(SUF):	$$i" >> Makefile.new ; \
		echo '	$$(CC) -c $$(CFLAGS)' $$i >> Makefile.new ; \
		$(UTIL_HOME)/lib.bin/cpp -d $(INCLUDES) $$i | sed "s/^/`basename $$i .c`.$$(SUF):	/" >> Makefile.new ; \
	done
	mv Makefile Makefile.old
	mv Makefile.new Makefile
	
lint:	cfiles
	$(LINT) $(LINTFLAGS) $(INCLUDES) $(SRC) $(LINTLIBS)

clean:
	rm -f $(LCSRC) $(OBJ) $(GENERATED) $(GSRC) $(GHSRC) cpp Out

# do not remove the next line. It is used for generating dependencies.
#DEPENDENCIES
LLlex.$(SUF):	$(SRC_DIR)/LLlex.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/LLlex.c
LLlex.$(SUF):	./dobits.h
LLlex.$(SUF):	$(SRC_DIR)/bits.h
LLlex.$(SUF):	$(SRC_DIR)/class.h
LLlex.$(SUF):	./Lpars.h
LLlex.$(SUF):	$(SRC_DIR)/file_info.h
LLlex.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
LLlex.$(SUF):	$(SRC_DIR)/LLlex.h
LLlex.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
LLlex.$(SUF):	$(SRC_DIR)/idf.h
LLlex.$(SUF):	$(TARGET_HOME)/modules/pkg/inp_pkg.spec
LLlex.$(SUF):	./inputtype.h
LLlex.$(SUF):	$(SRC_DIR)/input.h
LLlex.$(SUF):	$(TARGET_HOME)/modules/h/alloc.h
LLlex.$(SUF):	./strsize.h
LLlex.$(SUF):	./numsize.h
LLlex.$(SUF):	./idfsize.h
LLmessage.$(SUF):	$(SRC_DIR)/LLmessage.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/LLmessage.c
LLmessage.$(SUF):	./Lpars.h
LLmessage.$(SUF):	$(SRC_DIR)/file_info.h
LLmessage.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
LLmessage.$(SUF):	$(SRC_DIR)/LLlex.h
ch7bin.$(SUF):	$(SRC_DIR)/ch7bin.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/ch7bin.c
ch7bin.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
ch7bin.$(SUF):	./Lpars.h
ch7mon.$(SUF):	$(SRC_DIR)/ch7mon.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/ch7mon.c
ch7mon.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
ch7mon.$(SUF):	./Lpars.h
domacro.$(SUF):	$(SRC_DIR)/domacro.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/domacro.c
domacro.$(SUF):	./dobits.h
domacro.$(SUF):	$(SRC_DIR)/bits.h
domacro.$(SUF):	$(SRC_DIR)/macro.h
domacro.$(SUF):	$(SRC_DIR)/class.h
domacro.$(SUF):	$(TARGET_HOME)/modules/h/alloc.h
domacro.$(SUF):	$(TARGET_HOME)/modules/h/assert.h
domacro.$(SUF):	./idfsize.h
domacro.$(SUF):	./textsize.h
domacro.$(SUF):	./parbufsize.h
domacro.$(SUF):	./nparams.h
domacro.$(SUF):	./botch_free.h
domacro.$(SUF):	./ifdepth.h
domacro.$(SUF):	$(TARGET_HOME)/modules/pkg/inp_pkg.spec
domacro.$(SUF):	./inputtype.h
domacro.$(SUF):	$(SRC_DIR)/input.h
domacro.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
domacro.$(SUF):	$(SRC_DIR)/idf.h
domacro.$(SUF):	./debug.h
domacro.$(SUF):	./Lpars.h
domacro.$(SUF):	$(SRC_DIR)/file_info.h
domacro.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
domacro.$(SUF):	$(SRC_DIR)/LLlex.h
domacro.$(SUF):	$(SRC_DIR)/interface.h
error.$(SUF):	$(SRC_DIR)/error.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/error.c
error.$(SUF):	$(SRC_DIR)/file_info.h
error.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
error.$(SUF):	$(SRC_DIR)/LLlex.h
error.$(SUF):	./errout.h
error.$(SUF):	/usr/include/varargs.h
error.$(SUF):	$(TARGET_HOME)/modules/h/system.h
idf.$(SUF):	$(SRC_DIR)/idf.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/idf.c
idf.$(SUF):	$(TARGET_HOME)/modules/h/alloc.h
idf.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.body
idf.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
idf.$(SUF):	$(SRC_DIR)/idf.h
init.$(SUF):	$(SRC_DIR)/init.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/init.c
init.$(SUF):	$(SRC_DIR)/interface.h
init.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
init.$(SUF):	$(SRC_DIR)/idf.h
init.$(SUF):	$(SRC_DIR)/macro.h
init.$(SUF):	$(SRC_DIR)/class.h
init.$(SUF):	$(TARGET_HOME)/modules/h/alloc.h
init.$(SUF):	$(TARGET_HOME)/modules/h/system.h
input.$(SUF):	$(SRC_DIR)/input.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/input.c
input.$(SUF):	$(TARGET_HOME)/modules/h/system.h
input.$(SUF):	$(TARGET_HOME)/modules/h/alloc.h
input.$(SUF):	$(TARGET_HOME)/modules/pkg/inp_pkg.body
input.$(SUF):	$(TARGET_HOME)/modules/pkg/inp_pkg.spec
input.$(SUF):	./inputtype.h
input.$(SUF):	$(SRC_DIR)/input.h
input.$(SUF):	$(SRC_DIR)/file_info.h
main.$(SUF):	$(SRC_DIR)/main.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/main.c
main.$(SUF):	$(SRC_DIR)/macro.h
main.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
main.$(SUF):	$(SRC_DIR)/idf.h
main.$(SUF):	./idfsize.h
main.$(SUF):	$(SRC_DIR)/file_info.h
main.$(SUF):	$(TARGET_HOME)/modules/h/system.h
main.$(SUF):	$(TARGET_HOME)/modules/h/assert.h
main.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
main.$(SUF):	$(TARGET_HOME)/modules/h/alloc.h
options.$(SUF):	$(SRC_DIR)/options.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/options.c
options.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
options.$(SUF):	$(SRC_DIR)/idf.h
options.$(SUF):	$(SRC_DIR)/macro.h
options.$(SUF):	$(SRC_DIR)/class.h
options.$(SUF):	./idfsize.h
options.$(SUF):	$(TARGET_HOME)/modules/h/alloc.h
Version.$(SUF):	$(SRC_DIR)/Version.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/Version.c
preprocess.$(SUF):	$(SRC_DIR)/preprocess.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/preprocess.c
preprocess.$(SUF):	./line_prefix.h
preprocess.$(SUF):	./dobits.h
preprocess.$(SUF):	$(SRC_DIR)/bits.h
preprocess.$(SUF):	./idfsize.h
preprocess.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
preprocess.$(SUF):	$(SRC_DIR)/idf.h
preprocess.$(SUF):	$(SRC_DIR)/class.h
preprocess.$(SUF):	$(SRC_DIR)/file_info.h
preprocess.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
preprocess.$(SUF):	$(SRC_DIR)/LLlex.h
preprocess.$(SUF):	./obufsize.h
preprocess.$(SUF):	$(TARGET_HOME)/modules/pkg/inp_pkg.spec
preprocess.$(SUF):	./inputtype.h
preprocess.$(SUF):	$(SRC_DIR)/input.h
preprocess.$(SUF):	$(TARGET_HOME)/modules/h/system.h
replace.$(SUF):	$(SRC_DIR)/replace.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/replace.c
replace.$(SUF):	$(SRC_DIR)/interface.h
replace.$(SUF):	$(SRC_DIR)/class.h
replace.$(SUF):	$(SRC_DIR)/file_info.h
replace.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
replace.$(SUF):	$(SRC_DIR)/LLlex.h
replace.$(SUF):	$(SRC_DIR)/macro.h
replace.$(SUF):	$(TARGET_HOME)/modules/pkg/inp_pkg.spec
replace.$(SUF):	./inputtype.h
replace.$(SUF):	$(SRC_DIR)/input.h
replace.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
replace.$(SUF):	$(SRC_DIR)/idf.h
replace.$(SUF):	$(TARGET_HOME)/modules/h/assert.h
replace.$(SUF):	$(TARGET_HOME)/modules/h/alloc.h
replace.$(SUF):	./textsize.h
replace.$(SUF):	./pathlength.h
replace.$(SUF):	./debug.h
scan.$(SUF):	$(SRC_DIR)/scan.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/scan.c
scan.$(SUF):	$(SRC_DIR)/file_info.h
scan.$(SUF):	$(SRC_DIR)/interface.h
scan.$(SUF):	$(SRC_DIR)/macro.h
scan.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
scan.$(SUF):	$(SRC_DIR)/idf.h
scan.$(SUF):	$(SRC_DIR)/class.h
scan.$(SUF):	$(TARGET_HOME)/modules/pkg/inp_pkg.spec
scan.$(SUF):	./inputtype.h
scan.$(SUF):	$(SRC_DIR)/input.h
scan.$(SUF):	./nparams.h
scan.$(SUF):	./lapbuf.h
skip.$(SUF):	$(SRC_DIR)/skip.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/skip.c
skip.$(SUF):	$(TARGET_HOME)/modules/pkg/inp_pkg.spec
skip.$(SUF):	./inputtype.h
skip.$(SUF):	$(SRC_DIR)/input.h
skip.$(SUF):	$(SRC_DIR)/class.h
skip.$(SUF):	$(SRC_DIR)/file_info.h
skip.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
skip.$(SUF):	$(SRC_DIR)/LLlex.h
tokenname.$(SUF):	$(SRC_DIR)/tokenname.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/tokenname.c
tokenname.$(SUF):	./Lpars.h
tokenname.$(SUF):	$(SRC_DIR)/file_info.h
tokenname.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
tokenname.$(SUF):	$(SRC_DIR)/LLlex.h
tokenname.$(SUF):	$(TARGET_HOME)/modules/pkg/idf_pkg.spec
tokenname.$(SUF):	$(SRC_DIR)/idf.h
next.$(SUF):	$(SRC_DIR)/next.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/next.c
next.$(SUF):	./debug.h
expr.$(SUF):	$(SRC_DIR)/expr.c
	$(CC) -c $(CFLAGS) $(SRC_DIR)/expr.c
expr.$(SUF):	./Lpars.h
tokenfile.$(SUF):	tokenfile.c
	$(CC) -c $(CFLAGS) tokenfile.c
tokenfile.$(SUF):	Lpars.h
expression.$(SUF):	expression.c
	$(CC) -c $(CFLAGS) expression.c
expression.$(SUF):	$(SRC_DIR)/file_info.h
expression.$(SUF):	$(TARGET_HOME)/modules/h/em_arith.h
expression.$(SUF):	$(SRC_DIR)/LLlex.h
expression.$(SUF):	Lpars.h
Lpars.$(SUF):	Lpars.c
	$(CC) -c $(CFLAGS) Lpars.c
Lpars.$(SUF):	Lpars.h
char.$(SUF):	char.c
	$(CC) -c $(CFLAGS) char.c
char.$(SUF):	$(SRC_DIR)/class.h
symbol2str.$(SUF):	symbol2str.c
	$(CC) -c $(CFLAGS) symbol2str.c
symbol2str.$(SUF):	Lpars.h
