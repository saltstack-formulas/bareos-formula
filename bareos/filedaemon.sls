# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set fd_config = bareos.filedaemon.config if bareos.filedaemon.config is defined else {} %}
{% set require_password = ['director'] %}

{% if bareos.use_upstream_repo %}
include:
  - bareos.repo
{% endif %}

install_fd_package:
  pkg.installed:
    - name: {{ bareos.filedaemon.pkg }}
    - version: {{ bareos.version }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

install_fd_plugins:
  pkg.installed:
    - pkgs: {{ bareos.filedaemon.plugins }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

{% if fd_config != {} %}
bareos_fd_cfg_file:
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
      - pkg: install_fd_package
    - watch_in:
      - service: bareos_fd_service
{% endif %}

bareos_fd_service:
  service.running:
    - name: {{ bareos.filedaemon.service }}
    - enable: true
    - require:
      - pkg: install_fd_package
