# Choice/Life Adoption Plan: columnar

## Summary

- **Error type**: `ColumnarError` defined in lattice.nim -- move to `convert.nim`
- **Files to modify**: 2 + re-export module
- **Result sites**: 4
- **Life**: Not applicable

## Steps

1. Delete `src/columnar/lattice.nim`
2. Move `ColumnarError* = object of CatchableError` to `src/columnar/convert.nim`
3. Add `requires "basis >= 0.1.0"` to nimble
4. In every file importing lattice:
   - Replace `import.*lattice` with `import basis/code/choice`
   - Replace `Result[T, E].good(v)` with `good(v)`
   - Replace `Result[T, E].bad(e[])` with `bad[T]("columnar", e.msg)`
   - Replace `Result[T, E].bad(ColumnarError(msg: "x"))` with `bad[T]("columnar", "x")`
   - Replace return type `Result[T, ColumnarError]` with `Choice[T]`
5. Update re-export: `export lattice` -> `export choice`
6. Update tests
