extends Node

signal objects_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	load_vars()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_vars():
	#读取物品配置
	if not FileAccess.file_exists(Global.OBJECT_CONFIG_PATH):
		Global.object_config = Global.DEFAULT_OBJECT_CONFIG
	else:
		Global.read_object()
	#解析已拥有物品信息
	#最终生成一个Global.temp.object_list数组[[物品1，数量1],[物品2，数量2],[物品3，数量3],[物品4，数量4],...]
	Global.temp.object_array = [] if Global.player_config.objects.strip_edges().length() == 0 else Array(Global.player_config.objects.strip_edges().split("\n",false)).map(func(x):return x.strip_edges())
	Global.temp.object_list = []
	for i in Global.temp.object_array:
		var pos = Ctutils.find_last(i," ")
		Global.temp.object_list.append([i.substr(0,pos).strip_edges(),Ctutils.evaluate(i.substr(pos))])
	pass

func set_vars(n,v):
	if n=="exp.":
		set_exp(v)
		return
	#记录变量在物品配置的位置
	var config_pos = var_config_pos(n)
	#找到变量在数组中的位置
	var i_pos = 0
	for i in Global.temp.object_list:
		if i[0]==n:
			break;
		i_pos+=1
	#找不到就新建一个
	if i_pos==Global.temp.object_list.size():
		Global.temp.object_list.append([n,v if config_pos<0 else Global.object_config[config_pos].default])
	#如果物品配置里有该变量信息，还得检查下数值是否越界
	if config_pos>=0:
		#如果低于最小值:
		Global.temp.object_list[i_pos][1] = Ctutils.evaluate(Global.object_config[config_pos].range[0])
		if v<Global.temp.object_list[i_pos][1]:
			Ctutils.evaluate(Global.object_config[config_pos].too_little).call(Global.temp.object_list[i_pos][1]-v)
		else:
			#如果高于最大值
			Global.temp.object_list[i_pos][1] = Ctutils.evaluate(Global.object_config[config_pos].range[1])
			if v>Global.temp.object_list[i_pos][1]:
				Ctutils.evaluate(Global.object_config[config_pos].too_much).call(v-Global.temp.object_list[i_pos][1])
			else:
				Global.temp.object_list[i_pos][1] = v
	else:
		#没有信息，直接赋值就好，或者数值为0的话直接删掉那一项
		Global.temp.object_list[i_pos][1] = v
		if v==0:
			Global.temp.object_list.remove_at(i_pos)
	#现在数据已经赋上，将其保存
	Global.set_player("objects","\n".join(PackedStringArray(Global.temp.object_list.map(func(i):return " ".join(PackedStringArray(i))))))
	#发出信号通知刷新
	emit_signal("objects_updated")
	pass

func get_vars(n):
	if n=="exp.":
		return get_exp()
	#记录变量在物品配置的位置
	var config_pos = var_config_pos(n)
	#找到变量在数组中的位置,找到了直接返回值
	for i in Global.temp.object_list:
		if i[0]==n:
			return i[1]
	if config_pos<0:
		return 0
	return Global.object_config[config_pos].default	


#这个变量在物品配置中的位置，，找不到就-1
func var_config_pos(n):
	var i_pos = 0
	for i in Global.object_config:
		if i.name==n:
			break;
		i_pos+=1
	if i_pos==Global.object_config.size():
		i_pos=-1
	return i_pos

func set_exp(v):
	while v>=1000:
		Global.player_config.level+=1
		v-=1000
	Global.set_player("experience",clamp(v,0,1000))
	emit_signal("objects_updated")
	pass

func get_exp():
	return Global.player_config.experience
	pass
