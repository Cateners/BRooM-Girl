extends Control

#已经保存日记时发出此信号，用于提醒Calendar更新标题等等
signal note_saved

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#根据Global.temp.current_editing_date刷新日记
func refresh_diary():
	$VBoxContainer/TextEdit.set_text(Global.calendar_config.notes)


func _on_text_edit_text_changed():
	Global.set_calendar("notes",$VBoxContainer/TextEdit.get_text())
	emit_signal("note_saved")
	pass # Replace with function body.
