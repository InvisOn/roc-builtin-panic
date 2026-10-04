# `getExternalTypeBase` panic with an ancestor `main.roc`

`roc check` and `roc docs` panic on `sub/Builtin.roc` when a `main.roc` exists
in the same directory or any directory above it:

```
$ roc check sub/Builtin.roc
thread … panic: getExternalTypeBase: type not found in scope or auto-imports
Cannot print stack trace: stack tracing is disabled
```

Without `main.roc` the same command reports `No errors found`.

Seen on `nightly-2026-10-03-c507926` (`release-fast-c5079264`) and
`nightly-2026-09-18-1d982dc`, linux_x86_64.

## Run

```sh
./repro.sh
```

It runs `roc check sub/Builtin.roc` with `main.roc` present, then again with it
renamed away. If another `main.roc` sits in a directory above this repo, the
second run panics too, and the script warns about it.

## What triggers it

All of these are required; changing any one makes the panic go away:

- the file is `Builtin.roc` (the same contents as `Foo :: [].{ Str :: [ProvidedByCompiler].{} }` in `Foo.roc` are fine)
- the nested type is named `Str` (`Thing :: [ProvidedByCompiler].{}` is fine)
- its backing is `[ProvidedByCompiler]` (`Str :: [A].{}` is fine)
- a non-empty `main.roc` is in the file's directory or an ancestor (an empty
  `main.roc`, or one named `app.roc`, does not trigger it)

`roc docs sub/Builtin.roc` panics the same way, with or without `--no-cache`.

## Why it matters

The roc-lang.org website build runs
`roc docs --no-cache <roc-src>/src/build/roc/Builtin.roc --with-lang-ref`.
That panics whenever any directory above the Roc source checkout contains a
`main.roc`, e.g. a stray `/tmp/main.roc` with the checkout under `/tmp`.

## Related

Checking or documenting an unrelated module also reports compile errors from an
ancestor `main.roc` that the module never imports. The commands appear to treat
the nearest ancestor `main.roc` as the app root. That would pull `Builtin.roc`
into an ordinary app build, where its `Str` collides with the real builtin `Str`.
