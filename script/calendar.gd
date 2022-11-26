extends Control

#var calendar_config:Dictionary
#var diary_instance = preload("res://scene/diary.tscn").instantiate()

#左栏出现的所有日期对应的天数(以start_date作为第一天)
var items:Array

#const mission_settings = preload("res://scene/MissionSettings.tscn")

@onready var DailyMission: Control = $"HSplitContainer/VBoxContainer2/TabContainer/任务"
@onready var DailyTask: Control = $"HSplitContainer/VBoxContainer2/TabContainer/工作"
@onready var Tabs: TabContainer = $HSplitContainer/VBoxContainer2/TabContainer
@onready var MissionSettings: Control = $"HSplitContainer/VBoxContainer2/TabContainer/任务设置"
@onready var TaskSettings: Control = $"HSplitContainer/VBoxContainer2/TabContainer/工作编辑"

#提醒更新日记的信号
signal load_diary

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	#根据今天的日期加载日记和任务
	#load_date(Time.get_date_string_from_system())
	Global.temp.current_editing_date = Time.get_date_string_from_system()
	Global.temp.current_editing_date_dict = Time.get_date_dict_from_system()
	Global.temp.current_editing_days = Ctdate.total_days(Global.temp.current_editing_date_dict)
	read_date()
	read_content()
	pass # Replace with function body.

func _ready():
	#加载一些东西
	#这里检测一下屏幕方向变化，如果屏幕旋转导致方向改变可选择性隐藏左栏
	get_tree().get_root().connect("size_changed", change_content_visibility)
	change_content_visibility()
	#根据以前的存档改一下分隔栏的位置
	$HSplitContainer.set_split_offset(Global.global_config.current_split_offset)
	#初始化一些子节点
	#这里已经在编辑器里连接了信号，就不另外连了
	#diary_instance.connect("note_saved",refresh_calendar_title)
	#diary_instance.connect("note_saved",refresh_content_title)
	connect("load_diary",Tabs.get_node("日记").refresh_diary)
	#

	Tabs.set_tab_hidden(Tabs.get_tab_idx_from_control(MissionSettings),true)
	Tabs.set_tab_hidden(Tabs.get_tab_idx_from_control(TaskSettings),true)
	
	load_date()
	load_content()
	#$"HSplitContainer/VBoxContainer2/TabContainer/日记".refresh_diary()
#	$"HSplitContainer/VBoxContainer2/TabContainer/日常".load_mission()
	DailyMission.load_mission()
	DailyTask.load_task()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$HSplitContainer/VBoxContainer2/Label.text=(String.num(Input.get_gravity()[0]))
	pass

#选择性隐藏左栏
func change_content_visibility():
	#如果需要在竖屏状态隐藏左栏
	#宽大于等于高则显示，否则不显示
	if Global.global_config.portrait_hide_content:
		$HSplitContainer/VBoxContainer.set_visible(get_viewport_rect().size[0]>=get_viewport_rect().size[1])
		pass
	pass

func read_date():
	#如果没有日期所对应的记录，就先新建一个
	if not FileAccess.file_exists("%s/%s.json" % [Global.DIARY_DIR_PATH,Global.temp.current_editing_date]):
		new_date()
	else:
		##现在可以开始加载了
		#从文件加载
		Global.read_calendar()
	pass
	
func read_content():
	#处理配置文件不存在的情况或加载配置
	#用else的原因是，new_content没有写入配置文件，直接读仍会出错
	if not FileAccess.file_exists(Global.CONTENT_CONFIG_PATH):
		new_content()
	else:
		Global.read_content()
	pass
	

#加载左边的栏
func load_content():
	#TODO
	#这里最好处理一下指定的配置不存在、甚至加载了空配置的情况，增加健壮性
	var current_config = Global.content_config[Global.global_config.default_content_config]
	$HSplitContainer/VBoxContainer/SpinBox.set_min(current_config.range[0])
	$HSplitContainer/VBoxContainer/SpinBox.set_max(current_config.range[1])
	$HSplitContainer/VBoxContainer/SpinBox.set_custom_minimum_size(Vector2(current_config.min_width,0))
	#这个时候再手动链接SpinBox改变事件，以防前面的改动造成误处理
	$HSplitContainer/VBoxContainer/SpinBox.connect("value_changed",_on_spin_box_value_changed)
	#这里改变了value，应该会触发_on_spin_box_value_changed事件
	#剩下的事情就让事件处理吧
	$HSplitContainer/VBoxContainer/SpinBox.set_value(clamp(Global.global_config.current_content_pos,current_config.range[0],current_config.range[1]))
	#WARNING由于未知原因导致事件没有触发，所以手动执行一下!
	_on_spin_box_value_changed(clamp(Global.global_config.current_content_pos,current_config.range[0],current_config.range[1]))
	pass

#好像也没什么要处理的:P
#毕竟因为日记已经初始化，Calendar0文件夹肯定存在
#直接写也不会报错的应该吧...出错再说
#还是来处理咯
func new_content():
	#DirAccess.make_dir_recursive_absolute("user://Calendar0")
	Global.content_config = Global.DEFAULT_CONTENT_CONFIG
	pass
	
#通过传入的日期(字符串比如2022-02-02)加载对应的日记、任务
#func load_date(date):
#	#如果没有日期所对应的记录，就先新建一个
#	if not FileAccess.file_exists("user://Calendar0/Diary/%s.txt" % date):
#		new_date(date)
#	#现在可以开始加载了
#	calendar_config = await Global.read_json("user://Calendar0/Diary/%s.txt" % date, "存档文件损坏")
#	$HSplitContainer/VBoxContainer2/Label.text = calendar_config.notes.substr(0,calendar_config.notes.find("\n"))
#	#如果diary没有被添加进树里就添加进去
#	if not has_node("HSplitContainer/VBoxContainer2/TabContainer/日记"):
#		diary_instance.set_name("日记")
#		add_child(diary_instance)
#
#	pass
#
##新建日期记录
#func new_date(date):
#	#如果存放记录的文件夹不存在，就新建它
#	DirAccess.make_dir_recursive_absolute("user://Calendar0/Diary")
#	#然后按此模板写文件
#	FileAccess.open("user://Calendar0/Diary/%s.txt" % date,FileAccess.WRITE).store_string("""{"version":0,
#"notes":"%s, Day %s\nWrite Something Here...",
#"tasks":"",
#"missions":""}"""%[date, 1+Ctdate.diff_days(Time.get_datetime_dict_from_datetime_string(date,false),Time.get_datetime_dict_from_datetime_string(Global.player_config.start_date,false))])
#	pass
#

#通过日期(Global.temp.current_editing_date)加载对应的日记、任务
func load_date():
	#$HSplitContainer/VBoxContainer2/Label.text = calendar_config.notes.substr(0,calendar_config.notes.find("\n"))
	refresh_calendar_title()
#	#如果diary没有被添加进树里就添加进去
#	if not has_node("HSplitContainer/VBoxContainer2/TabContainer/日记"):
#		diary_instance.set_name("日记")
#		#diary_instance.connect("note_saved",Callable(self,"refresh_calendar_title"))
#		#在写日记的时候，随时检查是否更新标题
#		diary_instance.connect("note_saved",refresh_calendar_title)
#		diary_instance.connect("note_saved",refresh_content_title)
#		connect("load_diary",diary_instance.refresh_diary)
#		$HSplitContainer/VBoxContainer2/TabContainer.add_child(diary_instance)
#	emit_signal("load_diary")
	#如果diary没有被添加进树里就添加进去
	#if not has_node("HSplitContainer/VBoxContainer2/TabContainer/日记"):
	#	diary_instance.set_name("日记")
		#diary_instance.connect("note_saved",Callable(self,"refresh_calendar_title"))
		#在写日记的时候，随时检查是否更新标题
	#$HSplitContainer/VBoxContainer2/TabContainer.add_child(diary_instance)
	emit_signal("load_diary")
	pass

#新建日期记录
func new_date():
	#如果存放记录的文件夹不存在，就新建它
	DirAccess.make_dir_recursive_absolute(Global.DIARY_DIR_PATH)
	Global.calendar_config = Global.DEFAULT_CALENDAR_CONFIG.duplicate()
	#然后按此模板写文件
#	FileAccess.open("user://Calendar0/Diary/%s.txt" % Global.temp.current_editing_date,FileAccess.WRITE).store_string("""{"version":0,
#"notes":"%s, Day %s\nWrite Something Here...",
#"tasks":"",
#"missions":""}"""%[Global.temp.current_editing_date, 1+Ctdate.diff_days(Time.get_datetime_dict_from_datetime_string(Global.temp.current_editing_date,false),Time.get_datetime_dict_from_datetime_string(Global.player_config.start_date,false))])
#	pass
	

#加载日历和日记的第一句作为标题
func refresh_calendar_title():
	$HSplitContainer/VBoxContainer2/Label.set_text("%s, Day %s\n《%s》"%[Global.temp.current_editing_date, 1+Ctdate.diff_days(Global.temp.current_editing_date_dict,Time.get_datetime_dict_from_datetime_string(Global.global_config.start_date,false)),Global.calendar_config.notes.substr(0,Global.calendar_config.notes.find("\n"))])
#	$HSplitContainer/VBoxContainer2/Label.set_text("%s, Day %s\n《%s》"%[Global.temp.current_editing_date, 1+Ctdate.diff_days(Time.get_datetime_dict_from_datetime_string(Global.temp.current_editing_date,false),Time.get_datetime_dict_from_datetime_string(Global.global_config.start_date,false)),Global.calendar_config.notes.substr(0,Global.calendar_config.notes.find("\n"))])

#TODO一直计算标题很烦的，要不在编辑完的时候就计算了？
#刷新左栏对应日期标题
func refresh_content_title():
	#如果左栏当前有当前编辑的日期，就得记得更新
	#当然，只会更新一个
	var pos = items.find(roundi(1+Global.temp.current_editing_days-Global.global_config.start_days))
	if pos>=0:
		var title = Global.calendar_config.notes.substr(0,Global.calendar_config.notes.find("\n"))
		if title.is_empty():
			$HSplitContainer/VBoxContainer/ItemList.set_item_text(pos,Global.temp.current_editing_date)
		else:
			$HSplitContainer/VBoxContainer/ItemList.set_item_text(pos,title)
		
		
	


#根据改变的值改ItemList
func _on_spin_box_value_changed(value):
	Global.set_global("current_content_pos",value)
	#这是当前的config
	var current_config = Global.content_config[Global.global_config.default_content_config]
	#刷新prefix, suffix
	$HSplitContainer/VBoxContainer/SpinBox.set_prefix(Ctutils.evaluate(current_config.prefix).call(value))
	$HSplitContainer/VBoxContainer/SpinBox.set_suffix(Ctutils.evaluate(current_config.suffix).call(value))
	#先清空ItemList,再一项一项添加进去，谓之刷新
	$HSplitContainer/VBoxContainer/ItemList.clear()
	#记录下数据备用
	items = Ctutils.evaluate(current_config.mapping).call(value)
	for i in items:
		#这里用一个函数计算日期对应的字符串
		#TODO以后并到config里使其可自动化
		#有日记标题就用标题，否则日期
		$HSplitContainer/VBoxContainer/ItemList.add_item((func(day):
			#如果所需的文件存在且有日记标题
			var date_string = Ctdate.get_date_string_from_date_dict(Ctdate.diff_date(Time.get_datetime_dict_from_datetime_string(Global.global_config.start_date,false),day-1))
			var path = "%s/%s.json"%[Global.DIARY_DIR_PATH,date_string]
			if FileAccess.file_exists(path):
				var config = await Global.read_json(path,"日期文件损坏")
				var config_note = config.notes.substr(0,config.notes.find("\n"))
				if not config_note.is_empty():
					return config_note
			return date_string
			).call(i),null,true)
		pass
	pass # Replace with function body.

#根据点击更新日记
func _on_item_list_item_selected(index):
	Global.temp.current_editing_days = Global.global_config.start_days+items[index]-1
	Global.temp.current_editing_date_dict = Ctdate.get_date(Global.temp.current_editing_days)
	Global.temp.current_editing_date = Ctdate.get_date_string_from_date_dict(Global.temp.current_editing_date_dict)
	read_date()
	load_date()
#	$"HSplitContainer/VBoxContainer2/TabContainer/日常".load_mission()
	DailyMission.load_mission()
	DailyTask.load_task()
	pass # Replace with function body.


#当拖到分隔栏时记录下位置，以便以后加载。
func _on_h_split_container_dragged(offset):
	Global.set_global("current_split_offset",offset)
	pass # Replace with function body.

func start_editing_mission():
	#打开任务设置栏
	Tabs.set_tab_hidden(Tabs.get_tab_idx_from_control(MissionSettings),false)
	MissionSettings.read_data()
	Tabs.set_current_tab(Tabs.get_tab_idx_from_control(MissionSettings))

func start_editing_task():
	#打开工作设置栏
	Tabs.set_tab_hidden(Tabs.get_tab_idx_from_control(TaskSettings),false)
	TaskSettings.prepare_task()
	Tabs.set_current_tab(Tabs.get_tab_idx_from_control(TaskSettings))
	

func _on_tab_container_tab_changed(tab):
	#关闭任务设置栏
	if (not Tabs.is_tab_hidden(Tabs.get_tab_idx_from_control(MissionSettings))) and tab != Tabs.get_tab_idx_from_control(MissionSettings):
		Tabs.set_tab_hidden(Tabs.get_tab_idx_from_control(MissionSettings),true)
		read_date()
		load_date()
		DailyMission.load_mission()
	#关闭工作设置栏
	if (not Tabs.is_tab_hidden(Tabs.get_tab_idx_from_control(TaskSettings))) and tab != Tabs.get_tab_idx_from_control(TaskSettings):
		Tabs.set_tab_hidden(Tabs.get_tab_idx_from_control(TaskSettings),true)
		read_date()
		load_date()
		DailyTask.load_task()
	pass # Replace with function body.

func _on_back_to_task():
	Tabs.set_current_tab(Tabs.get_tab_idx_from_control(DailyTask))
	pass # Replace with function body.
