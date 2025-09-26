@tool
extends StatusEffect


const PARTICLE := preload("res://objects/battle/effects/drenched/rage.tscn")

var particles : GPUParticles3D

func apply() -> void:
	super()
	particles = PARTICLE.instantiate()
	target.add_child(particles)
	particles.global_position = target.body.head_bone.global_position
	particles.reparent(target.body.head_bone)

func cleanup() -> void:
	super()
	if particles:
		particles.queue_free()


func get_status_name() -> String:
	return "rage"
