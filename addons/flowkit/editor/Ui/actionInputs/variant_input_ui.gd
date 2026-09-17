@tool
extends FKActionInputUi
class_name FKVariantActionInputUi

@export var line_edit: LineEdit

func get_value() -> Variant:
	return line_edit.text

func _can_hold_value(value: Variant) -> bool:
	return true

func _set_value(value: Variant) -> void:
	line_edit.text = str(value)

func get_class() -> String:
	return "FKVariantActionInputUi"