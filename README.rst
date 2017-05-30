==============
bareos-formula
==============

A saltstack formula to install and configure `BareOS <https://www.bareos.org>`_,
a master/slave server tool.

BareOS daemons' configuration, since version >= 16.2.2, can be done by mean of
config files or config directories/subdirectories.

This formula, to ease management, will follow this logic:

1. If no pillar key named `config` exists for a given daemon, it will be intalled
   and the default configuration included in the package (or a custom configuration
   set by any other mean) will be used. No configuration will be attempted.

   This means the current `subdirectories` configuration schema provided by the
   package will be used (see `Configuration Layout <http://doc.bareos.org/master/html/bareos-manual-main-reference.html#QQ2-1-150>`_.

2. If a pillar key named `config` is present for a given daemon, it will be
   installed and configured. This formula will use the "old approach" of setting
   all the configuration for the daemon in a single file, ignoring the rest of the
   included subdirectories. This may seem counterintuitive at first, because
   reading different small configuration files is easier. But the advantage is
   that, when you remove a key/value from the bareos pillar, the config file
   will be regenerated and you won't need to remove lingering files, or keep
   pillar keys with 'remove/delete/disable' values.

.. note::

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/en/latest/topics/development/conventions/formulas.html>`_.

Available states
================

.. contents::
    :local:

``bareos.director``
-------------------

Installs and configures the bareos director, and starts the associated bareos director service.

``bareos.storage``
------------------

Installs and configures the bareos storage, and starts the associated bareos storage service.

``bareos.filedaemon``
---------------------

Installs and configures the bareos filedaemon, and starts the associated bareos filedaemon service.

``bareos.client``
-----------------

Installs and configures the bareos client, and starts the associated bareos client service.
