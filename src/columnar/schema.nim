## schema.nim -- Schema definition types for Arrow/Parquet.

{.experimental: "strict_funcs".}

type
  ColumnType* = enum
    ctBool, ctInt8, ctInt16, ctInt32, ctInt64,
    ctUint8, ctUint16, ctUint32, ctUint64,
    ctFloat32, ctFloat64, ctUtf8, ctBinary,
    ctList, ctStruct

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
  of "bool": ctBool
  of "int8": ctInt8
  of "int16": ctInt16
  of "int32": ctInt32
  of "int", "int64": ctInt64
  of "uint8": ctUint8
  of "uint16": ctUint16
  of "uint32": ctUint32
  of "uint64": ctUint64
  of "float32": ctFloat32
  of "float", "float64": ctFloat64
  of "string", "utf8": ctUtf8
  of "binary", "bytes": ctBinary
  of "list": ctList
  of "struct": ctStruct
  else: ctUtf8

proc kind_of*(ct: ColumnType): ColumnKind =
  case ct
  of ctBool: ColumnKind("bool")
  of ctInt8: ColumnKind("int8")
  of ctInt16: ColumnKind("int16")
  of ctInt32: ColumnKind("int32")
  of ctInt64: ColumnKind("int64")
  of ctUint8: ColumnKind("uint8")
  of ctUint16: ColumnKind("uint16")
  of ctUint32: ColumnKind("uint32")
  of ctUint64: ColumnKind("uint64")
  of ctFloat32: ColumnKind("float32")
  of ctFloat64: ColumnKind("float64")
  of ctUtf8: ColumnKind("string")
  of ctBinary: ColumnKind("binary")
  of ctList: ColumnKind("list")
  of ctStruct: ColumnKind("struct")

proc column*(name: string, ck: ColumnKind, nullable: bool = true): ColumnDef =
  ColumnDef(name: name, col_kind: ck, nullable: nullable)

proc column*(name: string, ct: ColumnType, nullable: bool = true): ColumnDef =
  column(name, kind_of(ct), nullable)

proc schema*(fields: varargs[ColumnDef]): Schema =
  Schema(fields: @fields)

proc field_count*(s: Schema): int = s.fields.len

proc field_names*(s: Schema): seq[string] =
  for f in s.fields: result.add(f.name)
