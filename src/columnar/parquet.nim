## parquet.nim -- Parquet file types and abstraction.
##
## Row groups, column chunks, page encoding definitions.

{.experimental: "strict_funcs".}

import schema

type
  Encoding* {.pure.} = enum
    Plain, Rle, Delta, Dictionary

  CompressionCodec* {.pure.} = enum
    None, Snappy, Gzip, Lz4, Zstd

  PageHeader* = object
    encoding*: Encoding
    num_values*: int
    uncompressed_size*: int
    compressed_size*: int

  ColumnChunk* = object
    col_def*: ColumnDef
    encoding*: Encoding
    compression*: CompressionCodec
    num_values*: int
    data*: string  ## Encoded page data

  RowGroup* = object
    columns*: seq[ColumnChunk]
    num_rows*: int

  ParquetFile* = object
    schema*: Schema
    row_groups*: seq[RowGroup]
    created_by*: string

proc new_parquet_file*(s: Schema, created_by: string = "gideon/columnar"): ParquetFile =
  ParquetFile(schema: s, created_by: created_by)

proc add_row_group*(pf: var ParquetFile, rg: RowGroup) =
  pf.row_groups.add(rg)

proc total_rows*(pf: ParquetFile): int =
  for rg in pf.row_groups: result += rg.num_rows
