# Phantom

Phantom is a <a href="https://spectrelang.org">Spectre</a> debugger with a native (DWARF, Linux x86_64) and LLDB backend.

## Quick start

Given `hi.sx`:

```sx
val stdio = use("std/stdio")

pub fn main() void = {
    val xs: [_]ref u8 = [
        "hello", "world", "this", "is", "a", "test"
    ]
    for x in xs {
        trust stdio.print("{s}\n", {x})
    }
}
```

Start an interactive session (Phantom compiles `.sx` inputs with the ALT
backend automatically):

```sh
phantom debug hi.sx
```

Then, at the `(phantom)` prompt:

```text
break hi.sx:8
run
continue
locals
continue
```

The second stop is inside the loop, so `locals` can show the array contents:

```text
(int64_t / [_]ref u8) xs = ["hello", "world", "this", "is", "a", "test"]
```

The same session can be run non-interactively with `-batch`:

```sh
phantom debug hi.sx -batch \
    -ex 'break hi.sx:8' \
    -ex run \
    -ex continue \
    -ex locals \
    -ex continue
```

Commands can also be read from a file with `-x commands.txt`, or from stdin.
Batch mode prints only command output, without the banner or prompts.

## Run

```sh
phantom debug ./src/main.sx -backend native
phantom debug ./src/main.sx -backend lldb
phantom debug ./path/to/binary -backend native -- arg1 arg2
```

A `.sx` input is compiled automatically with the ALT backend. Use
`-compiler <path>` or `PHANTOM_COMPILER` to select the Spectre compiler.

### Batch mode

Run commands without entering the interactive prompt:

```sh
phantom debug ./path/to/binary -batch -ex 'break main' -ex run -ex backtrace
phantom debug ./path/to/binary -batch -x commands.txt
printf 'run\nbacktrace\n' | phantom debug ./path/to/binary -batch
```

Command files contain one debugger command per line; blank lines and lines
starting with `#` are ignored. Batch mode suppresses the banner and prompt and
exits when the commands finish.

The interactive commands include:

```text
run / r [args...]          start the program
continue / c               continue to the next breakpoint
break / b <func|file:line> set a breakpoint
info break                 list breakpoints
delete <id>                delete a breakpoint
locals / vars              show local variables using source names
print / p <expr>           evaluate an expression
watch <expr>               add to the watch list
unwatch <n>                remove a watch entry
backtrace / bt             show the call stack
list [line]                show source around the current line
quit / q                   quit
```

Breakpoints accept demangled names such as `main`, `parser.parse_expr`, or
`make_list[i32]`, as well as `file.sx:42`. Variable expressions use Spectre
source names (`sum`, `point.x`); Phantom translates them back to
the compiler's internal `t_` / `sx__` names where needed.

## Symbol inspection

```sh
phantom symbols ./binary [query]
phantom lines ./binary [file:line]
phantom variables ./binary [function]
```

Symbol names are shown demangled, e.g.:

```text
std.stdio.print
generic_id[i32]
```

## DAP

```sh
phantom dap -backend native
phantom dap -backend lldb -program ./path/to/binary
```

The server speaks DAP over stdin/stdout (`Content-Length` framing). A typical
editor launch configuration supplies the Spectre source file, for example:

```json
{
  "type": "phantom",
  "request": "launch",
  "name": "Debug Spectre",
  "program": "${workspaceFolder}/src/main.sx",
  "args": []
}
```

Run the adapter command with the backend you want:

```json
"debugServer": 0,
"miDebuggerPath": "${workspaceFolder}/phantom",
"miDebuggerArgs": ["dap", "-backend", "native"]
```

Supported requests include `initialize`, `launch`, `setBreakpoints`,
`setFunctionBreakpoints`, `configurationDone`, `threads`, `continue`,
`next` / `stepIn` / `stepOut` (LLDB only), `stackTrace`, `scopes`,
`variables`, `evaluate`, and `disconnect`.

## Native backend scope

The native backend currently supports:

- ELF64 symbol tables and DWARF 4/5 line tables
- function and source-line breakpoints
- software breakpoints via `ptrace` + `/proc/<pid>/mem`
- local variable reads, including struct fields and fixed-array indices
- a shallow frame-pointer backtrace

Not yet implemented natively: source-level stepping and full CFI-based
unwinding. Use the LLDB backend if those are really needed.

## Tests

Unit tests live next to the code they cover:

```sh
spectre src/demangle.sx -alt -test
spectre src/lldb.sx -alt -test
spectre src/cli.sx -alt -test
spectre src/main.sx -alt -test
```
