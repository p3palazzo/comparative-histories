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
vpath %.bib _bibliography
vpath %.csl .:_csl
vpath %.yaml .:_spec
vpath default.% .:_lib
vpath reference.% .:_lib

DEFAULTS := defaults.yaml references.bib
PANDOC-VERSION := 2.16.1
PANDOC/CROSSREF := docker run --rm -v "`pwd`:/data" \
	-u "`id -u`:`id -g`" pandoc/crossref:$(PANDOC-VERSION)
PANDOC/LATEX := docker run --rm -v "`pwd`:/data" \
	-u "`id -u`:`id -g`" palazzo/pandoc-ebgaramond:$(PANDOC-VERSION)

# Targets and recipes {{{1
# ===================
%.pdf : %.md _bibliography.yaml _latex.yaml \
	| _csl/chicago-fullnote-bibliography-with-ibid.csl
	$(PANDOC/LATEX) -d _latex.yaml -o $@ $<
	@echo "$< > $@"

cv.pdf : cv.md cv.bib _chicago-cv.csl _latex.yaml
	$(PANDOC/LATEX) -d _latex.yaml -o $@ $<
	@echo "$< > $@"

%.docx : %.md $(DEFAULTS) \
	| _csl/chicago-fullnote-bibliography-with-ibid.csl
	$(PANDOC/CROSSREF) -d _spec/defaults.yaml -o $@ $<
	@echo "$< > $@"

_csl/%.csl : _csl
	@cd _csl && git checkout master -- $(@F)
	@echo "Checked out $(@F)."

# Install and cleanup {{{1
# ===================
.PHONY : _csl
_csl :
	@echo "Fetching CSL styles..."
	@test -e $@ || \
		git clone --depth=1 --filter=blob:none --no-checkout \
		https://github.com/citation-style-language/styles.git \
		$@

.PHONY : clean
clean :
	-rm -rf _book/* _csl
# vim: set foldmethod=marker shiftwidth=2 tabstop=2 :
