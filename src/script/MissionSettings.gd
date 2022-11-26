extends Control

@onready var MissionOption: OptionButton = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/OptionButton
@onready var CopyButton: Button = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/CopyButton
@onready var DeleteButton: Button = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer/DeleteButton
@onready var NameText: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer2/LineEdit
@onready var MissionText: CodeEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VBoxContainer/CodeEdit
@onready var ScoreText: LineEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/HBoxContainer3/LineEdit
@onready var RewardText: CodeEdit = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VBoxContainer2/CodeEdit
@onready var MissionSave: Button = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/MissionSaveButton
@onready var RewardSave: Button = $VBoxContainer/ScrollContainer/MarginContainer/VBoxContainer/VBoxContainer2/HBoxContainer/RewardSaveButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func read_data():
	#初始化MissionOption
	MissionOption.clear()
	for i in Global.mission_config:
		MissionOption.add_item(i.description)
	MissionOption._select_int(Global.global_config.default_mission_config)
	_on_option_button_item_selected(Global.global_config.default_mission_config)
	pass

#根据选择的值设置其它控件
func _on_option_button_item_selected(index):
	Global.set_global("default_mission_config", index)
	NameText.set_text(Global.mission_config[index].description)
	MissionText.set_text(Global.mission_config[index].mission)
	ScoreText.set_text(String.num(Global.mission_config[index].target))
	RewardText.set_text(Global.mission_config[index].reward)
	MissionSave.set_text("保存更改")
	RewardSave.set_text("保存更改")
	pass # Replace with function body.



func _on_description_text_changed(new_text):
	MissionOption.set_item_text(Global.global_config.default_mission_config,new_text)
	Global.mission_config[Global.global_config.default_mission_config].description = new_text
	Global.set_mission()
	pass # Replace with function body.


func _on_mission_text_changed():
	MissionSave.set_text("保存更改*")
	pass # Replace with function body.
	

func _on_score_text_changed(new_text):
	if not new_text.is_valid_float():
		return
	Global.mission_config[Global.global_config.default_mission_config].target = Ctutils.evaluate(new_text)
	Global.set_mission()
	pass # Replace with function body.



func _on_reward_text_changed():
	RewardSave.set_text("保存更改*")
	pass # Replace with function body.


func _on_mission_save_button_pressed():
	Global.mission_config[Global.global_config.default_mission_config].mission = MissionText.get_text()
	Global.set_mission()
	MissionSave.set_text("保存更改")
	pass # Replace with function body.



func _on_reward_save_button_pressed():
	Global.mission_config[Global.global_config.default_mission_config].reward = RewardText.get_text()
	Global.set_mission()
	RewardSave.set_text("保存更改")
	pass # Replace with function body.



func _on_copy_button_pressed():
	Global.mission_config.append(Global.mission_config[Global.global_config.default_mission_config].duplicate())
	Global.set_mission()
	Global.set_global("default_mission_config",Global.mission_config.size()-1)
	MissionOption.add_item(Global.mission_config[Global.global_config.default_mission_config].description)
	MissionOption._select_int(Global.mission_config.size()-1)
	_on_option_button_item_selected(Global.global_config.default_mission_config)
	Ctutils.showMessage("已复制")
	pass # Replace with function body.



func _on_delete_button_pressed():
	if Global.mission_config.size() == 1:
		Ctutils.showMessage("至少要有一个模板")
		return
	Ctutils.simpleDialog("警告","你将删除模板：\n%s"%Global.mission_config[Global.global_config.default_mission_config].description,"确认",func():
		MissionOption.remove_item(Global.global_config.default_mission_config)
		Global.mission_config.remove_at(Global.global_config.default_mission_config)
		Global.set_mission()
		Global.set_global("default_mission_config",0)
		MissionOption._select_int(0)
		_on_option_button_item_selected(0)
		Ctutils.showMessage("已删除")
		,func():return)
	pass # Replace with function body.
