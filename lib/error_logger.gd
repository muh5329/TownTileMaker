# Simple error logger that appends errors to user://error_log.txt
class_name ErrorLogger

static func log_error(message: String, details: String = "") -> void:
	var path := "user://error_log.txt"
	var line := "%s | ERROR: %s %s" % [String(OS.get_datetime()), message, details]
	# open file for append (create if missing)
	var file: FileAccess
	if FileAccess.file_exists(path):
		file = FileAccess.open(path, FileAccess.WRITE_READ)
		file.seek_end()
	else:
		file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_line(line)
		file.close()
	# Also push to Godot console
	push_error(line)

static func log_info(message: String) -> void:
	var path := "user://error_log.txt"
	var line := "%s | INFO: %s" % [String(OS.get_datetime()), message]
	var file: FileAccess
	if FileAccess.file_exists(path):
		file = FileAccess.open(path, FileAccess.WRITE_READ)
		file.seek_end()
	else:
		file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_line(line)
		file.close()
	print(line)
