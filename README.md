Bathyscaphe
===========

Bathyscaphe is a command-line tool for downloading subtitles for tv-shows from addic7ed.com. Subtitles are searched based on tv-show file name. Downloaded subtitles are automatically renamed and saved next to corresponding files.

Existing solutions such as [Periscope](http://code.google.com/p/periscope/) and [Submarine](https://github.com/blazt/submarine) are more powerfull, they're using file hashes to search subtitles with API-powered services (Podnapisi, Opensubtitles, etc). And I use periscope most of the time for movies and old episodes ov tv-shows. But they don't work in case of just released episodes of tv-shows. And going to addic7ed.com every time is pain in the butt. So *bathyscaphe* to the rescue.

Be aware: there is a limit of 30 subs per day set by addic7ed.com. 

### INSTALL

    $ git clone https://ilzoff@github.com/ilzoff/bathyscaphe.git
    $ cd bathyscaphe
    $ gem install bones
    $ rake gem:install

### USAGE

    $ bathyscaphe [OPTIONS] TV_SHOW

#### Options
    -d, --dry-run                    Parse filename but do not download anything
    -h, --help                       Show usage

### TODO

  1 Test regexp for matching more tv-show names

### Authors

  - Ilia Zemskov (nbspace.ru) ilzoff@gmail.com