extends Node2D
# A test node for the license dialog.


func _ready():
	$LicenseDialog.popup()


func _on_license_dialog_close_requested():
	get_tree().quit()
