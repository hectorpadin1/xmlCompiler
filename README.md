# Design and implementation of simple XML syntax validator

The parser has been done incrementally, starting with the simplest file: a header and a tag without text, until we were able to validate files with nested tags, comments, etc. In case there is an error, the parser will display a brief but descriptive error message along with the line where it found the problem.

This parser is able to validate xml files taking into account the following conditions:
* Tags do not contain attributes.
* DTD or Schema files are not consider.
* The file must start with an xml header.
* Outside the root tag, there can only be comments and the header at the beginning of the file.
* Within the root tag there may be more nested root tags, which may be followed by more tags, and tag text.
* No line breaks, spaces or tabs are consider for the xml syntax (<o></o> is the same as <o><Enter></o>), but they are consider for naming tags (<o>!=<' 'o>).
* Comments can go on any line except before the header.
* When a label is opened, it must be closed with the same label name.

  Several test files, with descriptive names, have been left in order to test the above guidelines.
