# Phantom

Phantom is a <a href="https://spectrelang.org">Spectre</a> debugger with a native (DWARF, Linux x86_64) and LLDB backend.

## Run

```sh
phantom debug ./src/main.sx -backend native
phantom debug ./src/main.sx -backend lldb
phantom debug ./path/to/binary -backend native -- arg1 arg2
```

A `.sx` input is compiled automatically with the ALT backend. Use
`-compiler <path>` or `PHANTOM_COMPILER` to select the Spectre compiler.

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

Breakpoints accept demangled names such as `main`, `parser::parse_expr`, or
`make_list<i32>`, as well as `file.sx:42`. Variable expressions use Spectre
source names (`sum`, `point.x`, `items[2]`); Phantom translates them back to
the compiler's internal `t_` / `sx__` names where needed.

## Symbol inspection

```sh
phantom-dev symbols ./binary [query]
phantom-dev lines ./binary [file:line]
phantom-dev variables ./binary [function]
```

Symbol names are shown demangled, e.g.:

```text
std::stdio::print
generic_id<i32>
```

## DAP

```sh
phantom-dev dap --backend native
phantom-dev dap --backend lldb --program ./path/to/binary
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
"miDebuggerPath": "${workspaceFolder}/phantom-dev",
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
