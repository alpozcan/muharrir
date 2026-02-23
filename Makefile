PREFIX ?= /usr/local

.PHONY: build release install uninstall clean test lint run

build:
	swift build

release:
	swift build -c release

install: build
	cp .build/debug/yazman $(PREFIX)/bin/yazman

install-release: release
	cp .build/release/yazman $(PREFIX)/bin/yazman

uninstall:
	rm -f $(PREFIX)/bin/yazman

clean:
	swift package clean

test:
	swift test

lint:
	swiftlint lint --strict

run:
	swift run yazman

log:
	log stream --predicate 'subsystem == "dev.yazman.cli"' --level debug
