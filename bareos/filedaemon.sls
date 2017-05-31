# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set fd_config = bareos.filedaemon.config if bareos.filedaemon.config is defined else {} %}
{% set require_password = ['director'] %}
{% set pkgs = [bareos.filedaemon.pkg] + bareos.filedaemon.plugins %}

{% if bareos.use_upstream_repo %}
include:
  - bareos.repo
{% endif %}

bareos_filedaemon:
  pkg.installed:
    - pkgs: {{ pkgs }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

{% if fd_config != {} %}
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.filedaemon.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ fd_config|json() }}
        default_password: {{ bareos.default_password }}
        require_password: {{ require_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: bareos_filedaemon
    - watch_in:
      - service: bareos_filedaemon
{% endif %}

  service.running:
    - name: {{ bareos.filedaemon.service }}
    - enable: true
    - require:
      - pkg: bareos_filedaemon

