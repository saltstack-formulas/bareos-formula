# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set sd_config = bareos.storage.config if bareos.storage.config is defined else {} %}
{% set require_password = ['director'] %}
{% set pkgs = [bareos.storage.pkg] + bareos.storage.backends %}

{% if bareos.use_upstream_repo %}
include:
  - bareos.repo
{% endif %}

bareos_storage:
  pkg.installed:
    - pkgs: {{ pkgs }}
    {% if bareos.use_upstream_repo %}
    - require:
      - bareos_repo
    {% endif %}

{% if sd_config != {} %}
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.storage.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ sd_config|json() }}
        default_password: {{ bareos.default_password }}
        require_password: {{ require_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: bareos_storage
    - watch_in:
      - service: bareos_storage
{% endif %}

  service.running:
    - name: {{ bareos.storage.service }}
    - enable: true
    - require:
      - pkg: bareos_storage

