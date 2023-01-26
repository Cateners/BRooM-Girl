extends Control

enum {TYPE_CONDITION, TYPE_PERIOD}

@onready var DeleteButton: Button = $VBoxContainer/DeleteButton
@onready var NameText: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var DescriptionText: CodeEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VBoxContainer/CodeEdit
@onready var RewardText: CodeEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VBoxContainer2/CodeEdit
@onready var EmergencyText: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VBoxContainer3/LineEdit
@onready var TypeOption: OptionButton = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer2/OptionButton
@onready var ConditionContainer: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ConditionContainer
@onready var PeriodContainer: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/PeriodContainer
@onready var ConditionOption: OptionButton = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ConditionContainer/HBoxContainer/OptionButton
@onready var Data1Container: HBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ConditionContainer/Data1Container
@onready var Data2Container: HBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ConditionContainer/Data2Container
@onready var Data3Container: HBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ConditionContainer/Data3Container
@onready var ConditionText: CodeEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ConditionContainer/CodeEdit
@onready var ConditionComplete: CodeEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ConditionContainer/HBoxContainer5/CodeEdit
@onready var BeginText: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/PeriodContainer/HBoxContainer/LineEdit
@onready var EndText: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/PeriodContainer/HBoxContainer2/LineEdit
@onready var LastText: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/PeriodContainer/HBoxContainer3/LineEdit
@onready var EndEmergency: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/PeriodContainer/HBoxContainer4/LineEdit
@onready var PeriodComplete: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/PeriodContainer/HBoxContainer5/LineEdit

@onready var ConditionCompleteContainer: VBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/ConditionContainer/HBoxContainer5
@onready var PeriodCompleteContainer: HBoxContainer = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/PeriodContainer/HBoxContainer5

#条件型任务模板
#const CONDITION_TASK_TEMPLATE = {
#	#工作类型
#	"type":TYPE_CONDITION,
#	#工作名
#	"name":"",
#	#工作简介
#	"description":"",
#	#奖励
#	"reward":"""coin 100
#	exp. 30""",
#	#紧迫度
#	"emergency":0,
#	#出现条件
#	#参数是当前日期。
#	#返回true(出现)或false(不出现)
#	"condition":"""""",
#	#任务完成的日期
#	#可以有多行
#	"complete_dates":"",
#
#	#额外的
#	#在编辑器中的选项
#	"condition_type":0,
#	"data_1":1,
#	"data_2":[false,false,false,false,false,false,false],
#	"data_3":1
#}
#
#const PERIOD_TASK_TEMPLATE = {
#	#工作类型
#	"type":TYPE_PERIOD,
#	#工作名
#	"name":"",
#	#工作简介
#	"description":"",
#	#奖励
#	"reward":"""coin 100
#	exp. 30""",
#	#紧迫度
#	"emergency":0,
#	#起始日期
#	"begin_date":"",
#	#结束日期
#	"end_date":"",
#	#结束时紧迫度
#	"end_emergency":99,
#	#完成日期
#	"complete_date":""
#}

const TASK_TEMPLATE = {
	"version":0,
	#工作类型
	"type":TYPE_CONDITION,
	#工作名
	"name":"",
	#工作简介
	"description":"",
	#奖励
	"reward":"""coin 100
exp. 30""",
	#紧迫度
	"emergency":5,
	
	
	#出现条件
	#参数是当前日期字典。
	#返回true(出现)或false(不出现)
	"condition":"""func(date):return date==%s""",
	#任务完成的日期
	#可以有多行
	"complete_dates":"",
	
	#额外的
	#在编辑器中的选项
	"condition_type":0,
	"data_1":1,
	"data_2":[false,false,false,false,false,false,false],
	"data_3":1,
	
	
	#起始日期
	"begin_date":"",
	#结束日期
	"end_date":"",
	#结束时紧迫度
	"end_emergency":100,
	#完成日期
	"complete_date":"",
	"complete_days":0,
	#缓存
	"begin_days":0,
	"end_days":0,
}

signal back_to_task

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
#



#func new_task():
#	var task = TASK_TEMPLATE.duplicate()
#准备页面以编辑
func prepare_task():
	
	
	if Global.temp.current_editing_task<0:
		#新建工作
		DeleteButton.set_text("取消新建")
		ConditionCompleteContainer.set_visible(false)
		PeriodCompleteContainer.set_visible(false)
		Global.task_config.append(TASK_TEMPLATE.duplicate())
		Global.temp.current_editing_task = Global.task_config.size() - 1
		Global.task_config[Global.temp.current_editing_task].condition = Global.task_config[Global.temp.current_editing_task].condition%Global.temp.current_editing_date_dict
		Global.task_config[Global.temp.current_editing_task].begin_date = Global.temp.current_editing_date
		Global.task_config[Global.temp.current_editing_task].begin_days = Global.temp.current_editing_days
	else:
		Global.task_config[Global.temp.current_editing_task].condition_type = 4
		DeleteButton.set_text("删除工作")
		ConditionCompleteContainer.set_visible(true)
		PeriodCompleteContainer.set_visible(true)
	NameText.set_text(Global.task_config[Global.temp.current_editing_task].name)
	DescriptionText.set_text(Global.task_config[Global.temp.current_editing_task].description)
	RewardText.set_text(Global.task_config[Global.temp.current_editing_task].reward)
	EmergencyText.set_text("%s"%Global.task_config[Global.temp.current_editing_task].emergency)
	TypeOption._select_int(Global.task_config[Global.temp.current_editing_task].type)
	for x in Data2Container.get_children():
		x.connect("toggled",func(button_pressed):
			if not Global.temp.is_human_pressing:
				return
			Global.task_config[Global.temp.current_editing_task].data_2[String(x.get_name()).substr(8).to_int()] = button_pressed
			_on_data_2_changed())

	
	_on_option_button_item_selected(Global.task_config[Global.temp.current_editing_task].type)

#当选择了一个类型时
func _on_option_button_item_selected(index):
	Global.task_config[Global.temp.current_editing_task].type = index
	Global.set_task()
	ConditionContainer.set_visible(index==TYPE_CONDITION)
	PeriodContainer.set_visible(index==TYPE_PERIOD)
	match roundi(index):
		TYPE_CONDITION:
			ConditionOption._select_int(Global.task_config[Global.temp.current_editing_task].condition_type)
			_on_condition_option_button_item_selected(Global.task_config[Global.temp.current_editing_task].condition_type)
			ConditionComplete.set_text(Global.task_config[Global.temp.current_editing_task].complete_dates)
		TYPE_PERIOD:
			BeginText.set_text(Global.task_config[Global.temp.current_editing_task].begin_date)
			EndText.set_text(Global.task_config[Global.temp.current_editing_task].end_date)
			LastText.set_text("%s"%("" if Global.task_config[Global.temp.current_editing_task].begin_date.length()==0 or Global.task_config[Global.temp.current_editing_task].end_date.length()==0 else Global.task_config[Global.temp.current_editing_task].end_days - Global.task_config[Global.temp.current_editing_task].begin_days))
			EndEmergency.set_text("%s"%Global.task_config[Global.temp.current_editing_task].end_emergency)
			PeriodComplete.set_text(Global.task_config[Global.temp.current_editing_task].complete_date)
	pass # Replace with function body.

#根据ConditionOption的选择处理DataContainer和Condition代码
func _on_condition_option_button_item_selected(index):
	Global.task_config[Global.temp.current_editing_task].condition_type = index
	Global.set_task()
	Data1Container.set_visible(index==1)
	Data2Container.set_visible(index==2)
	Data3Container.set_visible(index==3)
	ConditionText.set_editable(index==4)
	match roundi(index):
		0:
			Global.task_config[Global.temp.current_editing_task].condition = """func(date):
	return date.year==%s and date.month==%s and date.day==%s"""%[Global.temp.current_editing_date_dict.year,Global.temp.current_editing_date_dict.month,Global.temp.current_editing_date_dict.day]
			ConditionText.set_text(Global.task_config[Global.temp.current_editing_task].condition)
			Global.set_task()
		1:
			Data1Container.get_node("LineEdit").set_text("%s"%Global.task_config[Global.temp.current_editing_task].data_1)
			_on_data_1_text_changed("%s"%Global.task_config[Global.temp.current_editing_task].data_1)
		2:
			var i_pos = 0
			Global.temp.is_human_pressing = false
			for i in Global.task_config[Global.temp.current_editing_task].data_2:
				Data2Container.get_node("CheckBox%s"%i_pos).set_pressed(i)
				i_pos+=1
			Global.temp.is_human_pressing = true
			_on_data_2_changed()
		3:
			Data3Container.get_node("LineEdit").set_text("%s"%Global.task_config[Global.temp.current_editing_task].data_3)
			_on_data_3_text_changed("%s"%Global.task_config[Global.temp.current_editing_task].data_3)
		4:
			ConditionText.set_text(Global.task_config[Global.temp.current_editing_task].condition)
	pass # Replace with function body.

func _on_data_1_text_changed(new_text):
	if not new_text.is_valid_int():
		return
	#SAVE
	Global.task_config[Global.temp.current_editing_task].data_1 = Ctutils.evaluate(new_text)
	Global.task_config[Global.temp.current_editing_task].condition = """func(date):
	var x = roundi(Ctdate.diff_days(date,%s))
	return x>=0 and x%%%s==0"""%[Global.temp.current_editing_date_dict,new_text]
	ConditionText.set_text(Global.task_config[Global.temp.current_editing_task].condition)
	Global.set_task()
	pass # Replace with function body.

func _on_data_2_changed():
	var i_pos = 0
	var arr = []
	for i in Global.task_config[Global.temp.current_editing_task].data_2:
		if i:
			arr.append(i_pos)
		i_pos+=1
	Global.task_config[Global.temp.current_editing_task].condition = """func(date):
	return Ctdate.diff_days(date,%s)>=0 and date.weekday in %s"""%[Global.temp.current_editing_date_dict,arr]
	ConditionText.set_text(Global.task_config[Global.temp.current_editing_task].condition)
	Global.set_task()
	pass

func _on_data_3_text_changed(new_text):
	if not new_text.is_valid_int():
		return
	#SAVE
	Global.task_config[Global.temp.current_editing_task].data_3 = Ctutils.evaluate(new_text)
	Global.task_config[Global.temp.current_editing_task].condition = """func(date):
	return date.day==%s"""%new_text
	ConditionText.set_text(Global.task_config[Global.temp.current_editing_task].condition)
	Global.set_task()
	pass # Replace with function body.

func _on_condition_text_changed():
	Global.task_config[Global.temp.current_editing_task].condition = ConditionText.get_text()
	Global.set_task()
	pass # Replace with function body.


func _on_complete_dates_text_changed():
	Global.task_config[Global.temp.current_editing_task].complete_dates = ConditionComplete.get_text()
	Global.set_task()
	pass # Replace with function body.

func _on_start_date_text_changed(new_text):
	Global.task_config[Global.temp.current_editing_task].begin_date = new_text
	Global.task_config[Global.temp.current_editing_task].begin_days = Ctdate.total_days(Ctdate.get_date_dict_from_date_string(new_text))
#	LastText.set_text("" if Global.task_config[Global.temp.current_editing_task].begin_date.length()==0 or Global.task_config[Global.temp.current_editing_task].end_date.length()==0 else "%s"%(Global.task_config[Global.temp.current_editing_task].end_days - Global.task_config[Global.temp.current_editing_task].begin_days))
	LastText.set_text("%s"%("" if Global.task_config[Global.temp.current_editing_task].begin_date.length()==0 or Global.task_config[Global.temp.current_editing_task].end_date.length()==0 else Global.task_config[Global.temp.current_editing_task].end_days - Global.task_config[Global.temp.current_editing_task].begin_days))
	Global.set_task()
	pass # Replace with function body.

func _on_end_date_text_changed(new_text):
	Global.task_config[Global.temp.current_editing_task].end_date = new_text
	Global.task_config[Global.temp.current_editing_task].end_days = Ctdate.total_days(Ctdate.get_date_dict_from_date_string(new_text))
#	LastText.set_text("" if Global.task_config[Global.temp.current_editing_task].begin_date.length()==0 or Global.task_config[Global.temp.current_editing_task].end_date.length()==0 else "%s"%(Global.task_config[Global.temp.current_editing_task].end_days - Global.task_config[Global.temp.current_editing_task].begin_days))
	LastText.set_text("%s"%("" if Global.task_config[Global.temp.current_editing_task].begin_date.length()==0 or Global.task_config[Global.temp.current_editing_task].end_date.length()==0 else Global.task_config[Global.temp.current_editing_task].end_days - Global.task_config[Global.temp.current_editing_task].begin_days))
	Global.set_task()
	pass # Replace with function body.

func _on_last_text_changed(new_text):
	if not new_text.is_valid_int():
		return
	Global.task_config[Global.temp.current_editing_task].end_days = Global.task_config[Global.temp.current_editing_task].begin_days + new_text.to_int()
	Global.task_config[Global.temp.current_editing_task].end_date = Ctdate.get_date_string_from_date_dict(Ctdate.get_date(Global.task_config[Global.temp.current_editing_task].end_days))
	EndText.set_text(Global.task_config[Global.temp.current_editing_task].end_date)
	Global.set_task()
	pass # Replace with function body.

func _on_end_emergency_text_changed(new_text):
	if not new_text.is_valid_int():
		return
	Global.task_config[Global.temp.current_editing_task].end_emergency = Ctutils.evaluate(new_text)
	Global.set_task()
	pass # Replace with function body.

func _on_complete_date_text_changed(new_text):
	Global.task_config[Global.temp.current_editing_task].complete_date = new_text
	Global.task_config[Global.temp.current_editing_task].complete_days = Ctdate.total_days(Ctdate.get_date_dict_from_date_string(new_text))
	Global.set_task()
	pass # Replace with function body.

func _on_name_text_changed(new_text):
	Global.task_config[Global.temp.current_editing_task].name = new_text
	Global.set_task()
	pass # Replace with function body.

func _on_description_text_changed():
	Global.task_config[Global.temp.current_editing_task].description = DescriptionText.get_text()
	Global.set_task()
	pass # Replace with function body.

func _on_reward_text_changed():
	Global.task_config[Global.temp.current_editing_task].reward = RewardText.get_text()
	Global.set_task()
	pass # Replace with function body.

func _on_emergency_text_changed(new_text):
	if not new_text.is_valid_int():
		return
	Global.task_config[Global.temp.current_editing_task].emergency = Ctutils.evaluate(new_text)
	Global.set_task()
	pass # Replace with function body.

func _on_delete_button_pressed():
	Ctutils.simpleDialog("警告","确定删除吗？","确定",func():
		Global.task_config.remove_at(Global.temp.current_editing_task)
		Global.set_task()
		emit_signal("back_to_task"),func():return)
	pass # Replace with function body.


func _on_copy_button_pressed():
	Global.task_config.append(Global.task_config[Global.temp.current_editing_task].duplicate(true))
	Global.temp.current_editing_task = Global.task_config.size()-1
	Global.task_config[Global.temp.current_editing_task].name+="（新）"
	Ctutils.showMessage("已复制")
	prepare_task()
	pass # Replace with function body.
