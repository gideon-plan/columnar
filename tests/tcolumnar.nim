## tcolumnar.nim -- Tests for columnar I/O.
{.experimental: "strict_funcs".}
import std/[unittest, tables]
import columnar

suite "schema":
  test "create schema":
    let s = schema(column("id", ColumnKind.Int64), column("name", ColumnKind.Utf8))
    check s.field_count == 2
    check s.field_names == @["id", "name"]

suite "arrow":
  test "record batch create and access":
    let s = schema(column("id", ColumnKind.Int64), column("name", ColumnKind.Utf8))
    var rb = new_record_batch(s, 3)
    add_int_column(rb, 0, @[1'i64, 2, 3])
    add_str_column(rb, 1, @["alice", "bob", "carol"])
    check get_int(rb, 0, 0) == 1
    check get_str(rb, 1, 2) == "carol"

  test "float column":
    let s = schema(column("val", ColumnKind.Float64))
    var rb = new_record_batch(s, 2)
    add_float_column(rb, 0, @[1.5, 2.5])
    check get_float(rb, 0, 1) == 2.5

suite "parquet":
  test "parquet file structure":
    let s = schema(column("x", ColumnKind.Int64))
    var pf = new_parquet_file(s)
    let rg = RowGroup(num_rows: 100)
    pf.add_row_group(rg)
    check pf.total_rows == 100
    check pf.row_groups.len == 1

suite "convert":
  test "record batch to table":
    let s = schema(column("id", ColumnKind.Int64), column("name", ColumnKind.Utf8))
    var rb = new_record_batch(s, 2)
    add_int_column(rb, 0, @[1'i64, 2])
    add_str_column(rb, 1, @["alice", "bob"])
    let rows = to_table(rb)
    check rows.len == 2
    check rows[0]["id"] == "1"
    check rows[1]["name"] == "bob"

  test "table to record batch":
    let s = schema(column("id", ColumnKind.Int64), column("name", ColumnKind.Utf8))
    var rows: seq[Table[string, string]]
    rows.add({"id": "10", "name": "test"}.toTable)
    let result = from_table(s, rows)
    check result.is_good
    check get_int(result.val, 0, 0) == 10
    check get_str(result.val, 1, 0) == "test"

  test "round-trip table -> batch -> table":
    let s = schema(column("x", ColumnKind.Int64), column("y", ColumnKind.Float64))
    var rows: seq[Table[string, string]]
    rows.add({"x": "42", "y": "3.14"}.toTable)
    let batch = from_table(s, rows)
    check batch.is_good
    let back = to_table(batch.val)
    check back.len == 1
    check back[0]["x"] == "42"
