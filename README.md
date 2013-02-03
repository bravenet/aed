AED - Shock your projects to life!
==================================

Disclaimer
----------

*This branch is not in a working state.*

Prior to starting this project I had written zero lines of Tcl. If you see glaring mistakes with my Tcl, or recommendations for more succinct Tcl send a pull request.


Installation
------------

__NOTE: Much of the installation/update process will be automated in the future.__

1. git clone https://github.com/bravenet/aed.git ~/.aed
2. export PATH=~/.aed/bin:$PATH

You can track upstream changes by using git to pull them down at your leisure.

Basic Usage
-----------

__NOTE: Much of the manual project configuration will be automated in the future.__

AED looks for an `Aedfile` inside your project. The `Aedfile` describes how to bring life to your project.

A sample Aedfile will look like this

    $ cat Aedfile
    # vim: ft=sh
    defib install mongodb
    defib install redis
    defib install mysql

With an Aedfile located in the root of your project you can breath life and bootstrap your project using the `defib` command.

    $ defib
                     ______  _____
              /\    |  ____||  __ \
             /  \   | |__   | |  | |
            / /\ \  |  __|  | |  | |
           / ____ \ | |____ | |__| |
          /_/    \_\|______||_____/


              Automated External
                Defibrillator


    >> Detecting platform...

    >> Detected 'osx'

    >> Looking for package manager...

    >> Detected 'homebrew'.

    >> Shocking project to life with 'homebrew' on 'osx' ... CLEAR!!!

    >> Updating homebrew...
    Already up-to-date.

    >> Installing git hooks...

    >> Installing mongodb...

    >> already installed, skipping.

    >> Installing redis...
    ==> Downloading http://redis.googlecode.com/files/redis-2.6.4.tar.gz
    ######################################################################## 100.0%
    ==> make -C /private/tmp/redis-eC5J/redis-2.6.4/src CC=cc
    ==> Your redis.conf will not work with 2.6; moved it to redis.conf.old
    ==> Caveats
    If this is your first install, automatically load on login with:
        mkdir -p ~/Library/LaunchAgents
        cp /usr/local/Cellar/redis/2.6.4/homebrew.mxcl.redis.plist ~/Library/LaunchA
    gents/
        launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.redis.plist

    If this is an upgrade and you already have the homebrew.mxcl.redis.plist loaded:

        launchctl unload -w ~/Library/LaunchAgents/homebrew.mxcl.redis.plist
        cp /usr/local/Cellar/redis/2.6.4/homebrew.mxcl.redis.plist ~/Library/LaunchA
    gents/
        launchctl load -w ~/Library/LaunchAgents/homebrew.mxcl.redis.plist

      To start redis manually:
        redis-server /usr/local/etc/redis.conf

      To access the server:
        redis-cli
    ==> Summary
    /usr/local/Cellar/redis/2.6.4: 9 files, 740K, built in 5 seconds

    >> It lives!!

Advanced Usage
--------------

See the wiki for advanced usage topics.

Credits
-------

Many thanks are due to [Brian Stolz](/tecnobrat) with whom I bounced many ideas off of, and who helped conceive of the modules concept and layout.
