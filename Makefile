# This Makefile provides sensible defaults for projects
# based on Pandoc and Jekyll, such as:
# - Dockerized runs of Pandoc and Jekyll with separate
#   variables for version numbers = easy update!
# - Lean CSL checkouts without committing to the repo
# - Website built on the gh-pages branch
# - Bibliography path compatible with Jekyll-Scholar

# Global variables and setup {{{1
# ================
VPATH = _lib
vpath %.yaml .:_spec
vpath default.% .:_lib
vpath reference.% .:_lib

PANDOC-VERSION := 2.18
PANDOC/CROSSREF := docker run --rm -v "`pwd`:/data" \
	-u "`id -u`:`id -g`" pandoc/core:$(PANDOC-VERSION)
PANDOC/LATEX := docker run --rm -v "`pwd`:/data" \
	-u "`id -u`:`id -g`" palazzo/pandoc-ebgaramond:$(PANDOC-VERSION)

# Targets and recipes {{{1
# ===================
%.pdf : %.md _bibliography.yaml latex.yaml
	$(PANDOC/LATEX) -d _spec/latex.yaml -o $@ $<
	@echo "$< > $@"

cv.pdf : cv.md cv.bib _chicago-cv.csl latex.yaml
	$(PANDOC/LATEX) -d _spec/latex.yaml -o $@ $<
	@echo "$< > $@"

%.docx : %.md _spec/docx.yaml _lib/reference.docx
	$(PANDOC/CROSSREF) -d _spec/docx.yaml -o $@ $<
	@echo "$< > $@"
# vim: set foldmethod=marker shiftwidth=2 tabstop=2 :
