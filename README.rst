==============
bareos-formula
==============

.. image:: https://travis-ci.org/saltstack-formulas/packages-formula.svg?branch=master

A saltstack formula to install and configure `BareOS <https://www.bareos.org>`_,
a master/slave server tool.

(This formula will probably be useful to install Bacula too, just changing the
`pkg` variables in the pillar data).

OS Compatibility
================

Tested with:

* Debian 9
* CentOS 6 and 7
* Ubuntu 16.04

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Formula Dependencies
====================

This formula won't try to install or configure a database server, just tries to
configure the BareOS database if possible. In case you want to use ``Postgresql``
or ``MySQL``, use the respective formulas. If your database is on another host,
you just need to configure the database host/user/password in the pillar.

TODO
====

The database management is REALLY basic yet and should be used with care. 


Available states
================

.. contents::
    :local:

``bareos``
----------

Installs and configures all the bareos components (includes ``bareos.director``,
``bareos.storage`` and ``bareos.client``.

``bareos.director``
-------------------

Installs and configures the bareos director, and starts the associated service.

``bareos.storage``
------------------

Installs and configures the bareos storage, and starts the associated service.

``bareos.client``
-----------------

Meta-state that includes `bareos.filedaemon`, `baeros.bconsole`  and `bareos.traymonitor`.

``bareos.filedaemon``
---------------------

Installs and configures the bareos filedaemon, and starts the associated service.

``bareos.bconsole``
-------------------

Installs and configures the bareos console.

``bareos.repo``
---------------

Configures the upstream bareos' repo (true, by default).

``bareos.traymonitor``
----------------------

Installs and configures the bareos tray-monitor.

Example Pillar
==============

BareOS daemons' configuration, since version >= 16.2.2, can be done by mean of
config files or config directories/subdirectories.

The formula, to ease management, follows this logic:

1. By default, the formula will setup and use the upstream BareOS repo.

2. If no pillar key named `config` exists for a given daemon, it will be intalled
   and the default configuration included in the package (or a custom configuration
   set by any other mean) will be used. No configuration will be attempted.

   This means the current `subdirectories` configuration schema provided by the
   package will be used (see `Configuration Layout <http://doc.bareos.org/master/html/bareos-manual-main-reference.html#QQ2-1-150>`_.

3. If a pillar key named `config` is present for a given daemon, it will be
   installed and configured. This formula will use the "old approach" of setting
   all the configuration for the daemon in a single file, ignoring the rest of the
   included subdirectories. This may seem counter-intuitive at first, because
   reading different small configuration files is easier. But the advantage is
   that, when you remove a key/value from the bareos pillar, the config file
   will be regenerated and you won't need to remove lingering files, or keep
   pillar keys with 'remove/delete/disable' values.

   The configuration for each BareOS daemon (director, storage, filedaemon) is
   generated from pillar data if a key `config` exist for such daemon, ie:
    
.. code:: yaml

    bareos:
    
      director:
        ...
        config:
          ...
          ...


   If no `config` section is given, no configuration will be perfomed, and the
   existing configuration will be used (or the one provided by the package).

   The `config` sections are ordered by resource type, like in the following example.

   Keys names are case insensitive.
    
   Keys that can be repeated multiple times (like `run`, in Schedules) should be
   written as lists, and they will be expanded accordingly.

   Resources that require a `Name` will use the provided one, or the dict name if no
   `Name` is provided.

   Resources that require `Password`, will use the provided password in each `config`
   section, or will use the password set in 'bareos:default_password'. If none is
   specified, this formula will use "default_bareos_formula_password" as the default
   password).

   The include file `@` parameter is an 'special case' of the resource_type, and should
   be written as a list instead of a dict, as shown below.

.. code:: yaml
    
    bareos:
      daemon:
        config:   
          resource_type1:
            resource1_name:
              param1: value1
              param2: 2
              param3:
                sub_param3a:
                  param3b: value3b
                  param3c: true
                  param3d:
                    - value3d_1
                    - value3d_2
                    - value3d_3
                  param3e: value_3e
                sub_param3b: 3
            resource2_name:
              name: someothername
              param1: value1
    
          resource_type2:
            resource3_name:
              param2: value2
    
          '@':
            - 'include_file1'
            - '|"/etc/bareos/generate_configuration_to_stdout.sh"'
            - '|"sh -c \"/etc/bareos/generate_client_configuration_to_stdout.sh clientname=client1.example.com\""'
    
   will create the following config file:
    
.. code:: yaml

    resource_type1 {
                
        Name = "resource1_name"
    
        param1 = "value1"
        param2 = 2
        param3 {
    
            sub_param3a {
    
                param3b = "value3b"
                param3c = True
                param3d = "value3d_1"
                param3d = "value3d_2"
                param3d = "value3d_3"
                param3e = "value_3e"
            }
            sub_param3b = 3
        }
    }
    
    resource_type1 {
                
        Name = "someothername"
    
        param1 = "value1"
    
    }
    
    resource_type2 {
                
        Name = "resource3_name"
    
        param2 = "value2"
    
    }
    
    @include_file1
    @|"/etc/bareos/generate_configuration_to_stdout.sh"
    @|"sh -c \"/etc/bareos/generate_client_configuration_to_stdout.sh clientname=client1.example.com\""


   See *bind/pillar.example* for a full example.

Contributions
=============

Contributions are always welcome. All development guidelines you have to know are:

* write clean code (proper YAML+Jinja syntax, no trailing whitespaces, no empty lines with whitespaces, LF only)
* set sane default settings
* test your code
* update README.rst doc

