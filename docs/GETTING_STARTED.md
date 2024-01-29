# Getting Started

This file will give you basic setup instructions so you can use the Godot
Unofficial License Dialog in your game or other project.

It is recommended that you read this document in a Markdown reader or on the
project's [GitHub](https://github.com/swashdev/godot-license-dialog), as
it contains embedded images and hyperlinks which will provide you with visual
aids and additional information.

## Before Beginning

This documentation assumes you have a basic grasp on how to use the Godot Engine
editor.  If you don't know how to use the Godot Engine editor, I recommend you
read the [Godot Engine documentation](https://docs.godotengine.org/en/stable/).

## Basic Setup

<img style = "float:right" src = "screenshots/getting_started_01.png" title = "The FileSystem dock in a Godot Engine project, showing the file `license_dialog.gd` selected."/>

If you haven't already, start by downloading the project.  The only files you
really need are `license_dialog.gd` (the script file) and `license_dialog.tscn`
(the scene file for the `LicenseDialog` node) from the root folder.  Because
the Godot Unofficial License Dialog is public domain software, it is not
necessary to download `COPYRIGHT.txt` or the `UNLICENSE` file, and the rest of
the files in the root folder are either documentation or part of the sample
project.

Drop the files into your Godot Engine project folder.  Although you can place
them in any folder you wish, I recommend placing them in the same folder to
begin with.  If you want them to be in separate folders, move them into their
appropriate directories from within the Godot Engine editor by right-clicking
them in the FileSystem dock and clicking "Move To."  If you do it this way, the
Godot Engine will automatically fix references to the script file within the
`LicenseDialog` scene for you.

If you want to, you can now rename the script and scene files by
right-clicking them in the FileSystem dock and clicking "Rename."  This will
also automatically update references for you.  For the purposes of this
documentation, we will assume that the files are still named
`license_dialog.gd` and `license_dialog.tscn`.

### Setting Up Project Information

After you've got the scene and script files where you want them in your project
folders, it's time to give the `LicenseDialog` node any information it needs
about your project.

Open up the `license_dialog.tscn` file in the Godot Engine editor and look in
the Inspector dock.  By default, this dock will be in the upper-right in the
"Inspector" tab.  You'll notice that it says `LicenseDialog` at the top, the
default name for the root node of this scene.  You can rename it if you wish,
but for our purposes we'll assume you let it keep its default name.

<img style = "margin: 0 auto" src = "screenshots/getting_started_02.png" title = "The Inspector dock in a Godot Engine project, showing some fields the user can modify to customize a `LicenseDialog` node." />

Under "Script Variables" you'll see some variables which you can modify by
typing some values into some text boxes.

#### Project Name

This is the name of your project, which will be used to label buttons in the
`LicenseDialog` which show attribution information for your project.

If you leave this field blank, the `LicenseDialog` will use the name which is
stored in your project file, so you don't need to do anything here unless you
want the name of your project to be displayed differently in the list of
attribution notices than it would be normally.

#### Copyright File

This is a path which refers to a file storing copyright information for your
project.  The `LicenseDialog` will look for a file stored in this location which
contains all of the information it needs to display attribution notices and
license texts for your project (*not* the Godot Engine).

The file in question needs to be formatted in a specific way in order for the
`LicenseDialog` to read it properly.  More detailed information will be given in
future versions of this documentation, but for now you can use [the sample
COPYRIGHT.txt] included with the Godot Unofficial License Dialog or [the Godot
Engine's COPYRIGHT.txt] as a reference, or refer to the format specification
[here][Debian copyright file format].

[the sample COPYRIGHT.txt]: ../COPYRIGHT.txt
[the Godot Engine's COPYRIGHT.txt]: https://github.com/godotengine/godot/blob/master/COPYRIGHT.txt
[Debian copyright file format]: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/

**Note:**
Strictly speaking, you don't _need_ to include a copyright file with your
project.  However, I recommend that you do so, especially if you are using
third-party assets in your project, as you can take advantage of the Godot
Unofficial License Dialog to display licensing information for your project,
including third-party assets, as well as the Godot Engine.  
If you choose not to include a copyright file, leave the Copyright File variable
blank.  If you specify a file which does not exist, your project will spit out a
warning when it is run letting you know that the `LicenseDialog` could not find
it.

**Helpful Tip:**
If you choose not to include a copyright file, you can slim down your scripting
a lot by deleting the `_read_copyright_file` function and any references to it
from the `license_dialog.gd` file, as this is the longest function in that
script.


### Implementing the Popup

The `LicenseDialog` node is a node of type `WindowDialog`, a class that comes
packaged with the Godot Engine which is used to display popup windows.

To add the `LicenseDialog` to your project, add it to another node, perhaps
containing the main menu.  After this, you can show it to the user by simply
adding a button which causes the window to pop up.

Here's an example function from a main menu which is linked to the "pressed"
signal from a `Button` node:

```gdscript
# The "Legal Stuff" button has been pressed.  This will open a dialog box
# containing licensing information.
func _on_LegalStuffButton_pressed():
	$LicenseDialog.popup_centered()
```

You can find more information about the `WindowDialog` class by visiting its
page in [the Godot Engine documentation][WindowDialog].

[WindowDialog]: https://docs.godotengine.org/en/stable/classes/class_windowdialog.html

**Helpful Tip**:
You can change what type of node the `LicenseDialog` is by right-clicking it and
selecting "Change Type."  Note that if you do this you will also have to change
what class the script in `license_dialog.gd` will inherit from; otherwise it
will not work.
