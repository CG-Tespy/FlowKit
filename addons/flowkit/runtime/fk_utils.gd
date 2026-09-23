class_name FKUtils

static func is_valid_vec_two(string_input: String) -> bool:
	if not string_input.is_empty():
		var clean_string: String = string_input
		clean_string = clean_string.replace("(", "").replace(")", "")
		
		var parts: Array = clean_string.split(",")
		
		# A valid Vector2 string must have exactly 2 parts
		if parts.size() != 2:
			return false
			
		# Check if both parts are valid float strings
		var x_str: String = parts[0].strip_edges()
		var y_str: String = parts[1].strip_edges()
		
		return x_str.is_valid_float() and y_str.is_valid_float()
	
	return false

static func is_valid_vec_three(string_input: String) -> bool:
	if not string_input.is_empty():
		var clean_string: String = string_input
		clean_string = clean_string.replace("(", "").replace(")", "")
		
		var parts: Array = clean_string.split(",")
		
		# A valid Vector2 string must have exactly 2 parts
		if parts.size() != 3:
			return false
			
		# Check if both parts are valid float strings
		var x_str: String = parts[0].strip_edges()
		var y_str: String = parts[1].strip_edges()
		var z_str: String = parts[2].strip_edges()
		
		return x_str.is_valid_float() and y_str.is_valid_float() and z_str.is_valid_float()
	
	return false   

static func is_valid_vec_four(string_input: String) -> bool:
	if not string_input.is_empty():
		var clean_string: String = string_input
		clean_string = clean_string.replace("(", "").replace(")", "")
		
		var parts: Array = clean_string.split(",")
		
		# A valid Vector2 string must have exactly 2 parts
		if parts.size() != 4:
			return false
			
		# Check if both parts are valid float strings
		var x_str: String = parts[0].strip_edges()
		var y_str: String = parts[1].strip_edges()
		var z_str: String = parts[2].strip_edges()
		var w_str: String = parts[4].strip_edges()
		
		return x_str.is_valid_float() and y_str.is_valid_float() and \
		z_str.is_valid_float() and w_str.is_valid_float()
	
	return false   

## Takes into account the html and vec formats.
static func is_valid_color(string_input: String) -> bool:
	return Color.html_is_valid(string_input) or is_valid_vec_three(string_input) or is_valid_vec_four(string_input)

static func is_valid_bool(str: String) -> bool:
	return str == "true" or str == "false"

static func vec_three_to_color(vec: Vector3) -> Color:
	return Color(vec.x, vec.y, vec.z)

static func vec_four_to_color(vec: Vector4) -> Color:
	return Color(vec.x, vec.y, vec.z, vec.w)

## If the string is not a valid color, this returns white.
static func str_to_color(str: String) -> Color:
	var result: Color = Color.WHITE
	if is_valid_vec_three(str) or is_valid_vec_four(str):
		result = str_to_var("Color" + str)
	elif str.is_valid_html_color():
		result = Color(str)
	else:
		printerr("Cannot convert to color: " + str)

	return result