extends HBoxContainer

#节点在(模板或额外)列表的位置
#var pos = 0

#原始文本
var original_text:String

#存放分数的变量
var score = 0

#这个节点是模板里的任务吗?
#如果是额外任务，就是false
var is_daily_mission = true

signal refresh_score

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_check_box_toggled(button_pressed):
	if not Global.temp.is_human_pressing:
		return
	#如果本节点是模板任务，被(取消)勾选后重新计算分数
	if is_daily_mission:
		if button_pressed:
			#由未完成到完成,将该项任务添加到已完成数组
			Global.temp.completed_array.append(original_text)
			Global.calendar_config.missions_score+=score
		else:
			#否则从已完成数组移除
			Global.temp.completed_array.erase(original_text)
			Global.calendar_config.missions_score-=score
		#保存数据
		Global.set_calendar("missions","\n".join(PackedStringArray(Global.temp.completed_array)))
		emit_signal("refresh_score")
		return
	#如果是额外任务，在另一个数组中记录一下勾选的数据
	if button_pressed:
		Global.temp.chosen_extra.append(original_text)
		return
	Global.temp.chosen_extra.erase(original_text)
	pass # Replace with function body.
