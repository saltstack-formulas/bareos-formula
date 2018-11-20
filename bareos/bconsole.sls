# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set bc_config = bareos.bconsole.config if bareos.bconsole.config is defined else {} %}
{% set require_password = ['director'] %}

include:
  - bareos.generate_password
{% if bareos.use_upstream_repo %}
  - bareos.repo
{% endif %}

install_bconsole_package:
  pkg.installed:
    - name: {{ bareos.bconsole.pkg }}
    - version: {{ bareos.version }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}
    {% if salt['pillar.get']('bareos:generate_unique_password', False) %}
    - require_in:
      - file: bareos_password_file
    {% endif %}

{% if bc_config != {} %}
bareos_bconsole_cfg_file:
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.bconsole.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ bc_config|yaml() }}
        default_password: {{ bareos.default_password }}
        require_password: {{ require_password }}
    - template: jinja
    - mode: 640
    - user: {{ bareos.system_user }}
    - group: {{ bareos.system_group }}
    - require:
      - pkg: install_bconsole_package
{% endif %}
