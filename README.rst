==============
bareos-formula
==============

A saltstack formula to install `BareOS <https://www.bareos.org>`_, a master/slave server tool.
 
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
