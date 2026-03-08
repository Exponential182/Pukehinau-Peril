extends GPUParticles2D


func _on_finished() -> void:
	self.queue_free()
