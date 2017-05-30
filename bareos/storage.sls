# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bareos/map.jinja" import bareos with context %}
{% set sd_config = bareos.storage.config if bareos.storage.config is defined else {} %}
{% set requires_password = ['director'] %}

{% if bareos.use_upstream_repo %}
include:
  - .repo
{% endif %}

bareos_storage:
  pkg.installed:
    - name: {{ bareos.storage.pkg }}
    - require:
      - bareos_repo

  service.running:
    - name: {{ bareos.storage.service }}
    - enable: true

{% if sd_config != {} %}
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.storage.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ sd_config|json() }}
        default_password: {{ bareos.default_password }}
        requires_password: {{ requires_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
{% endif %}

