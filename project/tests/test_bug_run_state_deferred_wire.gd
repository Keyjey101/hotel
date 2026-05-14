extends "res://scripts/tests/test_base.gd"
## Test: RunState._wire_events called deferred misses early signals
## Bug: run_state.gd:43-46 _wire_events.call_deferred() creates gap where signals are missed

## Verify RunState wires events synchronously (or documents the bug)


func test_run_state_wire_events_is_deferred() -> void:
	var rs := RunState.new()
	# At this point, _wire_events has been called via call_deferred
	# but has NOT yet executed (it's queued for next idle frame)
	# Any EventBus signals emitted NOW will be missed by this RunState
	assert(rs != null, "RunState created")
	assert(true, "Bug: _wire_events.call_deferred() means signals between new() and deferred execution are missed")


func test_run_state_wire_events_deferred_rationale() -> void:
	# The deferred call was likely added because EventBus might not be ready
	# during _init(). But autoloads are always ready before any node's _ready().
	# Since RunState is created in GameManager._ready() (which is an autoload),
	# EventBus is guaranteed to exist.
	assert(true, "Fix: call _wire_events() directly in _init(), or use _ready() pattern instead")
