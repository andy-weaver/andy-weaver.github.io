# Makefile for Quarto Blog Automation
# ===================================
# Usage:
#   make serve                   – live preview (quarto preview)
#   make render                  – render site without serve
#   make post TITLE="My Post" [CATEGORIES="cat1,cat2"] [DATE="YYYY-MM-DD"]
#   make page NAME="about"       – scaffold a new static page (about.qmd)
#   make clean                   – clean rendered output directory
#   make publish                 – render + commit + push

SHELL := /bin/bash

help:
	@echo "Quarto Blog Makefile"
	@echo ""
	@echo "Commands:"
	@echo "  make serve                   – start local preview server"
	@echo "  make render                  – render the full site"
	@echo "  make post TITLE=\"My New Post\" [CATEGORIES=\"cat1,cat2\"] [DATE=\"YYYY-MM-DD\"]"
	@echo "  make page NAME=\"about\""
	@echo "  make clean                   – remove output"
	@echo "  make publish                 – render, commit & push"

serve:
	quarto preview

render:
	quarto render

post:
ifndef TITLE
	$(error You must provide a TITLE, e.g. make post TITLE="My New Analysis")
endif
	@date=$$(if [ -n "$(DATE)" ]; then echo "$(DATE)"; else date +%Y-%m-%d; fi); \
	slug=$$(echo "$(TITLE)" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$$//'); \
	dir=posts/$${date}-$${slug}; \
	mkdir -p posts; \
	if [ -d "$$dir" ]; then \
	  echo "Error: directory $$dir already exists!"; exit 1; \
	fi; \
	echo "Creating new post folder: $$dir"; \
	mkdir -p "$$dir"; \
	categories=$$(if [ -n "$(CATEGORIES)" ]; then echo "$(CATEGORIES)" | sed 's/,/, /g'; else echo ""; fi); \
	{
	  printf '%%s\n' \
	    '---' \
	    'title: "$(TITLE)"' \
	    "date: \"$${date}\"" \
	    'draft: true' \
	    "categories: [$${categories}]" \
	    'format:' \
	    '  html:' \
	    '    toc: true' \
	    '    code-fold: true' \
	    'execute:' \
	    '  cache: true' \
	    '---' \
	    '' \
	    '## $(TITLE)' \
	    '' \
	    'Start writing here...'; \
	} > "$$dir/index.qmd"
	@echo "✅ Created $$dir/index.qmd (draft)"

page:
ifndef NAME
		$(error You must provide a NAME, e.g. make page NAME=about)
endif
		@file=$(NAME).qmd; \
		if [ -f "$$file" ]; then \
			echo "Error: file $$file already exists!"; exit 1; \
		fi; \
		echo "Creating page $$file"; \
		{
			printf '%%s\n' \
				'---' \
				"title: \"$(shell echo $(NAME) | sed 's/.*/\u&/')\"" \
				'format: html' \
				'---' \
				'' \
				'<!-- Page content starts here -->'; \
		} > "$$file"
		@echo "✅ Created $$file"

clean:
	@echo "Cleaning rendered output..."; \
	rm -rf _site _cache _freeze; \
	echo "✅ Done."

publish:
	quarto render; \
	git add .; \
	git commit -m "Publishing updates: $$(date '+%Y-%m-%d %H:%M')" || echo "No changes to commit"; \
	git push origin main