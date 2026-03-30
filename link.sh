#!/usr/bin/env sh

set -eu

script_dir=$(cd "$(dirname "$0")" && pwd)

usage() {
	echo "Usage: $(basename "$0") <vault-path> [vault-path...]" >&2
}

link_target() {
	src=$1
	dest=$2
	ln -sfn "$src" "$dest"
}

if [ "$#" -eq 0 ]; then
	usage
	exit 1
fi

for vault in "$@"; do
	if [ ! -d "$vault" ]; then
		echo "Skipping '$vault' (not a directory)" >&2
		continue
	fi

	obsidian_dir="$vault/.obsidian"
	if [ ! -d "$obsidian_dir" ]; then
		echo "Skipping '$vault' (missing .obsidian directory)" >&2
		continue
	fi

	plugin_dir=""
	if [ -d "$obsidian_dir/plugins/slides-extended" ]; then
		plugin_dir="$obsidian_dir/plugins/slides-extended"
	elif [ -d "$obsidian_dir/plugins/obsidian-advanced-slides" ]; then
		plugin_dir="$obsidian_dir/plugins/obsidian-advanced-slides"
	else
		echo "Skipping '$vault' (neither slides-extended nor obsidian-advanced-slides found)" >&2
		continue
	fi

	css_dir="$plugin_dir/css/catppuccin"
	hl_dir="$plugin_dir/css/highlightjs/catppuccin"

	mkdir -p "$css_dir" "$hl_dir"

	link_target "$script_dir/common.css" "$css_dir/common.css"
	link_target "$script_dir/frappe.css" "$css_dir/frappe.css"
	link_target "$script_dir/latte.css" "$css_dir/latte.css"
	link_target "$script_dir/fonts" "$css_dir/fonts"

	if [ -d "$script_dir/highlightjs" ]; then
		for src in "$script_dir"/highlightjs/*; do
			[ -e "$src" ] || continue
			name=$(basename "$src")
			link_target "$src" "$hl_dir/$name"
		done
	fi

	echo "Linked Catppuccin assets into $vault ($(basename "$plugin_dir"))"
done
