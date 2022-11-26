extends Node

#配置文件路径常量
const PREFIX_PATH_DIR = "user:/"
#const PREFIX_PATH_DIR = "/storage/emulated/0/Android/data/com.fctstudio.ms15/files"
const PLAYER_CONFIG_PATH = "%s/player0.json"%PREFIX_PATH_DIR
const GLOBAL_CONFIG_PATH = "%s/global_config.json"%PREFIX_PATH_DIR
const DIARY_DIR_PATH = "%s/Calendar0/Diary"%PREFIX_PATH_DIR
const CONTENT_CONFIG_PATH = "%s/Calendar0/content.json"%PREFIX_PATH_DIR
const MISSION_CONFIG_PATH = "%s/Calendar0/mission.json"%PREFIX_PATH_DIR
const TASK_CONFIG_PATH = "%s/Calendar0/task.json"%PREFIX_PATH_DIR
const OBJECT_CONFIG_PATH = "%s/object_config.json"%PREFIX_PATH_DIR
#const PLAYER_CONFIG_PATH = "user://player0.json"
#const GLOBAL_CONFIG_PATH = "user://global_config.json"
#const DIARY_DIR_PATH = "user://Calendar0/Diary"
#const CONTENT_CONFIG_PATH = "user://Calendar0/content.json"
#const MISSION_CONFIG_PATH = "user://Calendar0/mission.json"
#const OBJECT_CONFIG_PATH = "user://object_config.json"

#一些配置文件常量
const DEFAULT_PLAYER_CONFIG = {
	"version":0,
	"name":"The Hero",
	"level":1,
	"experience":0,
	"current_progress":"dev",
	"objects":""
#	"objects":"coin 3\ngem 4\nComputer 1"
}

const DEFAULT_GLOBAL_CONFIG = {
	"version":0,#config版本
	"start_date":"2018-01-01",#第一次打开游戏的日期字符串
	"start_days":737060,#第一次打开游戏的日期数(距离0年1月1日)
	"default_content_config":0,#使用第几个作为左栏配置？模板位于user://Calendar0/content0.json
	"current_content_pos":0,#目前左栏的数字？
	"current_split_offset":0,#HSplitContainer位置
	"current_calendar_tab":0,#目前在看日记，任务，还是工作
	"past_diary_viewonly":true,#以前的日记是否设为只读
	"portrait_hide_content":true,#竖屏是否隐藏左栏
	"portrait_min_content":true,#如果你不想隐藏左栏，那需要尽可能调小左栏的宽度吗？
	"force_score_modify":false,#是否允许在有分数的情况下修改分数项
	"force_score_today":true,#是否只允许修改今天的分数项
	"default_mission_config":0,#选择第几个每日任务配置
	#下面只是暂时使用的全局变量，其实也不需要被存储
#	"current_editing_date":"2022-09-26",
#	"current_editing_days":738789,
	#每日任务模板
	#"current_mission",#:Dictionary,
	#从任务模板解析到的任务(字符串)数组(也包括不是任务的字段)
	#"mission_array",#:Array,
	#从calendar中解析到的已完成任务的数组
	#"completed_array",#:Array,
	#模板总分数
	#"mission_score",
	#包括额外任务一共获得的分数
	#"total_score"
}

const DEFAULT_CALENDAR_CONFIG = {
	"version":0,
	"notes":"",
#	"notes":"日记的第一行将作为标题\nWrite Something Here...\nMeow",
	"tasks":"",
	#记录已完成的每日任务。
	"missions":"",
#	"missions":"吃早餐 7\n喝早茶 5",
	#今日分数
	"missions_score":0,
	#记录因完成mission而得到的奖励
	#格式一样，但最后永远是常量。
	"missions_reward":""""""
}

const DEFAULT_CONTENT_CONFIG = [
	{
		"version":0,#配置版本号
		"description":"按星期组织每一天(从第一次打开app算起)",
		"min_width":100,#最小宽度
		"range":[1,52],#数字范围
		#mapping:一个函数，描述在每个数字x下应该显示哪些天(以start_date作为第一天)
		#这里数字范围是1到52，就是指第一周到第52周
		#第1周需要显示第1天到第7天，所以下面应该是7天的数组，x=1时刚好是[1,2,3,4,5,6,7]
		#x=2时是[8,9,10,11,12,13,14]，以此类推
		"mapping":"""func(x:int):return [7*x-6,7*x-5,7*x-4,7*x-3,7*x-2,7*x-1,7*x]""",
		#在这个配置里期望显示Week 1, Week 2,...
		"prefix":"""func(x):return "Week" """,#显示在数字前面的字，这里显示Week
		"suffix":"""func(x):return "" """,#显示在数字后面的字，这里不显示
		#"title":""
	},
	{
		"version":0,#配置版本号
		"description":"按月份组织每一天(从今年第一天算起)",
		"min_width":100,#最小宽度
		"range":[1,12],#数字范围
		#mapping:一个函数，描述在每个数字x下应该显示哪些天(以start_date作为第一天)
		#这里数字范围是1到12，指12个月份
		#lambda初始2个换行符!!!另外最后的引号单独一行
		#别听上面的
		"mapping":"""func(x:int):
	var date=Time.get_datetime_dict_from_system()
	date.month=x
	date.day=1
	return range([31,29 if (date.year%4==0 and date.year%100!=0) or date.year%400==0 else 28,31,30,31,30,31,31,30,31,30,31][x-1]).map(func(y):return 1+y+Ctdate.total_days(date)-Global.global_config.start_days)
		""",
		"prefix":"""func(x):return ["January","February","March","April","May","June","July","Augest","September","October","November","December"][x-1] """,#显示在数字前面的字，这里显示Week
		"suffix":"""func(x):return "" """,#显示在数字后面的字，这里不显示
		
	},
]

#简单的每日任务默认配置。
#mission是所有的每日任务。
#target指满多少分后分数会变红。
#reward指满多少分后会获得什么奖励。
const DEFAULT_MISSION_CONFIG = [{
	"version":0,
	"description":"平静的一天",
	#mission的格式:"任务名 分数"
	"mission":"""早上
7:30前起床 5
仔细刷牙洗脸 7
喝水 5
吃早餐 7
早上跑步锻炼10min 10
滴眼药水（需要的话 5
日常
充分利用了一节课的时间 1次 15
充分利用了一节课的时间 2次 15
充分利用了一节课的时间 3次 15
充分利用了一节课的时间 4次 15
充分利用了一节课的时间 5次 15
睡午觉 8
晚上
20:30前洗澡 10
21:00前开始洗衣（需要的话 10
睡觉前刷牙 18
22:30前睡觉 20
准备明天穿的衣服 8
其它
吃水果 3
上厕所 4
给Citrus浇水 3
和Clivo交流一段时间 10
平安报 1
核酸检测（需要的话 3
走满10000步 5
累计喝1杯水 3
累计喝2杯水 3
累计喝3杯水 3
累计喝4杯水 3
累计喝5杯水 3
累计喝6杯水 3
晚上累计跑步10min 10
晚上累计跑步15min 5
晚上累计跑步20min 5
一次性做了10个引体向上 10
累计喝1次夜宁颗粒 5
累计喝2次夜宁颗粒 5
""",
	"target":144,
	#reward格式:”分数 物品 数量“
	#关于稍后如何解析:
	#先按回车符分行;
	#找第一个空格，前面即为要达到的分数
	#找最后一个空格，后面即为获得物品的数量(会使用evaluate解析，所以可以是简单的表达式)
	#中间是货币名称。解析时会使用strip_edges()删掉前后的不可打印字符(如多出来的空格)。
	"reward":"""
100 coin 100
200 Wishes Flower 1
256 Bonus Reward 0.05
	""",
},{
	"version":0,
	"description":"天街小雨润如酥",
	#mission的格式:"任务名 分数"
	"mission":"""(雨天适用)
早上
7:50前起床 5
仔细刷牙洗脸 7
喝水 5
吃早餐 7
滴眼药水（需要的话 5
日常
充分利用了一节课的时间 1次 15
充分利用了一节课的时间 2次 15
充分利用了一节课的时间 3次 15
充分利用了一节课的时间 4次 15
充分利用了一节课的时间 5次 15
睡午觉 8
晚上
20:30前洗澡 10
21:00前开始洗衣（需要的话 10
睡觉前刷牙 18
22:30前睡觉 20
准备明天穿的衣服 8
其它
吃水果 3
上厕所 4
给Citrus浇水 3
和Clivo交流一段时间 10
平安报 1
核酸检测（需要的话 5
累计喝1杯水 3
累计喝2杯水 3
累计喝3杯水 3
累计喝4杯水 3
累计喝5杯水 3
累计喝6杯水 3
累计喝1次夜宁颗粒 5
累计喝2次夜宁颗粒 5
上厕所不看手机 5
上电梯不看手机 5
""",
	"target":144,
	#reward格式:”分数 物品 数量“
	#关于稍后如何解析:
	#先按回车符分行;
	#找第一个空格，前面即为要达到的分数
	#找最后一个空格，后面即为获得物品的数量(会使用evaluate解析，所以可以是简单的表达式)
	#中间是货币名称。解析时会使用strip_edges()删掉前后的不可打印字符(如多出来的空格)。
	"reward":"""
60 coin 100
144 gem 1
200 Wishes Flower 1
240 Bonus Reward 0.05
	""",
},{
	"version":0,
	"description":"Hero视角",
	#mission的格式:"任务名 分数"
	"mission":"""一般任务
住所能量加固 5
充能 5000mAh 10
充能 10000mAh 10
充能 30000mAh 10

探索任务
任意level探索度增加达1% 5
任意level探索度增加达2% 5
任意level探索度增加达3% 8
到达新的level 10
""",
	"target":32,
	#reward格式:”分数 物品 数量“
	#关于稍后如何解析:
	#先按回车符分行;
	#找第一个空格，前面即为要达到的分数
	#找最后一个空格，后面即为获得物品的数量(会使用evaluate解析，所以可以是简单的表达式)
	#中间是货币名称。解析时会使用strip_edges()删掉前后的不可打印字符(如多出来的空格)。
	"reward":"""
20 记忆晶片 1
30 记忆碎片 1
40 记忆晶片 2
50 记忆闪电 1
	""",
}]

#用于物品的config
const DEFAULT_OBJECT_CONFIG = [
	{
		#一些货币基本信息，名称，介绍，范围等。
		"name":"coin",
		"description":"Base object for all games.",
		"range":["0","9999999"],
		#如果超出范围该怎么做。参数是超出的量的绝对值。
		"too_much":"func(x):return",
		"too_little":"func(x):return",
		#物品的默认(初始)值。
		"default":0,
		#物品被主动使用的效果
		#"use":""
	}
]

const DEFAULT_TASK_CONFIG = []

#var test = Time.get_datetime_dict_from_datetime_string()

#存储玩家的存档的变量。
var player_config = DEFAULT_PLAYER_CONFIG

#一些全局变量
var global_config# = DEFAULT_GLOBAL_CONFIG

#暂时存放读取的calendar信息的Dictionary
var calendar_config #= DEFAULT_CALENDAR_CONFIG

#这是"日常"左栏的配置
var content_config = DEFAULT_CONTENT_CONFIG

var mission_config

var object_config

var task_config

#以后临时变量慢慢迁移到这里
var temp = {
	"is_human_pressing": true,
#
#	"current_editing_date":"2022-09-26",
#	"current_editing_days":738789,
#	"current_editing_date_dict"
#	#每日任务模板
#	#"current_mission",#:Dictionary,
#	#从任务模板解析到的任务(字符串)数组(也包括不是任务的字段)
#	#"mission_array",#:Array,
#	#从calendar中解析到的已完成任务的数组
#	#"completed_array",#:Array,
#	#模板总分数
#	#"mission_score",
#	#包括额外任务一共获得的分数
#	#"total_score"
	#“current_editing_task”
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_player(key, value):
	player_config[key]=value
	FileAccess.open(PLAYER_CONFIG_PATH, FileAccess.WRITE).store_string(JSON.stringify(player_config))
	

#修改global_config并立即以JSON保存到文件
func set_global(key, value):
	global_config[key]=value
	FileAccess.open(GLOBAL_CONFIG_PATH, FileAccess.WRITE).store_string(JSON.stringify(global_config))
	pass

#需要保证配置文件存在
func read_global():
	global_config = await read_json(GLOBAL_CONFIG_PATH, "配置文件读取错误")

#修改calendar_config并立即以JSON保存到文件
func set_calendar(key, value):
	calendar_config[key]=value
	FileAccess.open("%s/%s.json"%[DIARY_DIR_PATH,temp.current_editing_date], FileAccess.WRITE).store_string(JSON.stringify(calendar_config))
	pass

#根据global_config的current_editing_date加载calendar_config
#同样，需要保证文件存在
func read_calendar():
	calendar_config = await read_json("%s/%s.json"%[DIARY_DIR_PATH,temp.current_editing_date], "日历文件读取错误")

#修改content_config并立即以JSON保存到文件
#func set_content(key, value):
#	content_config[key]=value
#	FileAccess.open(CONTENT_CONFIG_PATH, FileAccess.WRITE).store_string(JSON.stringify(content_config))
#	pass

#同样，需要保证文件存在
func read_content():
	content_config = await read_json(CONTENT_CONFIG_PATH, "左栏配置文件读取错误")

#等什么时候优化一下
#func set_content(key, value):
#	content_config[key]=value
#	FileAccess.open(CONTENT_CONFIG_PATH, FileAccess.WRITE).store_string(JSON.stringify(content_config))
#	pass


#mission_config以JSON保存到文件
func set_mission():
	FileAccess.open(MISSION_CONFIG_PATH, FileAccess.WRITE).store_string(JSON.stringify(mission_config))
	pass
	
#task_config以JSON保存到文件
func set_task():
	FileAccess.open(TASK_CONFIG_PATH, FileAccess.WRITE).store_string(JSON.stringify(task_config))
	pass

#同样，需要保证文件存在
func read_mission():
	mission_config = await read_json(MISSION_CONFIG_PATH, "每日任务配置文件读取错误")
	
#同样，需要保证文件存在
func read_task():
	task_config = await read_json(TASK_CONFIG_PATH, "工作配置文件读取错误")

#同样，需要保证文件存在
func read_object():
	object_config = await read_json(OBJECT_CONFIG_PATH, "物品配置文件读取错误")

#从path中读取JSON文件信息，并转换为Dictionary返回
#若不能解析为JSON，则弹出错误对话框(AcceptDialog)，信息为error_msg
#使用此函数需要保证文件存在！
func read_json(path, error_msg):
	#新建一个JSON实例用来解析文本，存放结果
	var json = JSON.new()
	var error = json.parse(FileAccess.open(path,FileAccess.READ).get_as_text())
	if error == OK:
		return json.data
	#新建一个AcceptDialog抛出错误
	var dialog = AcceptDialog.new()
	dialog.dialog_text = error_msg + error
	dialog.ok_button_text = "退出"
	#退出游戏函数
	var quit_func = func():get_tree().quit();
	dialog.connect("cancelled",quit_func)
	dialog.connect("confirmed",quit_func)
	get_tree().get_current_scene().add_child(dialog)
	dialog.popup_centered()
	await dialog.cancelled
	await dialog.confirmed
	pass
	
