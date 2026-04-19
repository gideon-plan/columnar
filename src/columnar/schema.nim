## schema.nim -- Schema definition types for Arrow/Parquet.

{.experimental: "strict_funcs".}

type
  ColumnKind* {.pure.} = enum
    Bool, Int8, Int16, Int32, Int64,
    Uint8, Uint16, Uint32, Uint64,
    Float32, Float64, Utf8, Binary,
    List, Struct

  ColumnKind* = distinct string

  ColumnDef* = object
    name*: string
    col_kind*: ColumnKind
    nullable*: bool
    children*: seq[ColumnDef]  ## For list/struct

  Schema* = object
    fields*: seq[ColumnDef]

proc `==`*(a, b: ColumnKind): bool {.borrow.}
proc `$`*(ck: ColumnKind): string {.borrow.}

proc to_column_type*(ck: ColumnKind): ColumnKind =
  case string(ck)
  of "bool": ColumnKind.Bool
  of "int8": ColumnKind.Int8
  of "int16": ColumnKind.Int16
  of "int32": ColumnKind.Int32
  of "int", "int64": ColumnKind.Int64
  of "uint8": ColumnKind.Uint8
  of "uint16": ColumnKind.Uint16
  of "uint32": ColumnKind.Uint32
  of "uint64": ColumnKind.Uint64
  of "float32": ColumnKind.Float32
  of "float", "float64": ColumnKind.Float64
  of "string", "utf8": ColumnKind.Utf8
  of "binary", "bytes": ColumnKind.Binary
  of "list": ColumnKind.List
  of "struct": ColumnKind.Struct
  else: ColumnKind.Utf8

proc kind_of*(ct: ColumnKind): ColumnKind =
  case ct
  of ColumnKind.Bool: ColumnKind("bool")
  of ColumnKind.Int8: ColumnKind("int8")
  of ColumnKind.Int16: ColumnKind("int16")
  of ColumnKind.Int32: ColumnKind("int32")
  of ColumnKind.Int64: ColumnKind("int64")
  of ColumnKind.Uint8: ColumnKind("uint8")
  of ColumnKind.Uint16: ColumnKind("uint16")
  of ColumnKind.Uint32: ColumnKind("uint32")
  of ColumnKind.Uint64: ColumnKind("uint64")
  of ColumnKind.Float32: ColumnKind("float32")
  of ColumnKind.Float64: ColumnKind("float64")
  of ColumnKind.Utf8: ColumnKind("string")
  of ColumnKind.Binary: ColumnKind("binary")
  of ColumnKind.List: ColumnKind("list")
  of ColumnKind.Struct: ColumnKind("struct")

proc column*(name: string, ck: ColumnKind, nullable: bool = true): ColumnDef =
  ColumnDef(name: name, col_kind: ck, nullable: nullable)

proc column*(name: string, ct: ColumnKind, nullable: bool = true): ColumnDef =
  column(name, kind_of(ct), nullable)

proc schema*(fields: varargs[ColumnDef]): Schema =
  Schema(fields: @fields)

proc field_count*(s: Schema): int = s.fields.len

proc field_names*(s: Schema): seq[string] =
  for f in s.fields: result.add(f.name)
