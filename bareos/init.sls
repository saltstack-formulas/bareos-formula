# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context -%}

include:
  - bareos.director
  - bareos.storage
  - bareos.client
