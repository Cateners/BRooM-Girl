extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Ctvars.connect("objects_updated",refresh_text)
	refresh_text()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func refresh_text():
	$VBoxContainer/RichTextLabel.text="""[shake rate=5 level=5]%s

Level %s
Experience %s[color=red]/1000[/color]

拥有的物品：
%s[/shake]""" % [Global.player_config.name, Global.player_config.level, Global.player_config.experience, "(无)" if Global.player_config.objects.strip_edges().length()==0 else Global.player_config.objects]

