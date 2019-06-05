SHELL:=/bin/bash

NAME=$(shell cat NAME)
VERSION=$(shell cat VERSION)
BOOTSTRAPDIR=$(NAME)-bootstrap-$(VERSION)

.DEFAULT: all
.PHONY: all prepare build package-bootstrap copy-sources

all: copy-sources

prepare:
	@echo '[Prepare]'
	rm -rf $(NAME)-$(VERSION) $(BOOTSTRAPDIR) obs
	mkdir $(NAME)-$(VERSION) $(BOOTSTRAPDIR) obs
	tar -C $(NAME)-$(VERSION) --strip-components=1 -xf $(NAME)-$(VERSION).tar.xz
	patch -d $(NAME)-$(VERSION) -p1 <$(NAME)-*.patch

build: prepare
	@echo '[Build]'
	( \
	cd $(NAME)-$(VERSION) && \
	./gradlew \
		--gradle-user-home /tmp/gradle --project-cache-dir /tmp/gradle-project \
		-xtest -xcheck \
		-xpmdMain -xpmdTest \
		-xcheckstyleGpl -xcheckstyleMain -xcheckstyleNonfree -xcheckstyleTest \
		build \
	)
	mv /tmp/gradle* $(BOOTSTRAPDIR)

package-bootstrap: build
	@echo '[Package bootstrap]'
	find $(BOOTSTRAPDIR) -type d -exec chmod ugo+rx '{}' \;
	find $(BOOTSTRAPDIR) -type f -exec chmod ugo+r '{}' \;
	tar -cJf obs/$(BOOTSTRAPDIR).tar.xz $(BOOTSTRAPDIR)

copy-sources: package-bootstrap
	@echo '[Copy sources]'
	for specfile in $(NAME){,-bootstrap}.spec.m4; do \
		m4 -D__NAME__=$(NAME) -D__VERSION__=$(VERSION) $$specfile >obs/$${specfile//.m4}; \
	done
	cp $(NAME)-*.patch $(NAME)-$(VERSION).tar.xz obs
