@abstract
class_name Gravity
extends Resource

@abstract
func get_gravity_at(position: Vector3) -> Vector3

## Equivalent to SpaceOverride
enum Mode {
	## This area adds its gravity values to whatever has been calculated so far.
	COMBINE,
	## This area adds its gravity values to whatever has been calculated so far, any lower priority
	# areas will be ignored.
	COMBINE_REPLACE,
	## Use only this area's gravity value, regardless of any other area. Priority between two
	## REPLACE areas is based on which has been most recently entered.
	REPLACE,
	## Discards all gravity values accumulated so far (higher priority and more recent) but allows
	## older and lower priority areas to accumulate.
	REPLACE_COMBINE
}