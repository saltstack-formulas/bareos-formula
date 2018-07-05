bareos formula
==============

0.0.6 (2017-11-13)
Add support of dynamic Client - Director Configuration
Update README

0.0.5 (2017-11-01)
Use pillar file instead of populating the kitchen.yml
   This change is necessary because:
   * It's easier and cleaner to have pillar data in a separate file
   The issue is resolved in this commit by:
   * Adding a new pillar file

Clean up default configuration from all services
   This change is necessary because:
   * Bareos 16.x comes with a new configuration structure,
   they introduced several directories and split the configuration into different files.
   As we would like to have a central config file for every service,
   it's good to clean up the default config and structure.
   The issue is resolved in this commit by:
   * When we install a new package, we automatically clean up those directories.

Fixed jinja template IF statements
   This change is necessary as the template wasn't adding
   the name & password <key:value> elements when the config object
   had a <key> that partially contains those strings.

   Example
   -------
   yaml object

   director:
     config:
       Catalog:
         MyCatalog:
           DbName: bareos

   The 'Name = MyCatalog' was missing from the generated config
   as the object has DbName <key>

Change the object format that we pass to Jinja template
   As pillar is in yaml format, it's better to pass the same format to Jinja template

Fix map.jinja file
   Merge the file contents with pillar data

Clean up repo.sls code
   Use the same syntax when calling grains

Security hardening
   Change file permissions and owner/group

Remove Debian-9 as supported platform

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
