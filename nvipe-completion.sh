# shellcheck shell=bash
_generate_neovipe_completions() {
	local idx="${1}"
	shift
	local words=("${@}")
	local current_word=${words[idx]}

	local array=(
		"--help: Prints help text for NeoVipe."
		"-h: Prints help text for NeoVipe."
		"--version: Prints the current version of NeoVipe."
		"-v: Prints the current version of NeoVipe."
		"--template: Specify template for naming temporary file buffer."
		"-t: Specify template for naming temporary file buffer."
		"--pipe-without-saving: If present, exiting \$EDITOR without saving doesn't emit an error."
		"-p: If present, exiting \$EDITOR without saving doesn't emit an error."
		"--output-file-name: If present, outputs temporary file name instead of contents."
		"-x: If present, outputs temporary file name instead of contents."
		"--delimiter: Sets the delimiter emitted after filename when used in conjunction with file name output mode."
		"-d: Sets the delimiter emitted after filename when used in conjunction with file name output mode."
	)
	for elem in "${array[@]}"; do
		if [[ "${elem}" == "${current_word}"* ]]; then printf "%s\n" "${elem}"; fi
	done
}

_complete_neovipe_bash() {
	local IFS=$'\n'
	local raw=($(_generate_neovipe_completions "${COMP_CWORD}" "${COMP_WORDS[@]}"))
	local trimmed=()
	trimmed+=("${raw[@]}")

	if ((${#raw[@]} == 1)); then
		trimmed+=("${raw[0]%%:*}")
	fi

	if ((COMP_CWORD == 1)); then
		COMPREPLY=("${trimmed[@]}")
	else
		COMPREPLY=()
	fi
}

_complete_neovipe_zsh() {
	local -a raw trimmed
	local IFS=$'\n'
	raw=($(_generate_neovipe_completions "${CURRENT}" "${words[@]}"))

	for d in ${raw}; do trimmed+=("${d%%:*}"); done
	if ((${#raw} == 1)); then
		trimmed+=("${raw[1]}")
		raw+=("${trimmed[1]}")
	fi

	compadd -d raw -- "${trimmed}"
}

if [[ -n "${ZSH_VERSION:-}" ]]; then
	autoload -Uz compinit
	compinit
	compdef _complete_neovipe_zsh nvipe
elif [[ -n "${BASH_VERSION:-}" ]]; then
	complete -o bashdefault -o default -F _complete_neovipe_bash nvipe
fi

# vim: set filetype=bash:
