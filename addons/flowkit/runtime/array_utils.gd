extends RefCounted
class_name ArrayUtils

static func _get_fk_units_in(arr: Array) -> Array[FKUnit]:
	var result: Array[FKUnit] = []
	
	for child in arr:
		if child is FKUnit:
			result.append(child)
			
	return result
	
static func _get_fk_action_units_in(arr: Array) -> Array[FKActionUnit]:
	var result: Array[FKActionUnit] = []
	
	for child in arr:
		if child is FKActionUnit:
			result.append(child)
			
	return result
	
static func _get_fk_condition_units_in(arr: Array) -> Array[FKConditionUnit]:
	var result: Array[FKConditionUnit] = []
	
	for child in arr:
		if child is FKConditionUnit:
			result.append(child)
			
	return result
