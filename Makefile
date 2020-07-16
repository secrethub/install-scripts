SC_EXCLUDES="SC2034,SC2086,SC2059,SC2046"

lint:
	@docker run -v $$(pwd):/src -w /src koalaman/shellcheck-alpine shellcheck --shell sh --exclude ${SC_EXCLUDES} cli_unix.sh
