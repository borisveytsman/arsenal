PACKAGE=arsenal

FONTS = \
	Arsenal-Bold.otf \
	Arsenal-BoldItalic.otf \
	Arsenal-Italic.otf \
	Arsenal-Regular.otf 

SAMPLES = sample-math-iwona.tex sample-math-kpsans.tex sample-text.tex

PDF = $(PACKAGE).pdf ${SAMPLES:%.tex=%.pdf}

all:  ${PDF} $(PACKAGE).sty $(FONTS) LICENSE_FONTS


%.pdf:  %.dtx   $(PACKAGE).sty $(FONTS)
	xelatex $<
	- bibtex $*
	xelatex $<
	- makeindex -s gind.ist -o $*.ind $*.idx
	- makeindex -s gglo.ist -o $*.gls $*.glo
	xelatex $<
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $*.log) \
	do xelatex $<; done


%.sty:   %.ins %.dtx  
	xelatex $<

%.pdf:  %.tex   $(PACKAGE).sty $(FONTS)
	xelatex $<
	- bibtex $*
	xelatex $<
	xelatex $<
	while ( grep -q '^LaTeX Warning: Label(s) may have changed' $*.log) \
	do xelatex $<; done

sample-math-%.tex: $(PACKAGE).ins sample-math.dtx
	xelatex $<

%.otf: arsenal-fonts/fonts/otf/%.otf
	cp $< $@

LICENSE_FONTS: arsenal-fonts/OFL.TXT
	cp $< $@

clean:
	$(RM)  *_FAMILY_* *.log *.aux \
	*.cfg *.glo *.idx *.toc \
	*.ilg *.ind *.out *.lof \
	*.lot *.bbl *.blg *.gls \
	*.dvi *.ps *.thm *.tgz *.zip *.rpi \
        *.hd  *.sty sample-math-*.tex


distclean: clean
	$(RM) $(PDF) $(PACKAGE).sty $(FONTS) LICENSE_FONTS

#
# Archive for the distribution. Includes typeset documentation
#
archive:  all clean
	COPYFILE_DISABLE=1  \
	tar -C .. -czvf ../$(PACKAGE).tgz --exclude '*~' \
	--exclude '*.tgz' --exclude '*.zip'  --exclude .git $(PACKAGE)
	mv ../$(PACKAGE).tgz .

zip:  all clean
	make $(PACKAGE).sty
	$(RM) $(PACKAGE).log
	cd ..;\
	zip -r  $(PACKAGE).zip $(PACKAGE) -x "*.ins" -x "*.gitignore"

