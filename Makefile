SHELL := /usr/bin/env sh

INSTALL ?= install
PREFIX ?= /usr/local
BASH_COMP_DIR := $(shell pkg-config --variable=completionsdir bash-completion 2>/dev/null)
ifeq ($(BASH_COMP_DIR),)
    BASH_COMP_DIR = /usr/share/bash-completion/completions
endif
ZSH_COMP_DIR ?= $(PREFIX)/share/zsh/site-functions
MANDIR ?= $(PREFIX)/share/man
MAN1DIR = $(MANDIR)/man1

.PHONY: all clean default info install install-nvipe install-nvipe-info uninstall

default: all

all: info

clean:
ifneq ($(wildcard docs/*.1.gz),)
	@printf "Cleaning up man pages.\n"
	@$(RM) docs/*.1.gz
else
	@printf "No man pages to clean.\n"
endif


info:
	@help2man ./nvipe -o docs/nvipe.1
	@gzip docs/nvipe.1

install: install-nvipe install-nvipe-info

install-nvipe:
	@printf "Installing NeoVipe to %s/bin...\n" $(DESTDIR)$(PREFIX)
	@$(INSTALL) -Dm 755 nvipe $(DESTDIR)$(PREFIX)/bin/nvipe

install-nvipe-info: docs/nvipe.1.gz
	@printf "Installing NeoVipe bash completion to %s...\n" $(DESTDIR)$(BASH_COMP_DIR)
	@$(INSTALL) -Dm 644 docs/nvipe-completion $(DESTDIR)$(BASH_COMP_DIR)/nvipe
	@printf "Installing NeoVipe zsh completion to %s...\n" $(DESTDIR)$(ZSH_COMP_DIR)
	@$(INSTALL) -Dm 644 docs/nvipe-completion $(DESTDIR)$(ZSH_COMP_DIR)/_nvipe
	@printf "Installing NeoVipe man page to %s...\n" $(DESTDIR)$(MAN1DIR)
	@$(INSTALL) -Dm 644 docs/nvipe.1.gz $(DESTDIR)$(MAN1DIR)/nvipe.1.gz
	-@mandb > /dev/null 2>&1

uninstall:
	@printf "Uninstalling NeoVipe from %s/bin...\n" $(DESTDIR)$(PREFIX)
	@printf "Uninstalling NeoVipe documentation from %s...\n" $(DESTDIR)$(PREFIX)
	@$(RM) $(DESTDIR)$(PREFIX)/bin/nvipe
	@$(RM) $(DESTDIR)$(BASH_COMP_DIR)/nvipe
	@$(RM) $(DESTDIR)$(ZSH_COMP_DIR)/_nvipe
	@$(RM) $(DESTDIR)$(MAN1DIR)/nvipe.1.gz
	-@mandb > /dev/null 2>&1
