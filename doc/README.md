# changelog-scraper(1)

## NAME
`changelog-scraper` - a HTML scraper that prints changelogs from [`git(1)`](https://linux.die.net/man/1/git) websites

## SYNOPSIS
```shell
changelog-scraper -u URL [options]
changelog-scraper --url URL [options]
```

## DESCRIPTION
`changelog-scraper` is a web scraper that takes a URL and a set of options and prints a changelog of [`git(1)`](https://linux.die.net/man/1/git) commits into the terminal. It supports different outputs and service providers, such as GitHub.

**The output of the `pipe` printer is designed to be piped to external text-processing tools. It is not designed to be read by humans.** This makes the program flexible, because it removes the need to modify the source code. Instead, an external formatting program like [`awk(1)`](https://linux.die.net/man/1/awk) should be used to format the output according to the user's needs.

## OPTIONS
Options can be taken in short form (such as `-v`) and in long form (such as `--verbose`). For the most updated list of options and their possible values, run the `changelog-scraper` command with the help option.

|SHORT|LONG|DESCRIPTION|
|-|-|-|
|`-v`|`--[no-]verbose`|Run this script with or without verbose output. Since the output of this script can be piped to other tools, the verbose output is directed to `STDERR`. Verbose output is disabled by default.|
|`-q`|`--[no-]quiet`|Run this script without output. Errors and warnings will never be disabled by this option. Since the output of this script can be piped to other tools, the non-verbose output is directed to `STDERR`. Non-verbose output is enabled by default.|
|`-u`|`--url URL`|Use the `URL` as the source of the changelog. The script will verify the URL and will reject any malformed or not supported URL. **This option is mandatory**.|
|`-p`|`--printer PRINTER`|The selected `PRINTER` will be used. If omitted, the `interactive` printer will be used by default.
|`-h`|`--help`|Show a help message and exit|

## INTERACTIVE COMMANDS
The `interactive` printer is built with [`curses(3)`](https://linux.die.net/man/3/curses). Use the following commands to navigate through the changelog.

|KEY|DESCRIPTION|
|-|-|
|`[ARROW]`|Use the up arrow and down arrow to move through the list of commits in the main menu.|
|`ESC`|This key will exit the interactive window when pressed twice in the main menu.|

## PIPE FORMATTER
The pipe formatter is a characteristic of the `pipe` printer that allows users to pipe the output to text processing tools, such as [`awk(1)`](https://linux.die.net/man/1/awk), [`sed(1)`](https://linux.die.net/man/1/sed) or [`perl(1)`](https://linux.die.net/man/1/perl) scripts or one-liners.

The `pipe` output is separated by invisible [`ascii(7)`](https://linux.die.net/man/7/ascii) characters. More precisely, they are separated by the **GS** (group separator: `0x1d`) character. There is one placed at the beginning, one between fields and one at the end of the string, followed by one new line character.

Most terminals do not print the invisible control characters, some of them may print these characters as their hexadecimal code. If that is the case, the output may look like this: `\x1d0\x1dCommit subject\x1d\n`.

This character is intended to be a field separator for tools like [`awk(1)`](https://linux.die.net/man/1/awk). Take this small one-liner as an example:
```shell
changelog-scraper -u [url] -q | awk -F'\\x1d' '{printf "#%3d:\t%s\n", $2 + 1, $3}'
```

The `pipe` output is limited to a counter in the first field, that starts from 0, and the commit subject in the second field.

## AUTHORS
Oever González ⟨ notengobattery@gmail.com ⟩

## SEE ALSO
[`awk(1)`](https://linux.die.net/man/1/awk), [`sed(1)`](https://linux.die.net/man/1/sed), [`perl(1)`](https://linux.die.net/man/1/perl), [`git(1)`](https://linux.die.net/man/1/git), [`ruby(1)`](https://linux.die.net/man/1/ruby)

## AVAILABILITY
This program is available at GitHub. Instructions for preparing and running it are available. Visit ⟨ https://github.com/NoTengoBattery/changelog-scraper ⟩ for more information. **This program is designed as a UNIX tool**, and as such, you can expect it to not work correctly when used with the Native Ruby Installer for Windows. **It will work in MinGW and WSL.**
