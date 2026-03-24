## schema.nim -- Schema definition types for Arrow/Parquet.

{.experimental: "strict_funcs".}

type
  ColumnType* = enum
    ctBool, ctInt8, ctInt16, ctInt32, ctInt64,
    ctUint8, ctUint16, ctUint32, ctUint64,
    ctFloat32, ctFloat64, ctUtf8, ctBinary,
    ctList, ctStruct

  ColumnDef* = object
    name*: string
    col_type*: ColumnType
    nullable*: bool
    children*: seq[ColumnDef]  ## For ctList/ctStruct

  Schema* = object
    fields*: seq[ColumnDef]

proc column*(name: string, ct: ColumnType, nullable: bool = true): ColumnDef =
  ColumnDef(name: name, col_type: ct, nullable: nullable)

proc schema*(fields: varargs[ColumnDef]): Schema =
  Schema(fields: @fields)

proc field_count*(s: Schema): int = s.fields.len

proc field_names*(s: Schema): seq[string] =
  for f in s.fields: result.add(f.name)
