# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set dir_config = bareos.director.config if bareos.director.config is defined else {} %}
{% set require_password = ['client', 'console', 'director', 'storage'] %}
{% set pkgs = [bareos.director.pkg] + bareos.director.plugins %}

{% if bareos.use_upstream_repo %}
include:
  - bareos.repo
{% endif %}

bareos_director:
  pkg.installed:
    - pkgs: {{ pkgs }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

{% if dir_config != {} %}
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.director.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ dir_config|json() }}
        default_password: {{ bareos.default_password }}
        require_password: {{ require_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: bareos_director
    - watch_in:
      - service: bareos_director
{% endif %}

  service.running:
    - name: {{ bareos.director.service }}
    - enable: true
    - require:
      - pkg: bareos_director
