extends Node

const SETTINGS_FILE_PATH = "user://settings.cfg"
var config = ConfigFile.new()

func _ready() -> void:
	# Load existing settings on startup, or create defaults if none exist
	if load_settings() != OK:
		save_default_settings()

# Save a setting value under a specific section and key
func save_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	config.save(SETTINGS_FILE_PATH)

# Load a setting value, returning a fallback default if it doesn't exist
func load_setting(section: String, key: String, default_value: Variant) -> Variant:
	return config.get_value(section, key, default_value)

# Generate default configuration if the file is missing
func save_default_settings() -> void:
	config.set_value("Graphics", "fullscreen", false)
	config.set_value("Graphics", "resolution", Vector2i(1920, 1080))
	config.set_value("Audio", "master_volume", 0.8)
	config.set_value("Server", "watch_path", "")
	config.save(SETTINGS_FILE_PATH)

# Load the file from disk
func load_settings() -> Error:
	return config.load(SETTINGS_FILE_PATH)
