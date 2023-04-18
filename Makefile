## To build the needed Docker image see https://github.com/cagix/pandoc-lecture/docker.
##
## To build the slides/book , start the container interactively using "make runlocal" and
## run the desired Make targets in the interactive container shell.

PANDOC           = pandoc

MARKDOWN_SOURCES = README.md faq_praxisphase.md faq_abschlussarbeit.md faq_nachteilsausgleich.md
SLIDES_TARGETS   = $(MARKDOWN_SOURCES:%.md=%.pdf)
BOOK_Target      = IFM_FAQ_Praxisphase_Bachelorarbeit.pdf


.PHONY: runlocal
runlocal: ## Start Docker container "pandoc-lecture" into interactive shell
	docker run  --rm -it  -v "$(shell pwd):/pandoc" -w "/pandoc"  -u "$(shell id -u):$(shell id -g)"  -e CI=true  --entrypoint "bash"  pandoc-lecture


.PHONY: all
all: slides book ## Make everything

.PHONY: slides
slides: $(SLIDES_TARGETS) ## Create all slides

.PHONY: book
book: $(BOOK_Target) ## Create book


.PHONY: clean
clean: ## Clean up intermediate files and directories
	rm -rf $(SLIDES_TARGETS) $(BOOK_Target)


$(SLIDES_TARGETS): %.pdf: %.md
	$(PANDOC) -d ./slides $< -o $@

$(BOOK_Target): $(MARKDOWN_SOURCES)
	$(PANDOC) -d ./book   $< -o $@
