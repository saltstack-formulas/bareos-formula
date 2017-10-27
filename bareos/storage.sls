# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set sd_config = bareos.storage.config if bareos.storage.config is defined else {} %}
{% set require_password = ['director'] %}

{% if bareos.use_upstream_repo %}
include:
  - bareos.repo
{% endif %}

install_storage_package:
  pkg.installed:
    - name: {{ bareos.storage.pkg }}
    - version: {{ bareos.version }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

install_storage_plugins:
  pkg.installed:
    - pkgs: {{ bareos.storage.backends }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

{% if sd_config != {} %}
bareos_storage_cfg_file:
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
      - pkg: bareos-storage
    - watch_in:
      - service: bareos_storage_service
{% endif %}

bareos_storage_service:
  service.running:
    - name: {{ bareos.storage.service }}
    - enable: true
    - require:
      - pkg: bareos-storage
