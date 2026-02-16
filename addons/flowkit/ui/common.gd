class_name FKCommon

static var path_to_events_folder := "res://addons/flowkit/events"
static func recent_items_manager_script() -> Resource:
	return load("res://addons/flowkit/ui/modals/recent_items_manager.gd")

static var system_node_path := "/root/FlowKitSystem"
static var sheet_path_format := "res://addons/flowkit/saved/event_sheet/%d.tres"
static var sys_node_name := "System"
