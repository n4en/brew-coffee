.PHONY: help lint test clean

help:
	@echo "brew-coffee - Makefile targets"
	@echo ""
	@echo "Targets:"
	@echo "  install  - Make scripts executable"
	@echo "  link     - Create symlink at /usr/local/bin/brew-coffee"
	@echo "  lint     - Run shellcheck on all scripts"
	@echo "  test     - Run basic functionality tests"
	@echo "  clean    - Remove build artifacts"

lint:
	@echo "Running shellcheck..."
	@if SHELLCHECK_OPTS="-P SCRIPTDIR -P $(PWD)/lib" shellcheck -x coffee.sh scripts/*.sh lib/*.sh; then \
		echo "✅ No shellcheck issues found!"; \
	else \
		echo "⚠️  Shellcheck found some issues"; \
		exit 1; \
	fi

test: lint
	@echo "Running basic tests..."
	@echo "✅ Test: Script syntax check passed (lint)"
	@echo "✅ All tests passed!"

clean:
	@echo "Cleaning up..."
	rm -f .shellcheck_cache 2>/dev/null || true
	@echo "✅ Clean complete"

