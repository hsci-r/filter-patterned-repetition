knitopts = echo=F, warning=F, message=F

all: markdown

markdown: \
  analysis.md

html: \
  analysis.html

.Rmd.md:
	Rscript -e "knitr::opts_chunk\$$set($(knitopts)); knitr::knit('$<', output='$@')"

.md.html:
	pandoc $< -o $@

.SUFFIXES: .Rmd .md .html

.PHONY: markdown html
