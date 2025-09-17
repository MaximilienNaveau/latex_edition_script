# default parameters
ROOT:="$(PWD)"
SRCDIR:=src
HEADERDIR:=src/header
BIBDIR:=src/bib
BINDIR:=bin
FIGDIR:=figures
VIDEODIR:=video
BUILDDIR:=build

# useful parameter from above
# assumes there is a tikz folder in figures to compile them
TIKZDIR:=$(shell find $(SRCDIR) -name "tikz" -type d)
# get the main tex and save the name wihtout extension in TARGETNAME
TARGETNAME:=$(shell grep -Elr 'documentclass' `find $(SRCDIR) -name "*.tex"`)
TARGETNAME:=$(notdir $(TARGETNAME))
TARGETNAME:=$(basename $(TARGETNAME))
$(info The main tex is $(TARGETNAME))
DEPEND_SRCS:= $(shell find $(SRCDIR) -name '*.tex')
DEPEND_SRCS_FIG:= $(shell find $(TIKZDIR) -name '*.tex')
# export this variable to access the .cls in the header folder
export TEXINPUTS=.:./header/:

define link_bst_bib_sty
	for f in $(shell find $(SRCDIR) -name "*.sty" | sed -e "s/^/\"/g" -e 's/$$/"/g' ) \
		 $(shell find $(SRCDIR) -name "*.bib" | sed -e "s/^/\"/g" -e 's/$$/"/g' ) \
		 $(shell find $(SRCDIR) -name "*.bst" | sed -e "s/^/\"/g" -e 's/$$/"/g' ) \
		 $(shell find $(SRCDIR) -name "*.cls" | sed -e "s/^/\"/g" -e 's/$$/"/g' ) ; do \
		echo $$f ; \
		ln -sf $(ROOT)/$$f $(ROOT)/$(BUILDDIR)/ ;\
	done
	ln -sf $(ROOT)/$(VIDEODIR) $(ROOT)/$(BUILDDIR)/
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
	for targetname in $(2) ; do \
		cd $(1) ;\
		texfile=`find . -name "$$targetname.tex"` ;\
		working_dir=`echo $$texfile | sed 's|/[^/]*$$||'` ;\
		cd $$working_dir ;\
		texfile=`find . -name "$$targetname.tex"` ;\
		pdflatex -shell-escape -interaction=nonstopmode --output-directory=$(ROOT)/$(BUILDDIR) $$texfile;\
		cd $(ROOT) ; pwd ;\
	done
endef

define pdf_latex_debug
	echo "pdf_latex arguments are :" $(1) $(2)
	for texfiles in $(2) ; do \
		echo "Compiling :" $$texfiles.tex ;\
		cd $(1) ; pdflatex -shell-escape --output-directory=$(ROOT)/$(BUILDDIR) $$texfiles.tex ; cd $(ROOT) ; pwd ;\
	done
endef

define biber
	for bibfiles in $(1) ; do \
		echo "biber on :" $$bibfiles ;\
		cd $(ROOT)/$(BUILDDIR) ; biber $$bibfiles ; cd $(ROOT)/ ; \
	done
endef

define build
	$(call pdf_latex, $(1), $(2))
	$(call biber, $(2))
	$(call pdf_latex, $(1), $(2))
	$(call pdf_latex, $(1), $(2))
endef

define build_fast
	$(call pdf_latex, $(1), $(2))
	$(call biber, $(2))
endef

define build_debug
	$(call pdf_latex_debug, $(1), $(2))
	$(call biber, $(2))
endef

define build_figure
	$(call build, $1, $(basename $2))
	cp $(ROOT)/$(BUILDDIR)/$(basename $(notdir $2)).pdf $(ROOT)/$(FIGDIR)
	echo "End of build_figure"
endef

all: $(DEPEND_SRCS)
	$(call prepare_build)
	$(call build, $(ROOT)/$(SRCDIR), $(TARGETNAME))
	$(call end_build, $(TARGETNAME))

$(TARGETNAME): $(DEPEND_SRCS)
	$(call prepare_build)
	$(call build_fast, $(ROOT)/$(SRCDIR), $@)
	$(call end_build, $@)

figures: $(DEPEND_SRCS_FIG)
	$(call prepare_build)
	$(foreach source, $(DEPEND_SRCS_FIG), $(call build_figure, $(TIKZDIR), $(source)))

fast: $(DEPEND_SRCS)
	$(call prepare_build)
	$(call build_fast, $(ROOT)/$(SRCDIR), $(TARGETNAME))
	$(call end_build, $(TARGETNAME))

count: $(DEPEND_SRCS)
	wc -w $(DEPEND_SRCS)

bib : $(DEPEND_SRCS)
	$(call prepare_build)
	$(call biber,$(TARGETNAME))	

debug: $(DEPEND_SRCS)
	$(call prepare_build)
	$(call build_debug, $(ROOT)/$(SRCDIR), $(TARGETNAME))
	$(call end_build, $(TARGETNAME))

clean:
	rm -f ./build/*

bash_instruction:
	$(call link_bst_bib_sty)	
