extends Node2D
# A test node for the license dialog.


func _ready():
	$LicenseDialog.popup()


func _on_LicenseDialog_popup_hide():
	get_tree().quit()
