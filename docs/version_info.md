# Versioning Information

The purpose of this document is to clarify what the version number for License
Dialog for Redot means and how it can be used to determine what versions of
Redot this project is compatible with.

This project _does not_ use [semantic versioning][semver].  This is because the
purpose of the project is to serve as a useful add-on to the Redot Engine, and
different versions of the Redot Engine will require different versions of the
license dialog in order to maintain compatibility.  So, the version number for
the License Dialog for Redot project is based on the version of the Redot
Engine that it is compatible with.

[semver]: https://semver.org/

To put it simply, the first two numbers in the version indicate the _minimum_
version of Redot Engine that is required in order to use License Dialog for
Redot.  For example, if you are currently using version 4.4.0, it will only
work on Redot Engine versions 4.4 and later.  However, if you are using
version 4.0.1, you may use it on versions of Redot Engine 4.0 and later.

**Note:** The earliest stable version of Redot Engine is 4.3-stable.  However,
there is not a License Dialog for Redot version 4.3.0, because the version of
the project that was made for Godot Engine version 4.0-stable still works on
versions 4.3 and earlier.

The third number starts at 0 and is incremented each time that version of
License Dialog for Redot is updated, whether that be for a bugfix or (less
likely) for a more substantial feature change.

Prerelease versions are indicated following a dash.  If there is no dash in
the version information, that means you have a release version that should be
stable.  I try to avoid prereleases, since they make the version history
messy, but I will use them if I'm releasing a version of License Dialog for
Redot for a non-stable version of Redot Engine.

If the version number ends with "dev," that means the code you've downloaded
is not production-ready and is not a tagged version.  You should download a
release or prerelease version.


## Is My Version of Redot Compatible?

To answer this question, all you have to do is check which version of Redot
you are using (this is output in the command line at startup but can also be
found in-engine by going to the Help menu and clicking on "About Engine") and
comparing the first two numbers to the first two numbers in License Dialog for
Redot's version.  If License Dialog's numbers are bigger, that means it's not
compatible.

If they're smaller, it's probably compatible, but it may require updates.
Currently, Redot Engine version 4.4 has to make changes to the scene files in
order to make it compatible.  At time of writing, I'm working on a License
Dialoge for Redot version 4.4.0, which will be compatible with Redot Engine
4.4 without needing to make changes.


## Where Do I Find the Version Number?

The version number for License Dialog for Redot can be found in a comment
line near the top of the [script file][license_dialog.gd].  Beneath that
comment line will be a comment indicating what versions of Redot Engine that
version of the license dialog has been tested on.

[license_dialog.gd]: ../addons/swashberry/license_dialog/license_dialog.gd

There is not currently any other place in code where the version number can
be obtained, since this is not critical information for the API.


## Where Can I Get Updated Versions?

The [GitHub Releases Page][gh-releases] is currently where release versions
of License Dialog for Redot are published.  Be sure to pay attention to
whether you're downloading a Release or Prerelease version.

[gh-releases]: https://github.com/swashdev/redot-license-dialog/releases
