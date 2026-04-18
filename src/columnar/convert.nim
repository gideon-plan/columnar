## convert.nim -- Conversion between Arrow record batches and Nim tables.

{.experimental: "strict_funcs".}

import std/[strutils, tables]

type
  ColumnarError* = object of CatchableError

import basis/code/choice, schema, arrow

proc to_table*(rb: RecordBatch): seq[Table[string, string]] =
  ## Convert a record batch to a sequence of string-valued row tables.
  let names = rb.schema.field_names()
  for row in 0 ..< rb.row_count:
    var t: Table[string, string]
    for col in 0 ..< rb.schema.field_count():
      let ct = to_column_type(rb.columns[col].col_kind)
      case ct
      of ctInt8, ctInt16, ctInt32, ctInt64:
        if row < rb.columns[col].values_int.len:
          t[names[col]] = $rb.columns[col].values_int[row]
      of ctFloat32, ctFloat64:
        if row < rb.columns[col].values_float.len:
          t[names[col]] = $rb.columns[col].values_float[row]
      of ctUtf8:
        if row < rb.columns[col].values_str.len:
          t[names[col]] = rb.columns[col].values_str[row]
      of ctBool:
        if row < rb.columns[col].values_bool.len:
          t[names[col]] = $rb.columns[col].values_bool[row]
      else:
        discard
    result.add(t)

proc from_table*(s: Schema, rows: seq[Table[string, string]]
                ): Choice[RecordBatch] =
  ## Convert row tables to a record batch.
  var rb = new_record_batch(s, rows.len)
  for col_idx in 0 ..< s.field_count():
    let f = s.fields[col_idx]
    case to_column_type(f.col_kind)
    of ctInt8, ctInt16, ctInt32, ctInt64:
      var vals: seq[int64]
      for row in rows:
        if f.name in row:
          try: vals.add(int64(parseInt(row[f.name])))
          except ValueError:
            return bad[RecordBatch]("columnar", "invalid int: " & row[f.name])
        else:
          vals.add(0)
      add_int_column(rb, col_idx, vals)
    of ctFloat32, ctFloat64:
      var vals: seq[float64]
      for row in rows:
        if f.name in row:
          try: vals.add(parseFloat(row[f.name]))
          except ValueError:
            return bad[RecordBatch]("columnar", "invalid float: " & row[f.name])
        else:
          vals.add(0.0)
      add_float_column(rb, col_idx, vals)
    of ctUtf8:
      var vals: seq[string]
      for row in rows:
        vals.add(row.getOrDefault(f.name, ""))
      add_str_column(rb, col_idx, vals)
    else:
      discard
  good(rb)
