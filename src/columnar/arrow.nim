## arrow.nim -- Arrow IPC format types and record batch abstraction.

{.experimental: "strict_funcs".}

import schema

type
  ColumnData* = object
    ## A single column of data.
    null_bitmap*: seq[bool]  ## true = valid, false = null
    values_int*: seq[int64]
    values_float*: seq[float64]
    values_str*: seq[string]
    values_bool*: seq[bool]
    col_kind*: ColumnKind

  RecordBatch* = object
    schema*: Schema
    columns*: seq[ColumnData]
    row_count*: int

proc new_record_batch*(s: Schema, row_count: int): RecordBatch =
  var cols: seq[ColumnData]
  for f in s.fields:
    cols.add(ColumnData(col_kind: f.col_kind))
  RecordBatch(schema: s, columns: cols, row_count: row_count)

proc add_int_column*(rb: var RecordBatch, col_idx: int, values: seq[int64]) =
  rb.columns[col_idx].values_int = values
  rb.columns[col_idx].null_bitmap = newSeq[bool](values.len)
  for i in 0 ..< values.len: rb.columns[col_idx].null_bitmap[i] = true

proc add_str_column*(rb: var RecordBatch, col_idx: int, values: seq[string]) =
  rb.columns[col_idx].values_str = values
  rb.columns[col_idx].null_bitmap = newSeq[bool](values.len)
  for i in 0 ..< values.len: rb.columns[col_idx].null_bitmap[i] = true

proc add_float_column*(rb: var RecordBatch, col_idx: int, values: seq[float64]) =
  rb.columns[col_idx].values_float = values
  rb.columns[col_idx].null_bitmap = newSeq[bool](values.len)
  for i in 0 ..< values.len: rb.columns[col_idx].null_bitmap[i] = true

proc get_int*(rb: RecordBatch, col_idx, row_idx: int): int64 =
  rb.columns[col_idx].values_int[row_idx]

proc get_str*(rb: RecordBatch, col_idx, row_idx: int): string =
  rb.columns[col_idx].values_str[row_idx]

proc get_float*(rb: RecordBatch, col_idx, row_idx: int): float64 =
  rb.columns[col_idx].values_float[row_idx]
