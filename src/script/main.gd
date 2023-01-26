extends Control

# Called when the node enters the scene tree for the first time.
func _enter_tree():
	#一些测试
	#print(Ctdate.total_days(Time.get_datetime_dict_from_datetime_string("2022-09-26", false)))
#	print(Ctdate.get_date(Ctdate.total_days(Time.get_datetime_dict_from_datetime_string("0-1-1", false))))
#	print(Ctdate.get_date(Ctdate.total_days(Time.get_datetime_dict_from_datetime_string("2018-1-1", false))))
#	print(Ctdate.get_date(Ctdate.total_days(Time.get_datetime_dict_from_datetime_string("21474836-4-8", false))))
#	print(Ctdate.get_date(Ctdate.total_days(Time.get_datetime_dict_from_datetime_string("2147483647-12-31", false))))
#	print(Ctdate.get_date(Ctdate.total_days(Time.get_datetime_dict_from_datetime_string("100100100-12-31", false))))
#	print(Ctdate.get_date(Ctdate.total_days(Time.get_datetime_dict_from_datetime_string("190000-1-1", false))))
#	print(Ctdate.get_date(Ctdate.total_days(Time.get_datetime_dict_from_datetime_string("1900-12-31", false))))
	#读取存档
	read_config()
	load_properties()
	pass # Replace with function body.

func _ready():
#	get_tree().get_root().connect("size_changed",wrap_content_size)
#	pass
	var i = randi_range(0,10)
	if i in range(0,8):
		$ColorRect.set_color(Color("#c8c8a9"))
	if i in range(0,7):
		$ColorRect.set_color(Color("#83af9b"))
	if i in range(0,6):
		$ColorRect.set_color(Color("#9f84ae"))
	if i in range(0,5):
		$ColorRect.set_color(Color("#c3a6cb"))
	if i in range(0,4):
		$ColorRect.set_color(Color("#87c1fa"))
	if i in range(0,3):
		$ColorRect.set_color(Color("#ec95cc"))
	if i in range(0,2):
		$ColorRect.set_color(Color("#e6d933"))
	if i in range(0,1):
		$ColorRect.set_color(Color("#ffffff"))
	$TabContainer.set_current_tab(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func wrap_content_size():
#	pass
#	#如果横屏，则设置宽1152高648，反之高1152宽648
#	var i = get_viewport_rect().size[0]>=get_viewport_rect().size[1]
#	ProjectSettings.set_setting("display/window/size/viewport_width",648 if i else 648)
#	ProjectSettings.set_setting("display/window/size/viewport_height",648 if i else 648)
#	print(ProjectSettings.get_setting("display/window/size/viewport_width"))

#func read_config():
#	#存档文件为用户目录下的player0.json，以JSON格式存储
#	#检测存档是否存在，如果是就以JSON格式加载，如果加载有误就报错
#	#（如果加载没问题但数据本身有问题那就没办法处理了
#	if FileAccess.file_exists("user://player0.json"):
#		#读取配置和存档
#		Global.read_global()
#		Global.player_config = await Global.read_json("user://player0.json","存档文件存在但已损坏:3\n")
##		var json = JSON.new()
##		var error = json.parse(FileAccess.open("user://player0.json",FileAccess.READ).get_as_text())
##		if error == OK:
##			Global.player_config = json.data
##			return
##		$AcceptDialog.dialog_text = "存档文件存在但已损坏:3\n" + error
##		$AcceptDialog.popup_centered()
##		#TODO 退出APP
#	#存档存在的情况上面已经处理完毕
#	#如果存档不存在，就进行一些初始化操作
#	user_initialize()
#	pass
	
func read_config():
	#读取global_config
	if not FileAccess.file_exists(Global.GLOBAL_CONFIG_PATH):
		Global.global_config = Global.DEFAULT_GLOBAL_CONFIG.duplicate()
		Global.global_config.start_date = Time.get_date_string_from_system()
		Global.global_config.start_days = Ctdate.total_days(Time.get_date_dict_from_system())
	else:
		#读取配置
		Global.read_global()
	#存档文件为用户目录下的player0.json，以JSON格式存储
	#检测存档是否存在，如果是就以JSON格式加载，如果加载有误就报错
	#（如果加载没问题但数据本身有问题那就没办法处理了
	if not FileAccess.file_exists(Global.PLAYER_CONFIG_PATH):
		user_initialize()
	else:
		#读取存档
		Global.player_config = await Global.read_json(Global.PLAYER_CONFIG_PATH,"存档文件存在但已损坏:3\n")
#		var json = JSON.new()
#		var error = json.parse(FileAccess.open("user://player0.json",FileAccess.READ).get_as_text())
#		if error == OK:
#			Global.player_config = json.data
#			return
#		$AcceptDialog.dialog_text = "存档文件存在但已损坏:3\n" + error
#		$AcceptDialog.popup_centered()
#		#TODO 退出APP
	#存档存在的情况上面已经处理完毕
	#如果存档不存在，就进行一些初始化操作
	pass

func load_properties():
	#载入主选项卡
	#var properties_instance = preload("res://scene/properties.tscn").instantiate()
	#$TabContainer/properties.set_name("封面")
	#$TabContainer.add_child(properties_instance)
	#载入日历选项卡
	#var calendar_instance = preload("res://scene/calendar.tscn").instantiate()
	#$TabContainer/calendar.set_name("日常")
	#$TabContainer.add_child(calendar_instance)
	
	pass

func user_initialize():
#	#记录第一次打开游戏的日期字符串
#	Global.global_config.start_date = Time.get_date_string_from_system()
#	Global.global_config.start_days = Ctdate.total_days(Time.get_date_dict_from_system())
	#等等等等......
	pass
