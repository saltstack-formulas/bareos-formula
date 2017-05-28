# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "bareos/map.jinja" import bareos with context %}

bareos-config:
  file.managed:
    - name: {{ bareos.config }}
    - source: salt://bareos/files/example.tmpl
    - mode: 644
    - user: root
    - group: root
