.PHONY: lint test check

lint:
	shellcheck keybars.tmux scripts/* tests/*.sh

test:
	sh tests/plugin_test.sh
	sh tests/rules_test.sh

check: lint test
