# default parameters
ROOT:=$(PWD)
SRCDIR:=src
HEADERDIR:=src/header
BIBDIR:=src/bib
BINDIR:=bin
FIGDIR:=figures
VIDEODIR:=video
BUILDDIR:=build

# useful parameter from above 
# assumes there is a tikz folder in figures to compile them
TKIZDIR:=$(ROOT)/$(FIGDIR)/tikz
# get the main tex and seve the name wihtout extension in FILENAME
FILENAME:=$(shell grep -Elr 'documentclass' $(SRCDIR)/*.tex | cut -d':' -f1)
FILENAME:=$(notdir $(FILENAME))
FILENAME:=$(basename $(FILENAME))
$(info The main tex is $(FILENAME).tex)
TEXFILENAME:=$(FILENAME).tex
DEPEND_SRCS:= $(shell find $(SRCDIR) -name '*.tex')
DEPEND_SRCS_FIG:= $(shell find $(TKIZDIR) -name '*.tex')
# export this variable to access the .cls in the header folder
export TEXINPUTS=.:./header/:

define link_bst_bib_sty
	for f in $(shell find $(SRCDIR) -name '*.sty') \
		$(shell find $(SRCDIR) -name '*.bib') \
		$(shell find $(SRCDIR) -name '*.bst') \
		$(shell find $(SRCDIR) -name '*.cls') ; do \
		echo $$f ; \
		ln -sf $(ROOT)/$$f $(ROOT)/$(BUILDDIR)/ ;\
	done
endef

define prepare_build
	if [ ! -d "$(BUILDDIR)" ]; then mkdir $(BUILDDIR); fi
	if [ ! -d "$(BINDIR)" ]; then mkdir $(BINDIR); fi
	$(call link_bst_bib_sty)
endef

define end_build
	echo "copy of \"" $(1) "\" in the build folder"
	for pdffile in $(1) ; do \
		cp $(ROOT)/$(BUILDDIR)/$$pdffile.pdf $(ROOT)/$(BINDIR)/ ; \
	done
endef

define pdf_latex
	echo "pdf_latex arguments are :" $(1) $(2)
	for texfiles in $(2) ; do \
		echo "Compiling :" $$texfiles.tex ;\
		cd $(1) ; pdflatex -interaction=nonstopmode --output-directory=$(ROOT)/$(BUILDDIR) $$texfiles.tex ; cd $(ROOT) ; pwd ;\
	done
endef

define pdf_latex_debug
	echo "pdf_latex arguments are :" $(1) $(2)
	for texfiles in $(2) ; do \
		echo "Compiling :" $$texfiles.tex ;\
		cd $(1) ; pdflatex --output-directory=$(ROOT)/$(BUILDDIR) $$texfiles.tex ; cd $(ROOT) ; pwd ;\
	done
endef

define bibtex
	for bibfiles in $(1) ; do \
		echo "Bibtex on :" $$bibfiles.aux ;\
		cd $(ROOT)/$(BUILDDIR) ; bibtex $$bibfiles.aux ; cd $(ROOT)/ ; \
	done
endef

define build
	$(call pdf_latex, $(1), $(2))
	$(call bibtex, $(2))
	$(call pdf_latex, $(1), $(2))
	$(call pdf_latex, $(1), $(2))
endef

define build_fast
	$(call pdf_latex, $(1), $(2))
	$(call bibtex, $(2))
endef

define build_debug
	$(call pdf_latex_debug, $(1), $(2))
	$(call bibtex, $(2))
endef

all: $(DEPEND_SRCS)
	$(call prepare_build)
	$(call build, $(ROOT)/$(SRCDIR), $(FILENAME))
	$(call end_build, $(FILENAME))

$(FILENAME): $(DEPEND_SRCS)
	$(call prepare_build)
	$(call build_fast, $(ROOT)/$(SRCDIR), $@)
	$(call end_build, $@)

figures: $(DEPEND_SRCS_FIG)
	$(call prepare_build)
	$(foreach source, $(DEPEND_SRCS_FIG), $(call build, $(TIKZDIR), $(basename $(source))) ; cp $(ROOT)/$(BUILDDIR)/$(basename $(source))).pdf $(ROOT)/$(FIGDIR))

fast: $(DEPEND_SRCS)
	$(call prepare_build)
	$(call build_fast, $(ROOT)/$(SRCDIR), $(FILENAME))
	$(call end_build, $(FILENAME))

count: $(DEPEND_SRCS)
	wc -w $(DEPEND_SRCS)

bib : $(DEPEND_SRCS)
	$(call prepare_build)
	$(call bibtex,$(FILENAME))	

debug: $(DEPEND_SRCS)
	$(call prepare_build)
	$(call build_debug, $(ROOT)/$(SRCDIR), $(FILENAME))
	$(call end_build, $(FILENAME))

clean:
	rm -f ./build/*
