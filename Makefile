## Run 'make book' or 'make slides' to build the faq material.
##
## (a) You can use the toolchain installed in the Docker image "pandoc-lecture",
##     which comes ready to use (no other dependencies).
## (b) Alternatively, you need to
##         (1) install all tools (Pandoc, Hugo, TexLive) manually to your
##             operating system, and
##         (2) clone the pandoc-lecture repo locally to a specific location:
##             "git clone --depth 1 https://github.com/cagix/pandoc-lecture.git ${HOME}/.local/share/pandoc/".
##
## To build the mentioned Docker image or for the required packages for a native
## installation, see https://github.com/cagix/pandoc-lecture/docker.
##
## If you want to use the Docker image to build the faq material, start the
## container interactively using "make runlocal" and run the desired Make targets
## in the interactive container shell.


#--------------------------------------------------------------------------------
# Tools
#--------------------------------------------------------------------------------
PANDOC           = pandoc

## Where do we find the content from https://github.com/cagix/pandoc-lecture,
## i.e. the resources for Pandoc?
##     (a) If we run inside the Docker container, the variable CI is set to
##         true and we find the files in ${XDG_DATA_HOME}/pandoc/.
##     (b) If we are running locally (native installation), then we look for
##         the contents at ${HOME}/.local/share/pandoc/.
## Note: $(CI) is a default environment variable that GitHub sets (see
## https://docs.github.com/en/actions/learn-github-actions/variables#default-environment-variables)
ifeq ($(CI), true)
PANDOC_DIRS = --resource-path=".:$(XDG_DATA_HOME)/pandoc/:$(XDG_DATA_HOME)/pandoc/resources/"
else
PANDOC_DIRS = --resource-path=".:$(HOME)/.local/share/pandoc/:$(HOME)/.local/share/pandoc/resources/"
endif


#--------------------------------------------------------------------------------
# Source and target files for book and slides
#--------------------------------------------------------------------------------
MARKDOWN_SOURCES = README.md faq_praxisphase.md faq_abschlussarbeit.md faq_nachteilsausgleich.md
SLIDES_TARGETS   = $(MARKDOWN_SOURCES:%.md=%.pdf)
BOOK_Target      = IFM_FAQ_Praxisphase_Bachelorarbeit.pdf


#--------------------------------------------------------------------------------
# Main targets
#--------------------------------------------------------------------------------
.DEFAULT_GOAL:=help

.PHONY: help
help:  ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)


.PHONY: runlocal
runlocal: ## Start Docker container "pandoc-lecture" into interactive shell
	docker run  --rm -it  -v "$(shell pwd):/pandoc" -w "/pandoc"  -u "$(shell id -u):$(shell id -g)"  -e CI=true  --entrypoint "bash"  pandoc-lecture


.PHONY: all
all: slides book ## Make everything

.PHONY: slides
slides: $(SLIDES_TARGETS) ## Create all slides

.PHONY: book
book: $(BOOK_Target) ## Create a book


.PHONY: clean
clean: ## Clean up intermediate files and directories
	rm -rf $(SLIDES_TARGETS) $(BOOK_Target)


#--------------------------------------------------------------------------------
# Internal targets
#--------------------------------------------------------------------------------
$(SLIDES_TARGETS): %.pdf: %.md
	$(PANDOC) $(PANDOC_DIRS) -d ./slides $< -o $@

$(BOOK_Target): $(MARKDOWN_SOURCES)
	$(PANDOC) $(PANDOC_DIRS) -d ./book   $^ -o $@
