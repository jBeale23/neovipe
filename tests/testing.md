# Testing Guide
Unfortunately, I have yet to find a way to fully automate testing, as some of NeoVipe's behavior depends on end user input, so for now this must be run manually.
To run the tests, simply invoke ./test_neovipe.sh directly or via sh, then follow the instructions as they appear in your $EDITOR.

## The Flag Parsing Tests
These ensure that NeoVipe accurately parses its command line arguments.

## The Editing Tests
These ensure that NeoVipe appropriately emits edited output when it should, and fails to when it shouldn't.

## The Exit Code Tests
These ensure that NeoVipe emits the appropriate return code when something goes wrong in how the user is employing it.

## The Saturation Test
This test ensures that NeoVipe exits with an appropriate error code when something causes a failure in temporary file creation. It does so by generating all possible 3 digit alphanumeric filenames, guaranteeing that a collision will occur. Naturally, this test takes substantially longer than the others (~4 minutes to run and clean up on my machine), and thus the user is prompted to ask if they want to run it.
