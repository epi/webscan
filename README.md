# webscan
Web UI for SANE. That's it.
You just type webscan's address in your browser, press Scan and download the scanned page.
I've installed it on my Raspberry Pi with an old HP LJ 1220 attached to it
and now everyone in the local network can scan their stuff without worrying about cables and drivers.

## installation
You need a recent [D compiler](http://dlang.org/download.html)
and [dub package manager](http://code.dlang.org/download).
I've tested webscan with DMD 2.068.1 on x86_64 and GDC 5.2.0+2.066.1 on x86_64 and ARM hard float.

Building for Raspberry Pi looks like this (make sure that the necessary .so libraries for libevent and OpenSSL
are accessible to your compiler):

    dub build --compiler=/opt/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-gdc

Once built, copy the binary to the machine you want to use as the scan server, create a directory
named "result" in the same directory as the binary, and just run webscan there. Make sure sane is installed
and webscan is executed with sufficient privileges to access the scanner.

## license
It's public domain. See the file UNLICENSE. No charges, no restrictions, no warranty of any kind.
