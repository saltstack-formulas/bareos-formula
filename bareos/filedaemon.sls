# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set fd_config = bareos.filedaemon.config if bareos.filedaemon.config is defined else {} %}
{% set require_password = ['director'] %}

include:
  - bareos.generate_password
{% if bareos.use_upstream_repo  %}
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
    {% if salt['pillar.get']('bareos:generate_unique_password', False) %}
    - require_in:
      - file: bareos_password_file
    {% endif %}

install_fd_plugins:
  pkg.installed:
    - pkgs: {{ bareos.filedaemon.plugins }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

{% if fd_config != {} %}
cleanup_fd_default_config:
  file.absent:
    - name: {{ bareos.config_dir }}/{{ bareos.filedaemon.config_dir }}
    - onchanges:
      - pkg: install_fd_package

bareos_fd_cfg_file:
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.filedaemon.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ fd_config|yaml() }}
        default_password: {{ bareos.default_password }}
        require_password: {{ require_password }}
    - template: jinja
    - mode: 640
    - user: {{ bareos.system_user }}
    - group: {{ bareos.system_group }}
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

{% if bareos.filedaemon.plugins_files is defined and bareos.filedaemon.plugins_files_master_dir is defined %}
{% for dir in bareos.filedaemon.plugins_files %}
plugins_files_{{ dir }}:
  file.recurse:
    - name: {{ bareos['Plugin Directory']}}
    - name: /usr/lib64/bareos/plugins
    - source: salt://{{bareos.filedaemon.plugins_files_master_dir}}/fd-plugins/{{dir}}
    - include_empty: True
    - exclude_pat: README*
{% endfor %}
{% endif %}
