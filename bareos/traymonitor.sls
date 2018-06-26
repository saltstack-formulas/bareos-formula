# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set tm_config = bareos.traymonitor.config if bareos.traymonitor.config is defined else {} %}
{% set require_password = ['director'] %}

include:
  - bareos.generate_password
{% if bareos.use_upstream_repo %}
  - bareos.repo
{% endif %}

install_traymon_package:
  pkg.installed:
    - name: {{ bareos.traymonitor.pkg }}
    - version: {{ bareos.version }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}


{% if tm_config != {} %}
cleanup_traymon_default_config:
  file.absent:
    - name: {{ bareos.config_dir }}/{{ bareos.traymonitor.config_dir }}
    - onchanges:
      - pkg: install_traymon_package

bareos_traymon_cfg_file:
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.traymonitor.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ tm_config|yaml() }}
        default_password: {{ bareos.default_password }}
        require_password: {{ require_password }}
    - template: jinja
    - mode: 640
    - user: {{ bareos.system_user }}
    - group: {{ bareos.system_group }}
    - require:
      - pkg: install_traymon_package
{% endif %}
