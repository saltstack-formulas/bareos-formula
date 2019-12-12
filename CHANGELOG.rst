bareos formula
==============

0.1.0 (2019-02-07)
- Fix debian repository for latest version (18.2)
  * Use key_url to get GPG key from repo instead of keyserver

0.0.5 (2018-07-11)
- New upstream version
  * Added travis support
  * Fixed tests

0.0.4 (2017-10-27)
- Changed bconsole, filedaemon, storage & traymonitor State files:
  * Pin package versions
  * Separate the installation of core packages and plugins

0.0.3 (2017-10-20)

- Fixed Test-Kitchen
- Changed Director State file
  * Pin package version
  * Separate the installation of core packages and director plugins
  * Changed the database management to use build-in function
    to run commands as a separate user

0.0.2 (2017-05-28)

- Add initial management for configs
- Add filedaemon management


0.0.1 (2017-05-27)

- Initial version
