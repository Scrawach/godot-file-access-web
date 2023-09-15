class_name FileAccessWeb
extends RefCounted

signal loaded(file_type: String, raw_data: PackedByteArray)
signal progress(current_bytes: int, total_bytes: int)

var _file_uploading: JavaScriptObject

var _on_file_loaded_callback: JavaScriptObject
var _on_file_progress_callback: JavaScriptObject

func _init() -> void:
	if _is_not_web():
		_notify_error()
		return
	
	JavaScriptBridge.eval(js_source_code, true)
	_file_uploading = JavaScriptBridge.get_interface("godotFileAccessWeb")
	
	_on_file_loaded_callback = JavaScriptBridge.create_callback(_on_file_loaded)
	_on_file_progress_callback = JavaScriptBridge.create_callback(_on_file_progress)
	
	_file_uploading.setLoadedCallback(_on_file_loaded_callback)
	_file_uploading.setProgressCallback(_on_file_progress_callback)

func open(accept_files: String = "*") -> void:
	if _is_not_web():
		_notify_error()
		return
	
	_file_uploading.setAcceptFiles(accept_files)
	_file_uploading.open()

func _is_not_web() -> bool:
	return OS.get_name() != "Web"

func _notify_error() -> void:
	push_error("File Access Web worked only for HTML5 platform export!")

func _on_file_loaded(args: Array) -> void:
	var splitted_args: PackedStringArray = args[0].split(",", true, 1)
	var file_type: String = splitted_args[0].get_slice(":", 1). get_slice(";", 0)
	var base64_data: String = splitted_args[1]
	var raw_data: PackedByteArray = Marshalls.base64_to_raw(base64_data)
	loaded.emit(file_type, raw_data)

func _on_file_progress(args: Array) -> void:
	var current_bytes: int = args[0]
	var total_bytes: int = args[1]
	progress.emit(current_bytes, total_bytes)

const js_source_code = """
function godotFileAccessWebStart() {
	var loadedCallback;
	var progressCallback;

	var input = document.createElement("input");
	input.setAttribute("type", "file")

	var interface = {
		setLoadedCallback: (loaded) => loadedCallback = loaded,
		setProgressCallback: (progress) => progressCallback = progress,

		setAcceptFiles: (files) => input.setAttribute("accept", files),
		open: () => input.click()
	}

	input.onchange = (event) => {
		if (event.target.files.length === 0) {
			return;
		}

		var file = event.target.files[0];
		var reader = new FileReader();
		reader.readAsDataURL(file)

		reader.onloadend = (readerEvent) => {
			if (readerEvent.target.readyState === FileReader.DONE) {
				loadedCallback(readerEvent.target.result);
			}
		}
		
		reader.onprogress = (progressEvent) => {
			if (progressEvent.lengthComputable)
				progressCallback(progressEvent.loaded, progressEvent.total);
		}
	}

	return interface;
}

var godotFileAccessWeb = godotFileAccessWebStart();
"""
