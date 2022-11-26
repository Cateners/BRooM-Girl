extends Node

var cttoast = preload("res://ui/CTToast.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#找到str字符串最后的what
func find_last(str,what):
	var pos = str.find(what)
	while (str.find(what,pos+1))>=0:
		pos = str.find(what,pos+1)
	return pos

#把"""
#xx xx
#xaa renamed
#da aedf
#"""这种字符串转换成[xx xx,xaa renamed,da aedf]这种列表
func to_array(s):
	return [] if s.strip_edges().length() == 0 else Array(s.strip_edges().split("\n")).map(func(x):return x.strip_edges())

#把字符串当代码解析
func evaluate(input):
	var script :GDScript = preload("res://script/empty.gd")#GDScript.new()
	script.set_source_code("var eval = func():return " + input)
	script.reload(true)
	var obj = RefCounted.new()
	obj.set_script(script)
	return obj.eval.call()

#就像安卓的toast
func showMessage(text, time=2, format=true):
	var cttoast_instance = cttoast.instantiate()
	get_tree().get_current_scene().add_child(cttoast_instance)
	cttoast_instance.showMessage(text, time, format)
	
#简单对话框
func simpleDialog(title, message, confirm_text, on_confirmed, on_cancelled):
	var dialog = AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.ok_button_text = confirm_text
	dialog.connect("cancelled",on_cancelled)
	dialog.connect("confirmed",on_confirmed)
	get_tree().get_current_scene().add_child(dialog)
	dialog.popup_centered()
	return dialog


