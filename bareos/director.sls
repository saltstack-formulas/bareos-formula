# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bareos/map.jinja" import bareos with context %}
{% set dir_config = bareos.director.config %}
include:
  - .repo

bareos_director:
  pkg.installed:
    - name: {{ bareos.director.pkg }}
    - require:
      - bareos_repo

  service.running:
    - name: {{ bareos.director.service }}
    - enable: true

  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.director.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ dir_config|json() }}
        default_password: {{ bareos.default_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
