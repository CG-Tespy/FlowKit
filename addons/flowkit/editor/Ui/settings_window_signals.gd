extends RefCounted
class_name FKSettingsWindowSignals

signal editor_path_choice_changed(old_path: String, new_path)
signal editor_path_removal_requested(path_field: FKPathField)
signal editor_path_browse_start()
signal editor_path_browse_end()