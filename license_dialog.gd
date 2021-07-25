tool
extends WindowDialog
# A dialog which displays a human-readable list of attribution notices.


# Source: https://git.sr.ht/~swashberry/godot-license-dialog
# Version 0.0.0


# An enum used by the `_read_copyright_file` function to determine what kind of
# line is being read at the time.
enum { _FILE, _COPYRIGHT, _COMMENT, _LICENSE }

# The name of the project which will be used.  If left blank, this value will be
# replaced with the name of the Godot Engine project.
export(String) onready var project_name = "" setget set_project_name, \
		get_project_name

# The path to a file containing licensing information for the game.
export(String, FILE, "*.txt") onready var copyright_file = \
		"res://COPYRIGHT.txt" setget set_copyright_file, get_copyright_file

# The text for the label which appears above the components list.  The text
# "GAME_NAME" will be replaced with the contents of `project_name`.
export(String, MULTILINE) onready var label_text = "Clicking one of the " + \
		"buttons below will display licensing information for individual " + \
		"components of GAME_NAME and the engine it is built on, the Godot " + \
		"Engine." setget set_label_text, get_label_text


# These variables act as shortcuts to nodes within the LicenseDialog which we
# will be accessing frequently.  The reason we do this is that it's cheaper to
# get the node only once and store its reference in a variable than it is to
# get it every time we need to access it, which is helpful for project managers
# who want to optimize their code.
onready var _info_label = $Label
onready var _component_list = $ComponentList
onready var _attribution_popup = $AttributionDialog
onready var _attribution_textbox = $AttributionDialog/TextBox


# A dictionary which will store licensing information for the game, parsed from
# the game copyright file, and a corresponding TreeItem which will display this
# information.
var project_components: Dictionary = {}
var project_components_tree: TreeItem

# A dictionary which will store licensing information for the Godot Engine,
# parsed from data collected from the engine itself, and a corresponding
# TreeItem which will display this information.
var _godot_components: Dictionary = {}
var _godot_components_tree: TreeItem

# A dictionary which will store the full text of the licensing gathered from
# the above sources, and a TreeItem which will display this information.
var _licenses: Dictionary = {}
var _licenses_tree: TreeItem


func _ready():
	# Set the label text appropriately.
	var game_name = project_name
	if game_name == "":
		game_name = ProjectSettings.get_setting( "application/config/name" )

	var parsed_text = label_text.replace( "GAME_NAME", game_name )
	_info_label.set_text( parsed_text )

	# Create the root for the component list tree.
	var root = _component_list.create_item()

	# Populate the game components & licensing information from the copyright
	# file.
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

	# Create a subtree for the Godot Engine components list.
	_godot_components_tree = _component_list.create_item( root )
	_godot_components_tree.set_text( 0, "Godot Engine" )
	_godot_components_tree.set_selectable( 0, false )

	# Populate the Godot Engine components subtree.
	var components: Array = Engine.get_copyright_info()
	for component in components:
		var component_item = _component_list.create_item( _godot_components_tree
				)
		component_item.set_text( 0, component["name"] )
		_godot_components[component["name"]] = component["parts"]

	# The `_licenses` dictionary has already been populated by
	# `_read_copyright_file` but still needs to be populated with licenses from
	# the Godot Engine.
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
	label_text = text


func get_label_text( replace_name: bool = false ) -> String:
	if replace_name:
		return label_text
	else:
		return label_text.replace( "GAME_NAME", project_name )


func _on_ComponentList_item_selected():
	var selected: TreeItem = _component_list.get_selected()
	var parent: TreeItem = selected.get_parent()
	var title: String = selected.get_text( 0 )
	var parent_title: String = parent.get_text( 0 )
	
	if parent_title == "Godot Engine":
		_display_game_component_info( title, _godot_components[title] )
	elif parent_title == "Licenses":
		_display_license_info( title )
	else:
		_display_game_component_info( title, project_components[title] )


func _display_game_component_info( var title: String, component: Array ):
	var text: String = title

	for part in component:
		text += "\n\nFiles:"
		for file in part["files"]:
			text += "\n    %s" % file
		text += "\n"
		for copyright in part["copyright"]:
			text += "\nCopyright (c) %s" % copyright
		text += "\nLicense: %s" % part["license"]

	_popup_attribution_dialog( title, text )


func _display_license_info( var key: String ):
	_popup_attribution_dialog( key, _licenses[key] )


func _popup_attribution_dialog( title: String, text: String ):
	_attribution_popup.set_title( title )
	_attribution_textbox.set_text( text )
	_attribution_textbox.scroll_vertical = 0
	_attribution_textbox.scroll_horizontal = 0
	_attribution_popup.popup_centered()



# Reads in the copyright file given by `copyright_file` and parses it
# to fill the `_game_copyright_info` and `_licenses` variables.
func _read_copyright_file():
	var f: File = File.new()
	var err = f.open( copyright_file, File.READ )

	if err != OK:
		push_warning( "Couldn't find copyright file! Got error %d trying to open %s"
				% [err, copyright_file] )
		return

	var file_paragraph: PoolStringArray = []
	var comment_paragraph: PoolStringArray = []
	var copyright_paragraph: PoolStringArray = []
	var license_paragraph: PoolStringArray = []

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
			line.erase( 0, 7 )
			file_paragraph = [line.strip_edges()]
			#print_debug( "Line %d: Started reading files w/ %s"
			#		% [line_count, line.strip_edges()] )
		elif line.begins_with( "Comment: " ):
			blank_line_count = 0
			got_first_file = true
			reading_file_paragraph = true
			reading = _COMMENT
			line.erase( 0, 9 )
			comment_paragraph = [line.strip_edges()]
			#print_debug( "Line %d: Started reading comments w/ %s"
			#		% [line_count, line.strip_edges()] )
		elif line.begins_with( "Copyright: " ):
			blank_line_count = 0
			got_first_file = true
			reading_file_paragraph = true
			reading = _COPYRIGHT
			line.erase( 0, 11 )
			copyright_paragraph = [line.strip_edges()]
			#print_debug( "Line %d: Started reading copyrights w/ %s"
			#		% [line_count, line.strip_edges()] )
		elif line.begins_with( "License: " ):
			blank_line_count = 0
			got_first_file = true
			reading_file_paragraph = true
			reading = _LICENSE
			line.erase( 0, 9 )
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
					var license = ""
					for license_line in license_paragraph:
						if license_line_count > 0:
							license += "\n    "
						license += license_line
						license_line_count += 1
					full_paragraph["license"] = license
	
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
				line.erase( 0, 9 )
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
