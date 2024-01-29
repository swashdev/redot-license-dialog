Godot Unofficial License Dialog
===============================

If, like me, you want to support open-source game engines like [Godot], but you
worry about displaying proper licensing information for any project you do
which includes third-party software, then this project is for you.  Software
licenses can be a real pain in the neck sometimes, and it would be a lot better
if it was easier to remain compliant with them.

The Godot Engine uses a lot of third-party modules and components which all use
slightly different software licenses and affect what licensing information you
need to include with any games or other projects you make.  If you build Godot
from source, this licensing information may change, as different platforms and
different configurations of the engine use different modules, and that means
your attribution notices need to adapt as well.

The Godot Unofficial License Dialog, or GUiLD for short, is a simple node for
Godot Engine projects which parses and displays licensing information for your
project in a convenient and human-readable format which your users can access
in-game.

How It Works
------------

[The Godot Engine][Godot] actually has functions built-in which can give you
the copyright and licensing information for the version of the Godot Engine you
use to build your project.  The Godot Engine pulls this information from a file
in [its source code repository][godot source], COPYRIGHT.txt, which the
compiler reads and then bakes into the game engine.  This file is written in
[a standard format][debian license file format] which is parsed by the compiler
to create the information you can pull from the engine.

The problem with obtaining licensing information in this way is that the data
it gives you still needs to be displayed in a clear and human-readable format.
As it stands, what the engine is giving you is arrays of dictionaries which
also contain arrays.

What GUiLD does is read in the licensing information from the engine and use
it to create a popup dialog which displays a list of buttons that the user can
press to view attribution notices and the full text of any license for any
third-party modules which the Godot Engine might be using.

As an extra feature, the popup dialog will also read copyright information for
_your_ project and display that in a separate list from the copyright
information for the Godot Engine, so that your software licenses can be easily
displayed and unambiguously separated from the licenses which the Godot Engine
is subject to.  In order to do this, you must create a COPYRIGHT.txt file
yourself.

A sample COPYRIGHT.txt file which displays the copyright information
for the Godot Unofficial License Dialog has been included in the source
repository which you can use as a reference, and a sample project has been
included which you can use to see the popup in action.

How To Use It
-------------

Before you do anything else, please read the [Disclaimer](#disclaimer) below to
make sure you fully understand what GUiLD does and does not do.

To use GUiLD in your project, copy the [script](license_dialog.gd) and
[scene](license_dialog.tscn) files into your Godot Engine project folder.
These files will give you a node named `LicenseDialog` which can be used as a
regular popup dialog that will display the licensing information for your
project.

For more details and further setup instructions, please [read the Getting
Started file][Getting Started] in the docs folder.

Disclaimer
----------

The Godot Unofficial License Dialog (GUiLD) **does not** check for
compatibility between licenses and **does not** guarantee that you will be
fully complaint with the licenses for any software you may be using in your
project.  YOU ARE SOLELY RESPONSIBLE FOR ENSURING THAT YOU ARE COMPLIANT WITH
THIRD-PARTY SOFTWARE LICENSES!

GUiLD **does not** include attribution notices or license texts automatically;
it only pulls this information from the Godot Engine and from information which
you yourself supply.  Please read the documentation carefully so you know what
you are doing.

Use of GUiLD in your project may not in itself be sufficient in order to remain
compliant with certain software licenses--some licenses will require more than
an attribution notice and/or inclusion of the full text of a license with the
software.  For example, software using [copyleft] licenses such as the [GNU
General Public Licenses][GPL] may require you to distribute your source code if
you incorporate portions of their source code.  Be sure to read the licenses
for any third-party materials carefully before using them in your project.

The author of this software is not affiliated with the Godot Engine project and
does not represent the Godot Engine project in any capacity; GUiLD is not
endorsed by the Godot Engine project.

THE AUTHOR AND CONTRIBUTORS OF THIS SOFTWARE ARE NOT LAWYERS AND ARE NOT
PROVIDING LEGAL ADVICE!  THE USE OF THIS SOFTWARE IN ANY PROJECT IS NOT
ENDORSED BY THE AUTHOR OR CONTRIBUTORS OF THIS SOFTWARE AND ITS EFFECTIVENESS
OR FUNCTIONALITY IS NOT GUARANTEED.

THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

[Godot]: https://godotengine.org/
[godot source]: https://github.com/godotengine/godot/
[debian license file format]: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
[Getting Started]: docs/GETTING_STARTED.md
[copyleft]: https://en.wikipedia.org/wiki/Copyleft
[GPL]: https://en.wikipedia.org/wiki/GNU_General_Public_License
