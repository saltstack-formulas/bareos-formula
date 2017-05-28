# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bareos/map.jinja" import bareos with context %}
{% set fd_config = bareos.filedaemon.config %}
include:
  - .repo

bareos_filedaemon:
  pkg.installed:
    - name: {{ bareos.filedaemon.pkg }}
    - require:
      - bareos_repo

  service.running:
    - name: {{ bareos.filedaemon.service }}
    - enable: true

  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.filedaemon.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ fd_config|json() }}
        default_password: {{ bareos.default_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
