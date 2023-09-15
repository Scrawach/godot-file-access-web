class_name FileAccessWebImageExample
extends Control

@onready var upload_button: Button = %"Upload Button" as Button
@onready var canvas: TextureRect = %Canvas as TextureRect

var file_access_web: FileAccessWeb = FileAccessWeb.new()

func _ready() -> void:
	upload_button.pressed.connect(_on_upload_pressed)
	file_access_web.loaded.connect(_on_file_loaded)

func _on_upload_pressed() -> void:
	file_access_web.open("image/png")

func _on_file_loaded(type: String, data: PackedByteArray) -> void:
	raw_draw(type, data)

func raw_draw(type: String, data: PackedByteArray) -> void:
	var image := Image.new()
	var error: int = _load_image(image, type, data)
	
	if not error:
		canvas.texture = _create_texture_from(image)
	else:
		push_error("Error %s id" % error)

func _load_image(image: Image, type: String, data: PackedByteArray) -> int:
	match type:
		"image/png":
			return image.load_png_from_buffer(data)
		"image/jpeg":
			return image.load_jpg_from_buffer(data)
		"image/webp":
			return image.load_webp_from_buffer(data)
		_:
			return Error.FAILED

func _create_texture_from(image: Image) -> ImageTexture:
	var texture = ImageTexture.new()
	texture.set_image(image)
	return texture
