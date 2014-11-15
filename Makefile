.PHONY: all clean dist print

P = cv

SPELLTEX=$(shell egrep '^\\\input' $P.tex | sed 's/^.*input[^{]*{//' | sed 's/}.*$$/.tex/')

default : $P.pdf

$P.dvi	: $(wildcard *.tex *.bib *.sty *.cls)
	latex  $P < /dev/null || $(RM) $@
	bibtex $P < /dev/null || $(RM) $@
	latex  $P < /dev/null || $(RM) $@
	latex  $P < /dev/null || $(RM) $@

# dvipdf -Tletter $P.dvi $P.pdf
$P.pdf	: $(wildcard *.tex *.bib *.sty *.cls)
	pdflatex  $P < /dev/null || $(RM) $@
	bibtex $P < /dev/null || $(RM) $@
	bibtex conference < /dev/null || $(RM) $@
	bibtex workshop < /dev/null || $(RM) $@
	bibtex demos < /dev/null || $(RM) $@
	bibtex trs < /dev/null || $(RM) $@
	pdflatex  $P < /dev/null || $(RM) $@
	pdflatex  $P < /dev/null || $(RM) $@

paper-diff.pdf : $P.pdf # hack to pull in all dependencies of P.pdf
	latexdiff --flatten paper.tex paper-in.tex > paper-diff.tex
	pdflatex paper-diff
	bibtex paper-diff
	pdflatex paper-diff
	pdflatex paper-diff

%.pdf : %.svg
	./svg2pdf $<

%.eps : %.svg
	./svg2eps $<

%.pdf : %.eps
	epstopdf $< -o $@

%.eps : %.ps
	ps2eps -R + -f $<

$P.ps	: $P.dvi
	dvips -t letter $P.dvi -o $P.ps

$P.ps.gz: $P.ps
	$(RM) $P.ps.gz
	gzip -9 < $P.ps > $P.ps.gz

spellcheck:
	for i in $(SPELLTEX); do \
	  echo $$i; \
	  aspell -c --home-dir=. $$i; \
	done

print:	$P.ps

dist:	$P.ps.gz

clean:
	$(RM) $P.log $P.aux $P.bbl $P.blg $P.dvi $P.ps $P.ps.gz texput.log $P.out $P.pdf flatpaper-* *.bak

camera.pdf: $P.dvi
	dvips -Ppdf -Pcmz -Pamz -t letter -D 600 -G0 $P.dvi
	ps2pdf14 -dPDFSETTINGS=/prepress -dEmbedAllFonts=true $P.ps
	cp paper.pdf camera.pdf
