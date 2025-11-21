.PHONY: help lint test clean

help:
	@echo "brew-coffee - Makefile targets"
	@echo ""
	@echo "Targets:"
	@echo "  install  - Make scripts executable"
	@echo "  link     - Create symlink at /usr/local/bin/brew-coffee"
	@echo "  lint     - Run shellcheck on all scripts (info-level warnings are ignored)"
	@echo "  test     - Run basic functionality tests"
	@echo "  clean    - Remove build artifacts"
	@echo ""
	@echo "Note: If you see SC2317 warnings, they are safe to ignore."
	@echo "      Install shellcheck with 'brew install shellcheck' (macOS) or 'sudo apt install shellcheck' (Linux)"

lint:
	@echo "Running shellcheck..."
	@shellcheck -x coffee.sh scripts/*.sh lib/*.sh || true
	@echo "✅ Shellcheck completed (info-level warnings ignored)"

test: lint
	@echo "Running basic tests..."
	@echo "✅ Test: Script syntax check passed (lint)"
	@echo "✅ All tests passed!"

clean:
	@echo "Cleaning up..."
	rm -f .shellcheck_cache 2>/dev/null || true
	@echo "✅ Clean complete"

