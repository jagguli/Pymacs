# Interface between Emacs Lisp and Python - Makefile.
# Copyright © 2001, 2002, 2003, 2012 Progiciels Bourbeau-Pinard inc.
# François Pinard <pinard@iro.umontreal.ca>, 2001.

EMACS = emacs
PYTHON = python
RST2LATEX = rst2latex

PYSETUP = $(PYTHON) setup.py
PPPP = $(PYTHON) pppp -C ppppconfig.py

all pregithub: prepare
	$(PYSETUP) --quiet build

test: check
check: clean-debug
	$(PPPP) pymacs.el.in Pymacs.py.in tests
	cd tests && \
	  EMACS="$(EMACS)" PYTHON="$(PYTHON)" \
	  PYMACS_OPTIONS="-d debug-protocol -s debug-signals" \
	  $(PYTHON) pytest -f t $(TEST)

install: prepare
	$(PYSETUP) install

prepare:
	$(PPPP) Pymacs.py.in pppp.rst.in pymacs.el.in pymacs.rst.in contrib tests

clean: clean-debug
	rm -rf build* contrib/rebox/build
	rm -f */*py.class *.pyc */*.pyc pppp.pdf pymacs.pdf
	$(PPPP) -c *.in contrib tests

clean-debug:
	rm -f tests/debug-protocol tests/debug-signals

pppp.pdf: pppp.rst.in
	$(PPPP) pppp.rst.in
	rm -rf tmp-pdf
	mkdir tmp-pdf
	$(RST2LATEX) --use-latex-toc --input-encoding=UTF-8 \
	  pppp.rst tmp-pdf/pppp.tex
	cd tmp-pdf && pdflatex pppp.tex
	cd tmp-pdf && pdflatex pppp.tex
	mv -f tmp-pdf/pppp.pdf $@
	rm -rf tmp-pdf

pymacs.pdf: pymacs.rst.in
	$(PPPP) pymacs.rst.in
	rm -rf tmp-pdf
	mkdir tmp-pdf
	$(RST2LATEX) --use-latex-toc --input-encoding=UTF-8 \
	  pymacs.rst tmp-pdf/pymacs.tex
	cd tmp-pdf && pdflatex pymacs.tex
	cd tmp-pdf && pdflatex pymacs.tex
	mv -f tmp-pdf/pymacs.pdf $@
	rm -rf tmp-pdf

# ifneq "$(wildcard ~/etc/mes-sites/site.mk)" ""

htmldir = ./html
symlink =


GOALS = $(htmldir)/README.html $(htmldir)/contrib $(htmldir)/index.html $(htmldir)/pppp.pdf $(htmldir)/pymacs.pdf

site: $(GOALS)

package_name = Pymacs
margin_color = "\#d1b7ff"
caption_color = "\#f1e4eb"


# include ~/etc/mes-sites/site.mk

$(htmldir)/README.html $(htmldir)/index.html:
	./org2html.sh README.org
	@rm -f $@
	# @ln -s ~/html/notes/Pymacs.html $@

$(htmldir)/contrib: contrib
	$(symlink)

$(htmldir)/pppp.pdf: pppp.pdf
	$(symlink)

$(htmldir)/pymacs.pdf: pymacs.pdf
	$(symlink)
