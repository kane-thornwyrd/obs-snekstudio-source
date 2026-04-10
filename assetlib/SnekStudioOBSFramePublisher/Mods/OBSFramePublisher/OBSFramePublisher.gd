extends Mod_Base
class_name Mod_OBSFramePublisher

const HEADER_SIZE: int = 128
const FRAME_PROTOCOL_VERSION: int = 1
const PIXEL_FORMAT_RGBA8: int = 2
const FRAME_FLAG_READY: int = 1
const FRAME_MAGIC: Array[int] = [0x53, 0x4e, 0x45, 0x4b, 0x46, 0x42, 0x31, 0x00]
const STATUS_UPDATE_INTERVAL_FRAMES: int = 60
const DEFAULT_OUTPUT_WIDTH: int = 1280
const DEFAULT_OUTPUT_HEIGHT: int = 720
const MIN_OUTPUT_DIMENSION: int = 64
const MAX_OUTPUT_DIMENSION: int = 8192
const OUTPUT_SETTINGS_GROUP: String = "output"
const PERFORMANCE_SETTINGS_GROUP: String = "performance"
const DEFAULT_TARGET_PUBLISH_FPS: int = 30

## Enables or disables frame publication to the OBS shared framebuffer file.
@export var publisher_enabled: bool = true
## Output path for the shared framebuffer consumed by the OBS plugin.
@export var frame_path: String = ""
## Resizes the captured viewport to a stable output resolution before publishing.
@export var fixed_resolution_enabled: bool = true
## Published frame width when fixed output resolution is enabled.
@export var output_width: int = DEFAULT_OUTPUT_WIDTH
## Published frame height when fixed output resolution is enabled.
@export var output_height: int = DEFAULT_OUTPUT_HEIGHT
## Maximum frame rate to publish to OBS. Set to 0 to publish every frame.
@export var target_publish_fps: int = DEFAULT_TARGET_PUBLISH_FPS

var _output_file: FileAccess = null
var _resolved_frame_path: String = ""
var _runtime_active: bool = false
var _frame_sequence: int = 0
var _current_width: int = 0
var _current_height: int = 0
var _current_stride_bytes: int = 0
var _current_payload_bytes: int = 0
var _current_total_bytes: int = 0
var _last_error_status: String = ""
var _next_publish_time_usec: int = 0


func _ready() -> void:
	set_process(false)

	if frame_path.is_empty():
		frame_path = _default_frame_path()

	add_setting_group(OUTPUT_SETTINGS_GROUP, "Output")
	add_setting_group(PERFORMANCE_SETTINGS_GROUP, "Performance")
	add_tracked_setting("publisher_enabled", "Publisher enabled", {}, OUTPUT_SETTINGS_GROUP)
	add_tracked_setting("frame_path", "Frame output path", {"is_fileaccess": true}, OUTPUT_SETTINGS_GROUP)
	add_tracked_setting("fixed_resolution_enabled", "Use fixed output resolution", {}, OUTPUT_SETTINGS_GROUP)
	add_tracked_setting(
		"output_width",
		"Output width",
		{"min": MIN_OUTPUT_DIMENSION, "max": MAX_OUTPUT_DIMENSION},
		OUTPUT_SETTINGS_GROUP,
	)
	add_tracked_setting(
		"output_height",
		"Output height",
		{"min": MIN_OUTPUT_DIMENSION, "max": MAX_OUTPUT_DIMENSION},
		OUTPUT_SETTINGS_GROUP,
	)
	add_tracked_setting(
		"target_publish_fps",
		"Target publish FPS",
		{"min": 0, "max": 240},
		PERFORMANCE_SETTINGS_GROUP,
	)

	set_status(_get_idle_status())
	update_settings_ui()


## Initializes the publisher state when the mod becomes active in the scene.
func scene_init() -> void:
	_runtime_active = true
	set_process(true)
	_reset_runtime_state()
	set_status(_get_idle_status())


## Stops publishing and invalidates the shared framebuffer on shutdown.
func scene_shutdown() -> void:
	_runtime_active = false
	set_process(false)
	_invalidate_output_file()
	_close_output_file()
	set_status("Publisher stopped")


## Reinitializes runtime publisher state after settings are reloaded.
func load_after(_settings_old : Dictionary, _settings_new : Dictionary) -> void:
	_reset_runtime_state()
	set_status(_get_idle_status())


## Reports obvious configuration problems in the publisher settings.
func check_configuration() -> PackedStringArray:
	var errors : PackedStringArray = PackedStringArray()

	if _resolve_frame_path().is_empty():
		errors.append("No frame output path is configured.")

	if fixed_resolution_enabled:
		if output_width < MIN_OUTPUT_DIMENSION or output_width > MAX_OUTPUT_DIMENSION:
			errors.append("Output width is outside the supported range.")
		if output_height < MIN_OUTPUT_DIMENSION or output_height > MAX_OUTPUT_DIMENSION:
			errors.append("Output height is outside the supported range.")

	if target_publish_fps < 0 or target_publish_fps > 240:
		errors.append("Target publish FPS is outside the supported range.")

	return errors


func _process(_delta : float) -> void:
	if not _runtime_active or not publisher_enabled:
		return

	if _should_skip_publish(Time.get_ticks_usec()):
		return

	var output_image : Image = _capture_frame_image()
	if output_image == null:
		return

	output_image = _prepare_output_image(output_image)

	var width : int = output_image.get_width()
	var height : int = output_image.get_height()
	var rgba_data : PackedByteArray = output_image.get_data()
	if rgba_data.size() != width * height * 4:
		_set_error_status("Unexpected viewport pixel buffer size")
		return

	if not _ensure_output_file(width, height):
		return

	_write_frame(rgba_data)
	_maybe_update_running_status()


func _default_frame_path() -> String:
	var runtime_dir : String = OS.get_environment("XDG_RUNTIME_DIR")
	var base_dir : String = runtime_dir if not runtime_dir.is_empty() else "/tmp"
	return base_dir.path_join("snekstudio-source").path_join("demo-framebuffer.bin")


func _get_idle_status() -> String:
	if not publisher_enabled:
		return "Publisher disabled"
	return "Ready to publish %s at %s to %s" % [
		_get_output_mode_description(),
		_get_publish_rate_description(),
		_resolve_frame_path(),
	]


func _capture_frame_image() -> Image:
	var viewport_texture : ViewportTexture = get_viewport().get_texture()
	if viewport_texture == null:
		_set_error_status("No viewport texture available")
		return null

	var image : Image = viewport_texture.get_image()
	if image == null:
		_set_error_status("Viewport capture failed")
		return null

	if image.get_width() <= 0 or image.get_height() <= 0:
		_set_error_status("Viewport size is zero")
		return null

	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)

	return image


func _prepare_output_image(image : Image) -> Image:
	var target_size : Vector2i = _get_target_output_size(image.get_width(), image.get_height())
	if image.get_width() != target_size.x or image.get_height() != target_size.y:
		# Resizing here costs extra CPU time, but it makes the OBS source size stable.
		image.resize(target_size.x, target_size.y, Image.INTERPOLATE_BILINEAR)
	return image


func _get_target_output_size(captured_width : int, captured_height : int) -> Vector2i:
	if not fixed_resolution_enabled:
		return Vector2i(captured_width, captured_height)

	return Vector2i(
		_clamp_output_dimension(output_width),
		_clamp_output_dimension(output_height),
	)


func _clamp_output_dimension(value : int) -> int:
	if value < MIN_OUTPUT_DIMENSION:
		return MIN_OUTPUT_DIMENSION
	if value > MAX_OUTPUT_DIMENSION:
		return MAX_OUTPUT_DIMENSION
	return value


func _get_output_mode_description() -> String:
	if fixed_resolution_enabled:
		return "fixed %dx%d output" % [
			_clamp_output_dimension(output_width),
			_clamp_output_dimension(output_height),
		]

	return "dynamic viewport output"


func _get_publish_rate_description() -> String:
	if target_publish_fps <= 0:
		return "full frame rate"

	return "%d FPS" % target_publish_fps


func _should_skip_publish(now_usec : int) -> bool:
	if target_publish_fps <= 0:
		return false

	if now_usec < _next_publish_time_usec:
		return true

	var publish_interval_usec : int = int(1000000.0 / float(target_publish_fps))
	if publish_interval_usec <= 0:
		_next_publish_time_usec = now_usec
	else:
		_next_publish_time_usec = now_usec + publish_interval_usec

	return false


func _resolve_frame_path() -> String:
	var configured_path : String = frame_path.strip_edges()
	if configured_path.is_empty():
		return ""
	if configured_path.begins_with("res://") or configured_path.begins_with("user://"):
		return ProjectSettings.globalize_path(configured_path)
	return configured_path


func _set_error_status(message : String) -> void:
	if _last_error_status == message:
		return

	_last_error_status = message
	set_status(message)
	print_log(message)


func _clear_error_status() -> void:
	_last_error_status = ""


func _reset_runtime_state() -> void:
	_invalidate_output_file()
	_close_output_file()
	_frame_sequence = 0
	_next_publish_time_usec = 0
	_current_width = 0
	_current_height = 0
	_current_stride_bytes = 0
	_current_payload_bytes = 0
	_current_total_bytes = 0
	_clear_error_status()


func _close_output_file() -> void:
	if _output_file != null:
		_output_file.close()
	_output_file = null
	_resolved_frame_path = ""


func _flush_output_file() -> void:
	if _output_file != null:
		_output_file.flush()


func _invalidate_output_file() -> void:
	if _output_file == null or _current_total_bytes < HEADER_SIZE:
		return

	# Mark the header as not ready so OBS treats the last published frame as stale.
	var inactive_header : PackedByteArray = _build_header(
		_frame_sequence * 2,
		_frame_sequence,
		Time.get_ticks_usec() * 1000,
		0,
	)
	_output_file.seek(0)
	_output_file.store_buffer(inactive_header)
	_flush_output_file()


func _ensure_output_directory(output_path : String) -> bool:
	var output_dir : String = output_path.get_base_dir()
	if output_dir.is_empty() or DirAccess.dir_exists_absolute(output_dir):
		return true

	var err : int = DirAccess.make_dir_recursive_absolute(output_dir)
	if err != OK:
		_set_error_status("Failed to create frame directory: %s" % error_string(err))
		return false

	return true


func _open_output_file(resolved_path : String) -> bool:
	_close_output_file()

	if not _ensure_output_directory(resolved_path):
		return false

	var file : FileAccess = FileAccess.open(resolved_path, FileAccess.READ_WRITE)
	if file == null:
		file = FileAccess.open(resolved_path, FileAccess.WRITE_READ)

	if file == null:
		_set_error_status("Failed to open frame file: %s" % error_string(FileAccess.get_open_error()))
		return false

	_output_file = file
	_resolved_frame_path = resolved_path
	print_log(["Opened frame stream at ", resolved_path])
	return true


func _ensure_output_file(width : int, height : int) -> bool:
	var resolved_path : String = _resolve_frame_path()
	if resolved_path.is_empty():
		_set_error_status("Frame output path is empty")
		return false

	if _output_file == null or _resolved_frame_path != resolved_path:
		if not _open_output_file(resolved_path):
			return false

	var stride_bytes : int = width * 4
	var payload_bytes : int = stride_bytes * height
	var total_bytes : int = HEADER_SIZE + payload_bytes

	if _current_total_bytes != total_bytes:
		var resize_error : int = _output_file.resize(total_bytes)
		if resize_error != OK:
			_set_error_status("Failed to resize frame file: %s" % error_string(resize_error))
			_close_output_file()
			return false

		print_log([
			"Configured frame buffer at ",
			resolved_path,
			" for ",
			str(width),
			"x",
			str(height),
		])

	_current_width = width
	_current_height = height
	_current_stride_bytes = stride_bytes
	_current_payload_bytes = payload_bytes
	_current_total_bytes = total_bytes
	_flush_output_file()
	return true


func _write_frame(rgba_data : PackedByteArray) -> void:
	var next_frame_sequence : int = _frame_sequence + 1
	var timestamp_ns : int = Time.get_ticks_usec() * 1000

	# Toggle the ready flag around the payload write so OBS can detect in-flight updates.
	_output_file.seek(0)
	_output_file.store_buffer(_build_header(next_frame_sequence * 2 - 1, next_frame_sequence, timestamp_ns, 0))
	_output_file.seek(HEADER_SIZE)
	_output_file.store_buffer(rgba_data)
	_output_file.seek(0)
	_output_file.store_buffer(_build_header(next_frame_sequence * 2, next_frame_sequence, timestamp_ns, FRAME_FLAG_READY))
	_flush_output_file()

	_frame_sequence = next_frame_sequence
	_clear_error_status()


func _maybe_update_running_status() -> void:
	if _frame_sequence == 1 or _frame_sequence % STATUS_UPDATE_INTERVAL_FRAMES == 0:
		set_status(
			"Publishing %dx%d (%s) to %s (frame %d)" % [
				_current_width,
				_current_height,
				"%s, %s" % [
					"fixed" if fixed_resolution_enabled else "dynamic",
					_get_publish_rate_description(),
				],
				_resolved_frame_path,
				_frame_sequence,
			]
		)


func _build_header(write_sequence : int, frame_sequence : int, timestamp_ns : int, flags : int) -> PackedByteArray:
	var header : PackedByteArray = PackedByteArray()
	header.resize(HEADER_SIZE)

	for byte_index : int in range(FRAME_MAGIC.size()):
		header[byte_index] = FRAME_MAGIC[byte_index]

	_write_u32_le(header, 8, FRAME_PROTOCOL_VERSION)
	_write_u32_le(header, 12, HEADER_SIZE)
	_write_u32_le(header, 16, _current_width)
	_write_u32_le(header, 20, _current_height)
	_write_u32_le(header, 24, _current_stride_bytes)
	_write_u32_le(header, 28, PIXEL_FORMAT_RGBA8)
	_write_u32_le(header, 32, HEADER_SIZE)
	_write_u32_le(header, 36, _current_payload_bytes)
	_write_u64_le(header, 40, write_sequence)
	_write_u64_le(header, 48, frame_sequence)
	_write_u64_le(header, 56, timestamp_ns)
	_write_u32_le(header, 64, flags)
	_write_u32_le(header, 68, 0)

	return header


func _write_u32_le(buffer : PackedByteArray, offset : int, value : int) -> void:
	buffer[offset + 0] = value & 0xFF
	buffer[offset + 1] = (value >> 8) & 0xFF
	buffer[offset + 2] = (value >> 16) & 0xFF
	buffer[offset + 3] = (value >> 24) & 0xFF


func _write_u64_le(buffer : PackedByteArray, offset : int, value : int) -> void:
	buffer[offset + 0] = value & 0xFF
	buffer[offset + 1] = (value >> 8) & 0xFF
	buffer[offset + 2] = (value >> 16) & 0xFF
	buffer[offset + 3] = (value >> 24) & 0xFF
	buffer[offset + 4] = (value >> 32) & 0xFF
	buffer[offset + 5] = (value >> 40) & 0xFF
	buffer[offset + 6] = (value >> 48) & 0xFF
	buffer[offset + 7] = (value >> 56) & 0xFF