extends RefCounted
class_name FKSheetEntry

func _init(sheet: FKEventSheet, root: Node, scene_name: String, uid: int):
	self.sheet = sheet
	self.root = root
	self.scene_name = scene_name
	self.uid = uid

var sheet: FKEventSheet
var root: Node
var scene_name: String
var uid: int
