# Neovipe
A modern rework of vipe, turning `$EDITOR` into a pipe friendly tool.

Allows for piping in and out of `$EDITOR` even if it doesn't normally support pipes.
```bash
echo "change me" > "my_input.txt"
	head -n 1 "my_input.txt" | cut -f 1 | nvipe > "my_output.txt"
	cat "my_output.txt"
	This text could be changed to anything you wanted it to be in your editor.
```

# Installation
Just copy nvipe into your `$PATH`, make it executable, and you're all set.
- GNU getopt is required.

# Features
In it's latest incarnation Neovipe offers the following on top of its base functionality:
- Fallback to `vi` if `$EDITOR` is unspecified.
- Secure temporary file creation using `mktemp` (or at least more secure, see [here](https://www.gnu.org/software/coreutils/manual/html_node/mktemp-invocation.html) for caveats).
  - `$TMPDIR` is respected if it has been set in the environment.
  - Specify a template filename with `-t` or `--template`, defaults to `nvipe.XXXXXXXXXXXXXXXX` if unspecified.
- Piping to stdout only continues if the file is saved in `$EDITOR`, otherwise an error is raised.
  - This behavior can be overriden by invoking Neovipe with the `-p` or `--pipe-without-save` flags, though changes made in `$EDITOR` do not persist unless the file is saved.

# Origin
Neovipe is adapted and updated from the following sources:
- The work of Julian Gruber at https://github.com/juliangruber/vipe under the terms of the MIT License.
- The work of Joey Hess at https://github.com/madx/moreutils/blob/master/vipe under the terms of the GNU General Public License version 2.0.

# License
Neovipe is licensed under the terms of the [GNU General Public License version 2.0](https://github.com/jBeale23/neovipe/blob/main/LICENSE).
