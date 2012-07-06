#= require benchmarking/JSLitmus.js
#= require_tree ./support
#= require_tree ./benches
#= require_self

JSLitmus.test 'sync_create', ((count)->
  Benches.beforeSyncCreate()
  while count--
    Benches.syncCreate()
)
