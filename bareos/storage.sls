# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bareos/map.jinja" import bareos with context %}
{% set sd_config = bareos.storage.config %}
include:
  - .repo

bareos_storage:
  pkg.installed:
    - name: {{ bareos.storage.pkg }}
    - require:
      - bareos_repo

  service.running:
    - name: {{ bareos.storage.service }}
    - enable: true

  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.storage.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ sd_config|json() }}
        default_password: {{ bareos.default_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
