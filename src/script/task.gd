extends Control

var taskcheckbox = preload("res://scene/TaskCheckBox.tscn")

@onready var TaskContainer: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/TaskContainer
@onready var CompletedContainer: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/CompletedContainer
@onready var EmergencyText: RichTextLabel = $VBoxContainer/RichTextLabel

@onready var CurrentTitle: RichTextLabel = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/RichTextLabel
@onready var CompleteTitle: RichTextLabel = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer2/RichTextLabel

signal edit_task

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_task():
	if not FileAccess.file_exists(Global.TASK_CONFIG_PATH):
		Global.task_config = Global.DEFAULT_TASK_CONFIG.duplicate()
	else:
		Global.read_task()
	prepare_to_refresh()
	refresh_task()
	set_emergency()

func prepare_to_refresh():
	pass
#
#func refresh_task():
#	#清空列表
#	TaskContainer.get_children().map(func(x):
#		TaskContainer.remove_child(x)
#		return x.queue_free())
#	CompletedContainer.get_children().map(func(x):
#		CompletedContainer.remove_child(x)
#		return x.queue_free())
#	#这是一个计算合计紧迫度的变量
#	Global.temp.task_emergency = 0
#	#用来记录位置的变量
#	var i_pos = 0
#	#读取config并加载
#	for i in Global.task_config:
#		if i.type == 0:#条件型
#			#如果该工作和今天无关，则不显示，直接检查下一个工作
#			if not Ctutils.evaluate(i.condition).call(Global.temp.current_editing_date_dict):
#				i_pos += 1
#				continue
#			var cb = taskcheckbox.instantiate()
#			cb.data = i
#			cb.pos = i_pos
#			cb.connect("edit_task",func():emit_signal("edit_task"))
#			cb.connect("refresh_task",refresh_task_and_emergency)
#			#工作是否完成?
#			if Global.temp.current_editing_date in Ctutils.to_array(i.complete_dates):
#				cb.is_completed = true
#				CompletedContainer.add_child(cb)
#			else:
#				#工作没有完成的时候把紧迫度加上去
#				cb.is_completed = false
#				cb.emergency = i.emergency
#				Global.temp.task_emergency += cb.emergency
#				TaskContainer.add_child(cb)
#			cb.set_layout()
#		else:#区间型任务
#			#如果该工作和今天无关，则不显示，直接检查下一个工作
#			if not ((i.begin_date.strip_edges().length() == 0 or i.begin_days <= Global.temp.current_editing_days) and (i.end_date.strip_edges().length() == 0 or Global.temp.current_editing_days <= i.end_days)):
#				i_pos += 1
#				continue
#			var cb = taskcheckbox.instantiate()
#			cb.data = i
#			cb.pos = i_pos
#			cb.connect("edit_task",func():emit_signal("edit_task"))
#			cb.connect("refresh_task",refresh_task_and_emergency)
#			#工作是否完成?
##			if Global.temp.current_editing_date == i.complete_date.strip_edges():
#			if not i.complete_date.strip_edges().is_empty():
#				cb.is_completed = true
#				CompletedContainer.add_child(cb)
#			else:
#				#工作没有完成的时候把紧迫度加上去
#				cb.is_completed = false
#				TaskContainer.add_child(cb)
#				#结束日期必须大于起始日期！
#				#结束紧迫值必须有效
#				cb.emergency = (func():
#					#先排除紧迫度或日期相同的情况
#					if i.end_emergency == i.emergency:
#						return i.emergency
#					if i.begin_days==i.end_days:
#						return i.emergency
#					#当结束日期不存在时使用原始紧迫值
#					if i.end_date.strip_edges().length() == 0:
#						return i.emergency
#					#当开始日期不存在时使用原始紧迫值
#					if i.begin_date.strip_edges().length() == 0:
#						return i.end_emergency
#					#现在两个日期都存在，计算紧迫度
#					var a = (i.end_emergency - i.emergency)/(i.end_days - i.begin_days)
#					var b = i.emergency-a*i.begin_days
#					return i.emergency+(i.end_emergency - i.emergency)*(func(x):return x*abs(x)).call((a*Global.temp.current_editing_days+b-i.emergency)/(i.end_emergency - i.emergency))).call()
#				Global.temp.task_emergency += cb.emergency
#			cb.set_layout()
#		i_pos += 1
#	CurrentTitle.set_text("当前没有工作。" if TaskContainer.get_child_count()==0 else "当前工作：")
#	CompleteTitle.set_text("" if CompletedContainer.get_child_count()==0 else "已完成的工作：")
#

func refresh_task():
	#清空列表
	TaskContainer.get_children().map(func(x):
		TaskContainer.remove_child(x)
		x.queue_free())
		#return x.queue_free())
	CompletedContainer.get_children().map(func(x):
		CompletedContainer.remove_child(x)
		x.queue_free())
		#return x.queue_free())
	#这是一个计算合计紧迫度的变量
	Global.temp.task_emergency = 0
	#用来记录位置的变量
	var i_pos = 0
	#读取config并加载
	for i in Global.task_config:
		var cb = taskcheckbox.instantiate()
		cb.data = i
		cb.pos = i_pos
		cb.connect("edit_task",func():emit_signal("edit_task"))
		cb.connect("refresh_task",refresh_task_and_emergency)
		(func():
			if i.type == 0:#条件型
				#如果该工作和今天无关，则不显示，直接检查下一个工作
				if not Ctutils.evaluate(i.condition).call(Global.temp.current_editing_date_dict):
					return
				#工作是否完成?
				if Global.temp.current_editing_date in Ctutils.to_array(i.complete_dates):
					cb.is_completed = true
					CompletedContainer.add_child(cb)
				else:
					#工作没有完成的时候把紧迫度加上去
					cb.is_completed = false
					cb.emergency = i.emergency
					Global.temp.task_emergency += cb.emergency
					TaskContainer.add_child(cb)
				cb.set_layout()
			else:#区间型任务
				#如果该工作和今天无关，则不显示，直接检查下一个工作
				if not ((i.begin_date.strip_edges().length() == 0 or i.begin_days <= Global.temp.current_editing_days) and (i.end_date.strip_edges().length() == 0 or Global.temp.current_editing_days <= i.end_days)):
					return
				#工作是否完成?
#				if Global.temp.current_editing_date == i.complete_date.strip_edges():
				if not i.complete_date.strip_edges().is_empty():
					#工作已经完成。为了避免打扰不必要的日期，如果任务不在完成日期到起始/结束日期的区间内就不显示了。
					match [i.begin_date.strip_edges().length() == 0,i.end_date.strip_edges().length() == 0]:
						[true,true]:if i.complete_days != Global.temp.current_editing_days:return
						[true,false]:if Global.temp.current_editing_days < i.complete_days:return
						[false,true]:if Global.temp.current_editing_days > i.complete_days:return
						#[false,false]:
					cb.is_completed = true
					CompletedContainer.add_child(cb)
				else:
					#工作没有完成的时候把紧迫度加上去
					cb.is_completed = false
					TaskContainer.add_child(cb)
					#结束日期必须大于起始日期！
					#结束紧迫值必须有效
					cb.emergency = (func():
						#先排除紧迫度或日期相同的情况
						if i.end_emergency == i.emergency:
							return i.emergency
						if i.begin_days==i.end_days:
							return i.emergency
						#当结束日期不存在时使用原始紧迫值
						if i.end_date.strip_edges().length() == 0:
							return i.emergency
						#当开始日期不存在时使用原始紧迫值
						if i.begin_date.strip_edges().length() == 0:
							return i.end_emergency
						#现在两个日期都存在，计算紧迫度
						var a = (i.end_emergency - i.emergency)/(i.end_days - i.begin_days)
						var b = i.emergency-a*i.begin_days
						return i.emergency+(i.end_emergency - i.emergency)*(func(x):return x*abs(x)).call((a*Global.temp.current_editing_days+b-i.emergency)/(i.end_emergency - i.emergency))).call()
					Global.temp.task_emergency += cb.emergency
				cb.set_layout()).call()
		if not cb.is_inside_tree():
			cb.queue_free()
		i_pos += 1
	CurrentTitle.set_text("当前没有工作。" if TaskContainer.get_child_count()==0 else "当前工作：")
	CompleteTitle.set_text("" if CompletedContainer.get_child_count()==0 else "已完成的工作：")
		
		
func set_emergency():
	EmergencyText.set_text("紧迫度合计：\n[center][font_size=150]%s[/font_size][/center]"%(("%s" if Global.temp.task_emergency==0 else "[color=red]%s[/color]")%roundi(Global.temp.task_emergency)))
	pass

func refresh_task_and_emergency():
	refresh_task()
	set_emergency()

func _on_new_task_button_pressed():
	Global.temp.current_editing_task = -1
	emit_signal("edit_task")
	pass # Replace with function body.
