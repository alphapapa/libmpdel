SRCS = libmpdel.el
TESTS = test/libmpdel-test.el

LOAD_PATH = -L .

LOAD_PATH += -L ../package-lint

EMACSBIN ?= emacs
BATCH     = $(EMACSBIN) -Q --batch $(LOAD_PATH) --eval "(setq load-prefer-newer t)"

.PHONY: all ci-dependencies check test lint

CURL = curl -fsSkL --retry 9 --retry-delay 9
GITHUB=https://raw.githubusercontent.com

all: check

ci-dependencies:
	$(CURL) -O ${GITHUB}/purcell/package-lint/master/package-lint.el

check: test lint

test:
	$(BATCH) --eval "(progn\
	(load-file \"test/libmpdel-test.el\")\
	(ert-run-tests-batch-and-exit))"

lint :
	# Byte compile all and stop on any warning or error
	$(BATCH) \
	--eval "(setq byte-compile-error-on-warn t)" \
	-f batch-byte-compile ${SRCS} ${TESTS}

	# Run package-lint to check for packaging mistakes
	$(BATCH) \
	--eval "(require 'package)" \
	--eval "(require 'package-lint)" \
	-f package-lint-batch-and-exit ${SRCS}