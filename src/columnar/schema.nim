## schema.nim -- Schema definition types for Arrow/Parquet.

{.experimental: "strict_funcs".}

type
  ColumnType* {.pure.} = enum
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

proc to_column_type*(ck: ColumnKind): ColumnType =
  case string(ck)
  of "bool": ColumnType.Bool
  of "int8": ColumnType.Int8
  of "int16": ColumnType.Int16
  of "int32": ColumnType.Int32
  of "int", "int64": ColumnType.Int64
  of "uint8": ColumnType.Uint8
  of "uint16": ColumnType.Uint16
  of "uint32": ColumnType.Uint32
  of "uint64": ColumnType.Uint64
  of "float32": ColumnType.Float32
  of "float", "float64": ColumnType.Float64
  of "string", "utf8": ColumnType.Utf8
  of "binary", "bytes": ColumnType.Binary
  of "list": ColumnType.List
  of "struct": ColumnType.Struct
  else: ColumnType.Utf8

proc kind_of*(ct: ColumnType): ColumnKind =
  case ct
  of ColumnType.Bool: ColumnKind("bool")
  of ColumnType.Int8: ColumnKind("int8")
  of ColumnType.Int16: ColumnKind("int16")
  of ColumnType.Int32: ColumnKind("int32")
  of ColumnType.Int64: ColumnKind("int64")
  of ColumnType.Uint8: ColumnKind("uint8")
  of ColumnType.Uint16: ColumnKind("uint16")
  of ColumnType.Uint32: ColumnKind("uint32")
  of ColumnType.Uint64: ColumnKind("uint64")
  of ColumnType.Float32: ColumnKind("float32")
  of ColumnType.Float64: ColumnKind("float64")
  of ColumnType.Utf8: ColumnKind("string")
  of ColumnType.Binary: ColumnKind("binary")
  of ColumnType.List: ColumnKind("list")
  of ColumnType.Struct: ColumnKind("struct")

proc column*(name: string, ck: ColumnKind, nullable: bool = true): ColumnDef =
  ColumnDef(name: name, col_kind: ck, nullable: nullable)

proc column*(name: string, ct: ColumnType, nullable: bool = true): ColumnDef =
  column(name, kind_of(ct), nullable)

proc schema*(fields: varargs[ColumnDef]): Schema =
  Schema(fields: @fields)

proc field_count*(s: Schema): int = s.fields.len

proc field_names*(s: Schema): seq[string] =
  for f in s.fields: result.add(f.name)
