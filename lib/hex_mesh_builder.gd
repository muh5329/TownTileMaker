extends RefCounted
class_name HexMeshBuilder

## Builds a placeholder hex-prism mesh procedurally so the project runs
## with zero external art assets. Swap this out for real models later —
## every tile/highlight just needs a Mesh resource.

static func build(size: float = 1.0, height: float = 0.3) -> ArrayMesh:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var top_pts: Array[Vector3] = []
	var bot_pts: Array[Vector3] = []
	for i in range(6):
		var angle := deg_to_rad(60 * i + 30) # pointy-top, matches HexMath orientation
		var x := size * cos(angle)
		var z := size * sin(angle)
		top_pts.append(Vector3(x, height, z))
		bot_pts.append(Vector3(x, 0.0, z))

	var top_center := Vector3(0, height, 0)
	for i in range(6):
		var a := top_pts[i]
		var b := top_pts[(i + 1) % 6]
		st.add_vertex(top_center)
		st.add_vertex(a)
		st.add_vertex(b)

	var bot_center := Vector3(0, 0, 0)
	for i in range(6):
		var a := bot_pts[i]
		var b := bot_pts[(i + 1) % 6]
		st.add_vertex(bot_center)
		st.add_vertex(b)
		st.add_vertex(a)

	for i in range(6):
		var t1 := top_pts[i]
		var t2 := top_pts[(i + 1) % 6]
		var b1 := bot_pts[i]
		var b2 := bot_pts[(i + 1) % 6]
		st.add_vertex(b1)
		st.add_vertex(t1)
		st.add_vertex(t2)
		st.add_vertex(b1)
		st.add_vertex(t2)
		st.add_vertex(b2)

	st.generate_normals()
	return st.commit()
