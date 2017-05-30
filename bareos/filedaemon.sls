# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bareos/map.jinja" import bareos with context %}
{% set fd_config = bareos.filedaemon.config if bareos.filedaemon.config is defined else {} %}
{# http://doc.bareos.org/master/html/bareos-manual-main-reference.html#QQ2-1-197 #}
{% set required_resources = ['client', 'director', 'message'] %}
{% set requires_password = ['director'] %}

{% if bareos.use_upstream_repo %}
include:
  - .repo
{% endif %}

bareos_filedaemon:
  pkg.installed:
    - name: {{ bareos.filedaemon.pkg }}
    - require:
      - bareos_repo

  service.running:
    - name: {{ bareos.filedaemon.service }}
    - enable: true

{% if fd_config != {} %}
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.filedaemon.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ fd_config|json() }}
        default_password: {{ bareos.default_password }}
        required_resources: {{ required_resources  }}
        requires_password: {{ requires_password }}
    - template: jinja
    - mode: 644
    - user: root
    - group: root
{% endif %}

