## Godot File Access Web
Addon for uploading files in HTML5 on Godot 4.

## Example
<p align="center">
  <img width="600" src="docs/example.gif" alt="Example">
</p>

## Usage
Create `FileAccessWeb` object and open input dialog window:

```gdscript
var file_access_web := FileAccessWeb.new()
file_access_web.open()
```

You can pass accept files types as arguments to the open method:

```gdscript
file_acces_web.open(".jpg")
```