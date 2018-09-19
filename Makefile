SRC = src
CFLAGS = -g3 $(XFLAGS) -I$(SRC)
OFLAGS = -O3 -DNDEBUG
#OFLAGS = -pg

all : peg leg

peg : peg.o
	$(CC) $(CFLAGS) -o $@-new peg.o
	mv $@-new $@

leg : leg.o
	$(CC) $(CFLAGS) -o $@-new leg.o
	mv $@-new $@

ROOT	=
PREFIX	= /usr/local
BINDIR	= $(ROOT)$(PREFIX)/bin
MANDIR	= $(ROOT)$(PREFIX)/man/man1

install : $(BINDIR) $(BINDIR)/peg $(BINDIR)/leg $(MANDIR) $(MANDIR)/peg.1

$(BINDIR) :
	mkdir -p $(BINDIR)

$(BINDIR)/% : %
	cp -p $< $@

$(MANDIR) :
	mkdir -p $(MANDIR)

$(MANDIR)/% : $(SRC)/%
	cp -p $< $@

uninstall : .FORCE
	rm -f $(BINDIR)/peg
	rm -f $(BINDIR)/leg
	rm -f $(MANDIR)/peg.1

%.o : $(SRC)/%_.c
	$(CC) $(CFLAGS) -c -o $@ $<

peg.o : $(SRC)/peg.c $(SRC)/peg.peg-c

leg.o : $(SRC)/leg.c

check : check-peg check-leg

check-peg : peg.peg-c .FORCE
	diff $(SRC)/peg.peg-c peg.peg-c

check-leg : leg.c .FORCE
	diff $(SRC)/leg.c leg.c

peg.peg-c : $(SRC)/peg.peg peg
	./peg -o $@ $<

leg.c : $(SRC)/leg.leg leg
	./leg -o $@ $<

new : newpeg newleg

newpeg : peg.peg-c
	mv $(SRC)/peg.peg-c $(SRC)/peg.peg-c-
	mv peg.peg-c $(SRC)/.

newleg : leg.c
	mv $(SRC)/leg.c $(SRC)/leg.c-
	mv leg.c $(SRC)/.

test examples : peg leg .FORCE
	$(SHELL) -ec '(cd examples;  $(MAKE))'

clean : .FORCE
	rm -f $(SRC)/*~ *~ *.o *.peg.[cd] *.leg.[cd] peg.peg-c
	$(SHELL) -ec '(cd examples;  $(MAKE) $@)'

spotless : clean .FORCE
	rm -f $(SRC)/*-
	rm -rf build
	rm -f peg
	rm -f leg
	$(SHELL) -ec '(cd examples;  $(MAKE) $@)'

.FORCE :
