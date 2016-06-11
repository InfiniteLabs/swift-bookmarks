# swift-bookmarks

This is a tiny web-server based application I wrote while I was learning Swift.

## Installation

I'm assuming you already have Xcode installed.  I was using Xcode&nbsp;7.3.1 when I wrote this, although I assume it's similar with other versions.

Install [Carthage][carthage]:

    ```console
    $ brew update
    $ brew install carthage
    ```

Then install the dependencies from Carthage:

    ```console
    $ carthage update
    ```

Finally, start the server with `xcrun`:

    ```console
    $ xcrun swift -F Carthage/Build/Mac -target x86_64-macosx10.10 bookmarks.swift
    ```

[carthage]: https://github.com/Carthage/Carthage