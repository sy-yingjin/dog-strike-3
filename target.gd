extends Node3D

var health
signal got_hit

# signal collision hit
func hit():
	got_hit.emit()
