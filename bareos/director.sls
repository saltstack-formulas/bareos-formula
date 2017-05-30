# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bareos/map.jinja" import bareos with context %}
{% set dir_config = bareos.director.config if bareos.director.config is defined else {} %}
{% set requires_password = ['client', 'console', 'director', 'storage'] %}

{% if bareos.use_upstream_repo %}
include:
  - .repo
{% endif %}

bareos_director:
  pkg.installed:
    - name: {{ bareos.director.pkg }}
    - require:
      - bareos_repo

  service.running:
    - name: {{ bareos.director.service }}
    - enable: true

{% if dir_config != {} %}
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.director.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ dir_config|json() }}
        default_password: {{ bareos.default_password }}
        requires_password: {{ requires_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
{% endif %}
