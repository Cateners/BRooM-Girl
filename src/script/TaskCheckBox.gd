extends PanelContainer

#对应的工作字典数据。
var data

#该工作是否已完成
var is_completed = false

#该工作在列表的位置
var pos

#要显示的紧迫度
var emergency

#奖励数组
#[[奖励1(字符串),数量1(字符串)],[...],[...],...]
var reward

@onready var NameText: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/NameText
@onready var SecondText: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/HBoxContainer/SecondText
@onready var RewardText: RichTextLabel = $MarginContainer/HBoxContainer/VBoxContainer/RewardText
@onready var TaskCheck: CheckBox = $MarginContainer/HBoxContainer/CheckBox

signal edit_task
signal refresh_task

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#在准备好data, emergency和is_completed后调用
func set_layout():
	#已完成的任务变灰
	var text_effect = "[color=#FFFFFFAF]%s[/color]" if is_completed else "%s"
	NameText.set_text(text_effect%("（无名工作）" if data.name.is_empty() else data.name))
	#已完成的任务显示完成日期，否则显示紧迫度
	SecondText.set_text("[right]%s[/right]"%(text_effect%((Global.temp.current_editing_date if data.type==0 else data.complete_date) if is_completed else ("" if emergency==0 else round(emergency)))))
	#SecondText.set_text("[right]%s[/right]"%(text_effect%((Global.current_editing_date if is_completed else emergency) if data.type==0 else (data.complete_date if is_completed else emergency))))
	reward = Ctutils.to_array(data.reward).map(func(x):return (func(y):return [x.substr(0,y).strip_edges(),x.substr(y).strip_edges()]).call(Ctutils.find_last(x," ")))
	RewardText.set_text("[right]%s[/right]"%(text_effect%(" ".join(PackedStringArray(reward.map(func(x):
		var v = Ctutils.evaluate(x[1])
		return "%s%s%s"%["" if v<0 else "+",("" if v>0 else "-") if abs(v)==1 else "%s*"%v,x[0]]))))))
#	RewardText.set_text("[right]%s[/right]"%(text_effect%(" ".join(PackedStringArray(reward.map(func(x):return "%s*%s"%["" if x[1]=="1" else (x[1] if x[1].begins_with("-") else "+%s"%x[1]),x[0]]))))))
	TaskCheck.set_pressed_no_signal(is_completed)
	pass

func _on_check_box_toggled(button_pressed):
	var dialog = ConfirmationDialog.new()
	dialog.set_cancel_button_text("取消完成" if is_completed else "完成此工作")
	TaskCheck.set_pressed_no_signal(is_completed)
	dialog.set_ok_button_text("编辑")
	dialog.set_text("（无详情）" if data.description.is_empty() else data.description)
	dialog.set_title("（无名工作）" if data.name.is_empty() else data.name)
#	dialog.connect("cancelled",func():
#		TaskCheck.set_pressed_no_signal(false))
	dialog.connect("confirmed",func():
		#按下编辑键
		Global.temp.current_editing_task = pos
		emit_signal("edit_task")
		)
	dialog.get_cancel_button().connect("pressed",func():
		#按下完成键或取消完成键
		TaskCheck.set_pressed_no_signal(not is_completed)
		if is_completed:
			#完成到未完成，删去完成日期
			match roundi(data.type):
				0:#条件型工作，可能有多个日期
					var t = Ctutils.to_array(data.complete_dates)
					t.erase(Global.temp.current_editing_date)
					Global.task_config[pos].complete_dates = "\n".join(PackedStringArray(t))
				1:#区域型，只有一个日期，清空即可
					Global.task_config[pos].complete_date = ""
			#取消已获得奖励
			reward.map(func(x):Ctvars.set_vars(x[0],Ctvars.get_vars(x[0])-Ctutils.evaluate(x[1])))
		else:#未完成到完成，添加完成日期
			match roundi(data.type):
				0:#条件型工作，可能有多个日期
					var t = Ctutils.to_array(data.complete_dates)
					t.append(Global.temp.current_editing_date)
					Global.task_config[pos].complete_dates = "\n".join(PackedStringArray(t))
				1:#区域型，只有一个日期，赋值即可
					Global.task_config[pos].complete_date = Global.temp.current_editing_date
					Global.task_config[pos].complete_days = Global.temp.current_editing_days
			reward.map(func(x):Ctvars.set_vars(x[0],Ctvars.get_vars(x[0])+Ctutils.evaluate(x[1])))
		Global.set_task()
		emit_signal("refresh_task")
		)
	get_tree().get_current_scene().add_child(dialog)
	dialog.popup_centered()
	pass # Replace with function body.
