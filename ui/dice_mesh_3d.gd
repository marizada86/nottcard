class_name DiceMesh3d
extends RefCounted
## Dados declarativos para o renderer 3D. A aparência é de dado de mesa
## padrão: faces neutras e números gerados pelo Godot, sem sprites do jogo.

const PHI := 1.61803398875
const D20_VERTICES := [
	Vector3(-1, PHI, 0), Vector3(1, PHI, 0), Vector3(-1, -PHI, 0), Vector3(1, -PHI, 0),
	Vector3(0, -1, PHI), Vector3(0, 1, PHI), Vector3(0, -1, -PHI), Vector3(0, 1, -PHI),
	Vector3(PHI, 0, -1), Vector3(PHI, 0, 1), Vector3(-PHI, 0, -1), Vector3(-PHI, 0, 1),
]
const D20_FACES := [
	[0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11],
	[1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
	[3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9],
	[4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1],
]

static func d20_mesh() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	for face in D20_FACES:
		var a: Vector3 = D20_VERTICES[face[0]].normalized()
		var b: Vector3 = D20_VERTICES[face[1]].normalized()
		var c: Vector3 = D20_VERTICES[face[2]].normalized()
		var normal := (b - a).cross(c - a).normalized()
		var arrays := []
		arrays.resize(ArrayMesh.ARRAY_MAX)
		arrays[ArrayMesh.ARRAY_VERTEX] = PackedVector3Array([a, b, c])
		arrays[ArrayMesh.ARRAY_NORMAL] = PackedVector3Array([normal, normal, normal])
		arrays[ArrayMesh.ARRAY_TEX_UV] = PackedVector2Array([Vector2(0.5, 0), Vector2(0, 1), Vector2(1, 1)])
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh

static func face_normal(value: int) -> Vector3:
	var face: Array = D20_FACES[clampi(value, 1, 20) - 1]
	var a: Vector3 = D20_VERTICES[face[0]].normalized()
	var b: Vector3 = D20_VERTICES[face[1]].normalized()
	var c: Vector3 = D20_VERTICES[face[2]].normalized()
	return (b - a).cross(c - a).normalized()

static func face_center(value: int) -> Vector3:
	var face: Array = D20_FACES[clampi(value, 1, 20) - 1]
	return (D20_VERTICES[face[0]].normalized() + D20_VERTICES[face[1]].normalized() + D20_VERTICES[face[2]].normalized()) / 3.0

static func face_material(value: int) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	# Um marfim fosco é legível contra qualquer cenário e remete a dados físicos.
	material.albedo_color = Color8(232, 228, 214)
	material.metallic = 0.0
	material.roughness = 0.52
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	return material
