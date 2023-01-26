extends Control

var ctcheckbox = preload("res://scene/CTCheckBox.tscn")

@onready var DailyContainer: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/DailyContainer
@onready var ExtraContainer: VBoxContainer = $VBoxContainer/ScrollContainer/VBoxContainer/ExtraContainer
@onready var ScoreLabel: RichTextLabel = $VBoxContainer/RichTextLabel

@onready var DailyTitle: Label = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/Label
@onready var ExtraTitle: Label = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer2/Label


signal edit_mission

#
#@onready var DailyContainer: VBoxContainer = $ScrollContainer/VBoxContainer/DailyContainer
#@onready var ExtraContainer: VBoxContainer = $ScrollContainer/VBoxContainer/ExtraContainer
#@onready var ScoreLabel: RichTextLabel = $ScrollContainer/VBoxContainer/RichTextLabel

#
#func find_last(str,what):
#	var pos = str.find(what)
#	while (str.find(what,pos+1))>=0:
#		pos = str.find(what,pos+1)
#	return pos

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

#TODO
#这些加载函数大同小异，什么时候可以优化一下?
func load_mission():
	if not FileAccess.file_exists(Global.MISSION_CONFIG_PATH):
		Global.mission_config = Global.DEFAULT_MISSION_CONFIG.duplicate()
	else:
		Global.read_mission()
	prepare_to_refresh()
	refresh_daily_mission()
	refresh_extra_mission()
	set_score()

#在刷新两个列表之前准备好变量
func prepare_to_refresh():
	#任务模板文件
	Global.temp.current_mission = Global.mission_config[Global.global_config.default_mission_config]
	#模板文件中的任务列表
	Global.temp.mission_array = Ctutils.to_array(Global.temp.current_mission.mission)
	#已完成的任务列表
	Global.temp.completed_array = Ctutils.to_array(Global.calendar_config.missions)
	#任务奖励模板列表
	Global.temp.reward_array = Ctutils.to_array(Global.temp.current_mission.reward)
	#已获得奖励列表
	Global.temp.earned_array = Ctutils.to_array(Global.calendar_config.missions_reward)
	#用来确认"额外的任务"中选了哪些项的列表
	Global.temp.chosen_extra = []
##TODO这里相同代码多，要不来个func简化一下？
##在刷新两个列表之前准备好变量
#func prepare_to_refresh():
#	#任务模板文件
#	Global.temp.current_mission = Global.mission_config[Global.global_config.default_mission_config]
#	#模板文件中的任务列表
#	Global.temp.mission_array = Array(Global.temp.current_mission.mission.strip_edges().split("\n")).map(func(x):return x.strip_edges())
#	#已完成的任务列表
#	Global.temp.completed_array = Array(Global.calendar_config.missions.strip_edges().split("\n")).map(func(x):return x.strip_edges())
#	#任务奖励模板列表
#	Global.temp.reward_array = Array(Global.temp.current_mission.reward.strip_edges().split("\n")).map(func(x):return x.strip_edges())
#	#已获得奖励列表
#	Global.temp.earned_array = Array(Global.calendar_config.missions_reward.strip_edges().split("\n")).map(func(x):return x.strip_edges())
#	#用来确认"额外的任务"中选了哪些项的列表
#	Global.temp.chosen_extra = []

#主要是刷新每日列表并计算模板总分
func refresh_daily_mission():
	#清空列表
	DailyContainer.get_children().map(func(x):
		DailyContainer.remove_child(x)
		x.queue_free())
#		return x.queue_free())
	#计算总分的变量
	Global.temp.mission_score = 0
	#遍历下表的索引
	var i_pos = 0
	for i in Global.temp.mission_array:
		#遍历列表每一项，得到信息，填充新建的实例，然后把实例添加到DailyContainer里
		#遍历的时候顺便算一下总分
		#$ScrollContainer/VBoxContainer/DailyMission.add_item(i if not i in completed_array else i+COMPLETED_FLAG)
		var cb = ctcheckbox.instantiate()
		cb.get_node("NameLabel").set_text("[color=#FFFFFFAF]%s[/color]"%i.substr(0,Ctutils.find_last(i," ")))
		#cb.pos = i_pos
		cb.original_text = i
		cb.is_daily_mission = true
		var score_text = i.substr(Ctutils.find_last(i," "))
		if score_text.length() == 0:
			cb.get_node("ScoreLabel").set_text("")
			cb.get_node("CheckBox").set_visible(false)
		else:
			var score = Ctutils.evaluate(score_text)
			cb.get_node("ScoreLabel").set_text("[right]%s[/right]"%String.num(score))
			cb.score = score
			Global.temp.mission_score+=score
		cb.set_name("DailyList%s"%i_pos)
		#print("DailyList%s"%i_pos)
		cb.connect("refresh_score",set_score)
		DailyContainer.add_child(cb)
		i_pos+=1
	DailyTitle.set_text("每日任务：（无）" if DailyContainer.get_child_count()==0 else "每日任务：")

#刷新额外任务列表并计算今日得分
func refresh_extra_mission():
	#同前面，遍历已完成的列表，如果已完成的任务在前面的列表里有提到就打个勾
	#没有提到，就放进额外列表里
	#顺便计算已完成的总分
	ExtraContainer.get_children().map(func(x):
		ExtraContainer.remove_child(x)
		x.queue_free())
#		return x.queue_free())
	Global.calendar_config.missions_score = 0
	#防止误触发checkbox事件
	Global.temp.is_human_pressing = false
	for i in Global.temp.completed_array:
		#print(i)
		#print(Global.temp.completed_array)
		var pos = Global.temp.mission_array.find(i)
		#出现在这里的应该都是合法的分数项，就不另外检查了
		var score = Ctutils.evaluate(i.substr(Ctutils.find_last(i," ")))
		Global.calendar_config.missions_score+=score
		if pos<0:
			var cb = ctcheckbox.instantiate()
			cb.get_node("NameLabel").set_text("[color=#AFAFAF]%s[/color]"%i.substr(0,Ctutils.find_last(i," ")))
			cb.get_node("ScoreLabel").set_text("[right]%s[/right]"%String.num(score))
			cb.is_daily_mission = false
			cb.original_text = i
			#cb.get_node("CheckBox").set_visible(false)
			ExtraContainer.add_child(cb)
		else:
			#print("ScrollContainer/VBoxContainer/DailyContainer/DailyList%s/CheckBox"%pos)
			#print($ScrollContainer/VBoxContainer/DailyContainer.get_children())
			#DailyContainer.get_node("DailyList%s"%pos).is_human_pressing = false
			DailyContainer.get_node("DailyList%s/CheckBox"%pos).set_pressed_no_signal(true)
			#DailyContainer.get_node("DailyList%s"%pos).is_human_pressing = true
#			get_node("ScrollContainer/VBoxContainer/DailyContainer/DailyList%s"%pos).is_human_pressing = false
#			get_node("ScrollContainer/VBoxContainer/DailyContainer/DailyList%s/CheckBox"%pos).set_pressed(true)
#			get_node("ScrollContainer/VBoxContainer/DailyContainer/DailyList%s"%pos).is_human_pressing = true
	Global.temp.is_human_pressing = true
	ExtraTitle.set_text("额外的任务：（无）" if ExtraContainer.get_child_count()==0 else "额外的任务：")

func refresh_score(score):
	ScoreLabel.set_text("""今日得分：
[center][font_size=150]%s[/font_size][color=red]/%s[/color][/center]"""%["[color=red]%s[/color]"%score if score>=Global.temp.current_mission.target else score,Global.temp.mission_score])
	

#动态刷新分数的变量
var remaining_time = 0
var last_score = 0
var this_score = 0
const TOTAL_TIME = 0.5
const TIME_STEP = 0.0625

#用于判断是否切换了日期
var last_date = ""

#动态刷新分数的函数
func set_score():
	#判断一下变动分数是否由于切换日期所引起
	if last_date == Global.temp.current_editing_date:
		#如果是，那继续判断分数的变动是否引起奖励的得失
		for i in Global.temp.reward_array:
			#一项一项判断
			#Global.temp.total_score是改动后的分值
			#this_score是改动前的分值
			var score = Ctutils.evaluate(i.substr(0,i.find(" ")))
			if this_score<score and Global.calendar_config.missions_score>=score:
				#如果分数超越了分数线，获得奖励，并且将获得的奖励记录到missions_reward中
				var reward = i.substr(i.find(" "))
				var name = reward.substr(0,Ctutils.find_last(reward," ")).strip_edges()
				var value = Ctutils.evaluate(reward.substr(Ctutils.find_last(reward," ")))
				Ctvars.set_vars(name, Ctvars.get_vars(name)+value)
				Ctutils.showMessage("达到%s分，获得奖励 %s %s"%[score,value,name])
				Global.temp.earned_array.append(reward)
				Global.set_calendar("missions_reward","\n".join(PackedStringArray(Global.temp.earned_array)))
				continue
			if this_score>=score and Global.calendar_config.missions_score<score:
				#如果分数跌出了分数线，失去奖励，并且将获得的奖励从missions_reward中删除
				var reward = i.substr(i.find(" "))
				var name = reward.substr(0,Ctutils.find_last(reward," ")).strip_edges()
				var value = Ctutils.evaluate(reward.substr(Ctutils.find_last(reward," ")))
				Ctvars.set_vars(name, Ctvars.get_vars(name)-value)
				Ctutils.showMessage("低于%s分，失去奖励 %s %s"%[score,value,name])
				Global.temp.earned_array.erase(reward)
				Global.set_calendar("missions_reward","\n".join(PackedStringArray(Global.temp.earned_array)))
				#print(i.substr(i.find(" ")))
				continue
		
	else:
		last_date = Global.temp.current_editing_date
	#检查上次的动画是否没放完，是的话直接中断放新的
	if remaining_time>0:
		last_score = this_score
		$Timer.stop()
	remaining_time = TOTAL_TIME
	this_score = Global.calendar_config.missions_score
	$Timer.start(TIME_STEP)
	

func _on_timer_timeout():
	remaining_time-=TIME_STEP
	if remaining_time>0:
		refresh_score(roundi(last_score*remaining_time/TOTAL_TIME+this_score*(TOTAL_TIME-remaining_time)/TOTAL_TIME))
		$Timer.start(TIME_STEP)
	else:
		remaining_time = 0
		last_score = this_score
		refresh_score(this_score)
	pass # Replace with function body.

#
##根据加载的模板和日期加载每日任务
#func refresh_mission():
#	#先加载每日任务
#	#清空列表，再把要加载的一项一项添加进去
#	$ScrollContainer/VBoxContainer/DailyContainer.get_children().map(func(x):return x.queue_free())
#	Global.temp.current_mission = Global.mission_config[Global.global_config.default_mission_config]
#	Global.global_config.mission_array = Array(Global.temp.current_mission.mission.strip_edges().split("\n")).map(func(x):return x.strip_edges())
#	Global.temp.completed_array = Array(Global.calendar_config.missions.strip_edges().split("\n")).map(func(x):return x.strip_edges())
#	Global.global_config.mission_score = 0
#	#遍历下表的索引
#	var i_pos = 0
#	for i in Global.global_config.mission_array:
#		#遍历列表每一项，得到信息，填充新建的实例，然后把实例添加到DailyContainer里
#		#遍历的时候顺便算一下总分
#		#$ScrollContainer/VBoxContainer/DailyMission.add_item(i if not i in completed_array else i+COMPLETED_FLAG)
#		var cb = ctcheckbox.instantiate()
#		cb.get_node("NameLabel").set_text("[color=#AFAFAF]%s[/color]"%i.substr(0,find_last(i," ")))
#		cb.pos = i_pos
#		cb.is_daily_mission = true
#		var score_text = i.substr(find_last(i," "))
#		if score_text.length() == 0:
#			cb.get_node("ScoreLabel").set_text("")
#			cb.get_node("CheckBox").set_visible(false)
#		else:
#			var score = Cteval.evaluate(score_text)
#			cb.get_node("ScoreLabel").set_text(String.num(score))
#			Global.global_config.mission_score+=score
#		cb.set_name("DailyList%s"%i_pos)
#		$ScrollContainer/VBoxContainer/DailyContainer.add_child(cb)
#		i_pos+=1
#	#同前面，遍历已完成的列表，如果已完成的任务在前面的列表里有提到就打个勾
#	#没有提到，就放进额外列表里
#	#顺便计算已完成的总分
#	Global.temp.total_score = 0
#	for i in Global.temp.completed_array:
#		var pos = Global.global_config.mission_array.find(i)
#		#出现在这里的应该都是合法的分数项，就不另外检查了
#		var score = Cteval.evaluate(i.substr(find_last(i," ")))
#		Global.temp.total_score+=score
#		if pos<0:
#			var cb = ctcheckbox.instantiate()
#			cb.get_node("NameLabel").set_text("[color=#AFAFAF]%s[/color]"%i.substr(0,find_last(i," ")))
#			cb.get_node("ScoreLabel").set_text(String.num(score))
#			cb.is_daily_mission = false
#			#cb.get_node("CheckBox").set_visible(false)
#			$ScrollContainer/VBoxContainer/ExtraContainer.add_child(cb)
#		else:
#			#print("ScrollContainer/VBoxContainer/DailyContainer/DailyList%s/CheckBox"%pos)
#			#print($ScrollContainer/VBoxContainer/DailyContainer.get_children())
#			get_node("ScrollContainer/VBoxContainer/DailyContainer/DailyList%s/CheckBox"%pos).set_pressed(true)
#	$ScrollContainer/VBoxContainer/RichTextLabel.set_text("""今日得分：
#[center][font_size=50]%s[/font_size][color=red]/%s[/color][/center]"""%["[color=red]%s[/color]"%Global.temp.total_score if Global.temp.total_score>=Global.temp.current_mission.target else Global.temp.total_score,Global.global_config.mission_score])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#要添加项，先弹出对话框填写信息
func _on_add_extra_button_pressed():
	$AddExtraDialog.popup_centered(Vector2(900,0))
	pass # Replace with function body.

#填写完信息确认后，解析信息
func _on_add_extra_dialog_confirmed():
	var text = $AddExtraDialog/VBoxContainer/LineEdit.get_text().strip_edges()
	if text.split(" ",false).size()!=2:
		Ctutils.showMessage("[bgcolor=0000002f][center]文本不符合格式，未添加[/center][/bgcolor]",2)
		return
	Global.temp.completed_array.append(text)
	Global.set_calendar("missions","\n".join(PackedStringArray(Global.temp.completed_array)))
	refresh_extra_mission()
	set_score()
	pass # Replace with function body.

func _on_del_extra_button_pressed():
	#如果啥也没选中
	if Global.temp.chosen_extra.size() == 0:
		Ctutils.showMessage("没有选中的项",2)
		return
	#让用户确认删除
	Ctutils.simpleDialog("注意","你确认要删除这些项吗:\n%s"%("\n".join(PackedStringArray(Global.temp.chosen_extra))),"确认",func():
		Global.temp.chosen_extra.map(func(i):Global.temp.completed_array.erase(i))
		Global.set_calendar("missions","\n".join(PackedStringArray(Global.temp.completed_array)))
		Global.temp.chosen_extra.clear()
		refresh_extra_mission()
		set_score()
		,func():return)
	pass # Replace with function body.


func _on_modify_mission_button_pressed():
	#只有在没有分数项时才允许修改
	if not (Global.temp.completed_array.is_empty() or Global.global_config.force_score_modify):
		Ctutils.simpleDialog("注意","只有在没有分数的情况下才允许修改。","好",func():return,func():return)
		return
	#跳转到修改页面
	emit_signal("edit_mission")
	
	pass # Replace with function body.
