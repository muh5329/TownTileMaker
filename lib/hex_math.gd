extends RefCounted
class_name HexMath

## Axial-coordinate hex grid math for pointy-top hexes.
## q,r are stored as ints (Vector2i(q, r)). World space uses X/Z with Y up.

const HEX_SIZE := 1.0

const AXIAL_DIRS: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
]

static func axial_to_world(q: int, r: int) -> Vector3:
	var x := HEX_SIZE * (sqrt(3.0) * q + sqrt(3.0) / 2.0 * r)
	var z := HEX_SIZE * (1.5 * r)
	return Vector3(x, 0.0, z)

static func world_to_axial(pos: Vector3) -> Vector2i:
	var qf := (sqrt(3.0) / 3.0 * pos.x - 1.0 / 3.0 * pos.z) / HEX_SIZE
	var rf := (2.0 / 3.0 * pos.z) / HEX_SIZE
	return _axial_round(qf, rf)

static func neighbors(cell: Vector2i) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for d in AXIAL_DIRS:
		out.append(cell + d)
	return out

static func _axial_round(qf: float, rf: float) -> Vector2i:
	var xf := qf
	var zf := rf
	var yf := -xf - zf
	var x := roundf(xf)
	var y := roundf(yf)
	var z := roundf(zf)
	var dx := absf(x - xf)
	var dy := absf(y - yf)
	var dz := absf(z - zf)
	if dx > dy and dx > dz:
		x = -y - z
	elif dy > dz:
		y = -x - z
	return Vector2i(int(x), int(z))
