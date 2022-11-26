extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	#showMessage("[bgcolor=0000002f][center]MeowMeow!!![/center][/bgcolor]")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func showMessage(text, time, format):
	#设置文本，开始计时
	$VBoxContainer/RichTextLabel.set_text("[bgcolor=0000002f][center]%s[/center][/bgcolor]"%text if format else text)
	$Timer.start(time)
	

func _on_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,0), 1).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self.queue_free)
	pass # Replace with function body.
