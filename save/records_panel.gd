extends PopupPanel

var beginner = 999
var intermediate = 999
var advanced = 999

func update_label():
	$Panel/Label.text = '[center][b]Iniciante:[/b] ' + str(beginner) + '\n[b]Intermediário:[/b] ' + str(intermediate) + '\n[b]Avançado:[/b] ' + str(advanced)

func _on_close_requested():
	visible = false
