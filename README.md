Bathyscaphe
===========

Bathyscaphe is a command-line tool for downloading subtitles for tv-shows from addic7ed.com.

Subtitles are searched based on tv-show file name. Only english subtitles with highest dowloads counter, regardless of the release team, will be downloaded. Downloaded subtitles are automatically renamed and saved next to corresponding files.

Existing solutions such as [Periscope](http://code.google.com/p/periscope/) and [Submarine](https://github.com/blazt/submarine) are more powerfull then bathyscaphe, they're using file hashes to search subtitles with API-powered services (Podnapisi, Opensubtitles, etc). And frankly, I use periscope myself most of the time. But they don't work for recently released episodes of tv-shows. And having to go to addic7ed.com every time new episode comes out is a pain in the butt. So *bathyscaphe* to the rescue.

Be aware: there is a limit of 30 subs per day set by addic7ed.com.

Tell me if your show wasn't recognized by bathyscaphe. Or change Bathyscaphe::TVDB and make pull request.

### INSTALL

    $ git clone git://github.com/ilzoff/bathyscaphe.git
    $ cd bathyscaphe
    $ rake install

or just 

    $ gem install bathyscaphe

### USAGE

    $ bathyscaphe [OPTIONS] TV_SHOW

#### Options
    -d, --dry-run                    Parse filename but do not download anything
    -h, --help                       Show usage

### Changelog

#### 0.1.3
- RDoc + Refactoring

#### 0.1.2
- Some new exceptions handling
- LICENCE defined

#### 0.1.1
- Readme changed =)

#### 0.1.0
- Initial release

### TODO

  1. Test regexp for matching more tv-show names
  2. Write some tests
  3. Maybe add other sources

### Authors

  - Ilia Zemskov (http://nbspace.ru) ilzoff@gmail.com

### License

I don't care.

Copyright © 2012 Ilia Zemskov

MIT License. See LICENSE