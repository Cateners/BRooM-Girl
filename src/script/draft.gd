extends TabContainer


func find_last(str,what):
	var pos = str.find(what)
	while (str.find(what,pos+1))>=0:
		pos = str.find(what,pos+1)
	return pos

# Called when the node enters the scene tree for the first time.
func _ready():
#	print(find_last("012320","0"))
#	print("    3  45 \n  ".strip_edges())
#	print(["1","2","34"].find("3"+"4"))
#	print("Meow".substr(0,"Meow".find("o")))
#	print((func(x,y):return x+y).call(2,3))
#	var expression = Expression.new()
#	var error = expression.parse("5 if 1>1 else x",["x"])
#	if error != OK:
#		print(expression.get_error_text())
#	var result = expression.execute([1],self)
#	print(result)
	var eval = func(x):
		return 2*x
	print(eval.call(3))
	print(Time.get_datetime_dict_from_datetime_string("1245-",false))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not 1 in [1]:
		print(true)
		pass
	pass


func _on_spin_box_value_changed(value):
	#$Calendar/HSplitContainer/VBoxContainer/Label.text=String.num(value)
	pass # Replace with function body.


func evaluate(input):
	var script = GDScript.new()
	script.set_source_code("func eval():\n\treturn " + input)
	script.reload()
	var obj = RefCounted.new()
	obj.set_script(script)
	return obj.eval()
