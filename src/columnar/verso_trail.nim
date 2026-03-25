## verso_trail.nim -- Delta-compress Parquet row groups; verso Trail.
{.experimental: "strict_funcs".}

import basis/code/verso

type
  RowGroupDelta* = object
    file_path*: string
    row_group_idx*: int
    columns_changed*: seq[string]

proc row_group_to_mutation*(delta: RowGroupDelta, ts: int64): Mutation =
  var deltas: seq[Delta] = @[]
  for col in delta.columns_changed:
    deltas.add(delta_add(col, $delta.row_group_idx))
  var m = Mutation(parent: "", actor: "columnar", timestamp: ts,
    plan_version: 1, space: "home", partition: pData,
    entities: @[entity("parquet", delta.file_path)],
    deltas: deltas)
  stamp(m)
  m

proc mutations_to_trail*(mutations: seq[Mutation], file_path: string): seq[Mutation] =
  for m in mutations:
    for e in m.entities:
      if e.instance_id == file_path:
        result.add(m)
        break
