extends RefCounted
class_name FKSheetController

var sheet: FKEventSheet
var sheet_path: String

func load_sheet(path: String):
	sheet_path = path
	sheet = ResourceLoader.load(path, "FKEventSheet", ResourceLoader.CACHE_MODE_IGNORE)

func save_sheet():
	if sheet:
		ResourceSaver.save(sheet, sheet_path)
