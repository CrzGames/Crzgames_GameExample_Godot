extends Node

func _ready() -> void:
	print("Summator existe ? ", ClassDB.class_exists("Summator"))

	if ClassDB.class_exists("Summator"):
		var s := Summator.new()
		s.add(10)
		s.add(20)
		s.add(30)
		print("Total = ", s.get_total()) # devrait afficher 60
		s.reset()
		print("Après reset = ", s.get_total()) # 0
