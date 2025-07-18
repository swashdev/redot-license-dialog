extends Window
# A dialog which displays a human-readable list of attribution notices.


# Source: https://github.com/swashdev/redot-license-dialog
# Version 4.0.2-pre.1.dev
# Tested on Godot Engine 4.0-stable and Redot Engine 4.3-stable
# Works, but needs to be updated, for Redot Engine 4.4-alpha.2


# An enum used by the `_read_copyright_file` function to determine what kind of
# line is being read at the time.
enum { _FILE, _COPYRIGHT, _COMMENT, _LICENSE }

@export_category("License Dialog")

# The name of the project which will be used.  If left blank, this value will be
# replaced with the name of the Redot Engine project.
@export_placeholder("(Optional)") var project_name: String = "" : \
		set = set_project_name, get = get_project_name

# The path to a file containing licensing information for the game.
@export_file var copyright_file =  "res://COPYRIGHT.txt" : \
		set = set_copyright_file, get = get_copyright_file


# These variables act as shortcuts to nodes within the LicenseDialog which we
# will be accessing frequently.  The reason we do this is that it's cheaper to
# get the node only once and store its reference in a variable than it is to
# get it every time we need to access it, which is helpful for project managers
# who want to optimize their code.
@onready var _info_label = $Container/Label
@onready var _component_list = $Container/ComponentList
@onready var _attribution_popup = $AttributionDialog
@onready var _attribution_textbox = $AttributionDialog/TextBox


# A dictionary which will store licensing information for the game, parsed from
# the game copyright file, and a corresponding TreeItem which will display this
# information.
var project_components: Dictionary = {}
var project_components_tree: TreeItem

# A dictionary which will store licensing information for the Redot Engine,
# parsed from data collected from the engine itself, and a corresponding
# TreeItem which will display this information.
var _redot_components: Dictionary = {}
var _redot_components_tree: TreeItem

# A dictionary which will store the full text of the licensing gathered from
# the above sources, and a TreeItem which will display this information.
var _licenses: Dictionary = {}
var _licenses_tree: TreeItem


func _ready():
	# Set the label text appropriately.
	var game_name = project_name
	if game_name == "":
		game_name = ProjectSettings.get_setting( "application/config/name" )

	# Create the root for the component list tree.
	var root = _component_list.create_item()

	# Populate the game components & licensing information from the copyright
	# file.
	if copyright_file != "":
		_read_copyright_file()

		if project_components.size() == 0:
			push_warning( "Couldn't read any copyright data for this game!" )
		else:
			# Create a subtree for the project components list.
			project_components_tree = _component_list.create_item( root )
			project_components_tree.set_text( 0, game_name )
			project_components_tree.set_selectable( 0, false )
			for component in project_components:
				var component_item = _component_list.create_item(
						project_components_tree )
				component_item.set_text( 0, component )

	# Create a subtree for the Redot Engine components list.
	_redot_components_tree = _component_list.create_item( root )
	_redot_components_tree.set_text( 0, "Redot Engine" )
	_redot_components_tree.set_selectable( 0, false )

	# Populate the Redot Engine components subtree.
	var components: Array = Engine.get_copyright_info()
	for component in components:
		var component_item = _component_list.create_item( _redot_components_tree
				)
		component_item.set_text( 0, component["name"] )
		_redot_components[component["name"]] = component["parts"]

	# The `_licenses` dictionary has already been populated by
	# `_read_copyright_file` but still needs to be populated with licenses from
	# the Redot Engine.
	var license_info: Dictionary = Engine.get_license_info()
	var keys = license_info.keys()
	var key_count: int = keys.size()
	for index in key_count:
		_licenses[keys[index]] = license_info[keys[index]]
	
	# Create a subtree for the licenses list.
	_licenses_tree = _component_list.create_item( root )
	_licenses_tree.set_text( 0, "Licenses" )
	_licenses_tree.set_selectable( 0, false )

	# Populate the Licenses subtree.
	keys = _licenses.keys()
	# Sort the keys so that the licenses will be displayed in alphabetical
	# order.
	keys.sort()
	key_count = keys.size()
	for index in key_count:
		var license_item = _component_list.create_item( _licenses_tree )
		license_item.set_text( 0, keys[index] )
		license_item.set_selectable( 0, true )


func set_project_name( new_name: String ):
	project_name = new_name


func get_project_name() -> String:
	return project_name


func set_copyright_file( file_path: String ):
	copyright_file = file_path


func get_copyright_file() -> String:
	return copyright_file


func set_label_text( text: String ):
	_info_label.text = text


func _on_ComponentList_item_selected():
	var selected: TreeItem = _component_list.get_selected()
	var parent: TreeItem = selected.get_parent()
	var comp_title: String = selected.get_text( 0 )
	var parent_title: String = parent.get_text( 0 )
	
	if parent_title == "Redot Engine":
		_display_game_component_info(comp_title, _redot_components[comp_title])
	elif parent_title == "Licenses":
		_display_license_info(comp_title)
	else:
		_display_game_component_info(comp_title, project_components[comp_title])


func _display_game_component_info(comp_title: String, component: Array):
	var text: String = comp_title

	for part in component:
		text += "\n\nFiles:"
		for file in part["files"]:
			text += "\n    %s" % file
		text += "\n"
		for copyright in part["copyright"]:
			text += "\nCopyright (c) %s" % copyright
		text += "\nLicense: %s" % part["license"]

	_popup_attribution_dialog(comp_title, text)


func _display_license_info(key: String):
	_popup_attribution_dialog( key, _licenses[key] )


func _popup_attribution_dialog( component: String, text: String ):
	_attribution_popup.set_title( component )
	_attribution_textbox.set_text( text )
	_attribution_textbox.scroll_vertical = 0
	_attribution_textbox.scroll_horizontal = 0
	_attribution_popup.popup_centered()



# Reads in the copyright file given by `copyright_file` and parses it
# to fill the `_game_copyright_info` and `_licenses` variables.
func _read_copyright_file():
	var f: FileAccess = FileAccess.open( copyright_file, FileAccess.READ )

	if !f:
		push_warning( "Couldn't find copyright file! Got error %d trying to open %s"
				% [FileAccess.get_open_error(), copyright_file] )
		return

	var file_paragraph: PackedStringArray = []
	var comment_paragraph: PackedStringArray = []
	var copyright_paragraph: PackedStringArray = []
	var license_paragraph: PackedStringArray = []

	var reading: int
	var line_count: int = 0
	var blank_line_count: int = 0
	var got_first_file: bool = false
	var reading_file_paragraph: bool = false

	# Iterate through the copyright file one line at a time.
	while not f.eof_reached():
		line_count += 1
		var line: String = f.get_line()
	
		# Decide how to parse each line depending on its prefix.
		if line.begins_with( "Files: " ):
			blank_line_count = 0
			got_first_file = true
			reading_file_paragraph = true
			reading = _FILE
			line = line.right( -7 )
			file_paragraph = [line.strip_edges()]
			#print_debug( "Line %d: Started reading files w/ %s"
			#		% [line_count, line.strip_edges()] )
		elif line.begins_with( "Comment: " ):
			blank_line_count = 0
			got_first_file = true
			reading_file_paragraph = true
			reading = _COMMENT
			line = line.right( -9 )
			comment_paragraph = [line.strip_edges()]
			#print_debug( "Line %d: Started reading comments w/ %s"
			#		% [line_count, line.strip_edges()] )
		elif line.begins_with( "Copyright: " ):
			blank_line_count = 0
			got_first_file = true
			reading_file_paragraph = true
			reading = _COPYRIGHT
			line = line.right( -11 )
			copyright_paragraph = [line.strip_edges()]
			#print_debug( "Line %d: Started reading copyrights w/ %s"
			#		% [line_count, line.strip_edges()] )
		elif line.begins_with( "License: " ):
			blank_line_count = 0
			got_first_file = true
			reading_file_paragraph = true
			reading = _LICENSE
			line = line.right( -9 )
			license_paragraph = [line.strip_edges()]
			#print_debug( "Line %d: Started reading licenses w/ %s"
			#		% [line_count, line.strip_edges()] )
		elif line.begins_with( " " ):
			if not reading_file_paragraph:
				push_warning( "Inappropriate indentation at line %d in %s"
						% [line_count, copyright_file] )
			else:
				blank_line_count = 0
				line = line.strip_edges()
				match reading:
					_FILE:
						file_paragraph.append( line )
						#print_debug( "Line %d: Reading file %s"
						#		% [line_count, line ] )
					_COMMENT:
						comment_paragraph.append( line )
						#print_debug( "Line %d: Reading comment %s"
						#		% [line_count, line ] )
					_COPYRIGHT:
						copyright_paragraph.append( line )
						#print_debug( "Line %d: Reading copyright %s"
						#		% [line_count, line ] )
					_LICENSE:
						license_paragraph.append( line )
						#print_debug( "Line %d: Reading license %s"
						#		% [line_count, line ] )
					_:
						push_error( "Bad code detected! Invalid value %d for `reading`"
								% reading )
		elif line.strip_edges() == "":
			# Only count blank lines after we start reading files.
			if got_first_file:
				blank_line_count += 1
			# Three blank lines separate the file paragraphs from the license
			# paragraphs, so if we count three blank lines we should break
			# here.
			if blank_line_count == 3:
				break
			# If there's only one blank line, assume we are terminating reading
			# of a file paragraph.
			elif blank_line_count == 1:
				if file_paragraph.size() > 0 \
				and comment_paragraph.size() > 0 \
				and copyright_paragraph.size() > 0 \
				and license_paragraph.size() > 0:
					reading_file_paragraph = false
					var full_paragraph: Dictionary = {}
	
					full_paragraph["files"] = []
					for file in file_paragraph:
						full_paragraph["files"].append( file )
	
					full_paragraph["copyright"] = []
					for copyright in copyright_paragraph:
						full_paragraph["copyright"].append( copyright )
	
					var license_line_count: int = 0
					var full_license = ""
					for license_line in license_paragraph:
						if license_line_count > 0:
							full_license += "\n    "
						full_license += license_line
						license_line_count += 1
					full_paragraph["license"] = full_license
	
					for comment in comment_paragraph:
						if not project_components.has( comment ):
							project_components[comment] = [full_paragraph]
						else:
							push_warning( "Duplicate component %s found at line %d in %s. Consider consolidating."
									% [comment, line_count, copyright_file] )
							project_components[comment].append( full_paragraph )
						#print_debug( "Line %d: Finished reading file paragraph for %s"
						#		% [line_count, comment] )
					
					file_paragraph = []
					comment_paragraph = []
					copyright_paragraph = []
					license_paragraph = []
				else:
					push_warning( "Malformed file paragraph at line %d in %s"
							% [line_count, copyright_file] )
					push_warning( "NOTE: See this link for file format: %s"
							% "https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/" )

	# Having broken out of the loop, check if we aborted in the middle of a
	# file paragraph.
	if reading_file_paragraph:
		push_warning( "Got to end of file paragraphs on line %d in %s while still reading file paragraph for %s!"
				% [line_count, copyright_file, comment_paragraph[0]] )
		push_warning( "NOTE: Three blank lines terminate reading file paragraphs!" )

	# Having broken out of the loop, check if we've reached EOF already; if we
	# have, the copyright file does not contain any licenses.
	if f.eof_reached():
		push_warning( "Reached EOF in %s before reading licenses!"
				% copyright_file )
		return

	var short_license: String
	var license: String = ""
	var reading_license: bool = false

	# Read the licenses:
	while not f.eof_reached():
		line_count += 1
		var line: String = f.get_line()

		if line.begins_with( "License: " ):
			blank_line_count = 0
			if reading_license:
				push_warning( "Malformed license at line %d in %s!  Reached next license before license finished!"
						% [line_count, copyright_file] )
			else:
				line = line.right( -9 )
				short_license = line.strip_edges()
				license = ""
				reading_license = true
				#print_debug( "Line %d: Started reading license %s"
				#		% [line_count, short_license] )
		elif line.begins_with( " " ):
			blank_line_count = 0
			if not reading_license:
				push_warning( "Inappropriate indentation at line %d in %s"
						% [line_count, copyright_file] )
			else:
				line = line.strip_edges()
				# If the line only contains a dot, just add a newline.
				if line != ".":
					license += line
				license += "\n"
		elif line.strip_edges() == "":
			#print_debug( "Found blank line at %d" % line_count )
			blank_line_count += 1
			if reading_license and blank_line_count == 1:
				#print_debug( "Finished reading license %s" % short_license )
				_licenses[short_license] = license
				reading_license = false

	# Having broken out of the loop, check if we aborted in the middle of
	# reading a license.
	if reading_license:
		push_warning( "Reached EOF at line %d in %s in the middle of reading license for %s!"
				% [line_count, copyright_file, short_license] )
