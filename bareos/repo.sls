# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context -%}

{% if grains.os == 'Ubuntu' -%}
  {% set distro = 'x' ~ grains.os ~ '_' ~ grains.osrelease %}
{%- elif grains.os == 'Debian' %}
  {% set distro = grains.os ~ '_' ~ grains.osmajorrelease ~ '.0' %}
{%- else %}
  {% set distro = grains.os ~ '_' ~ grains.osmajorrelease %}
{%- endif %}

{% if salt['grains.get']('os_family') == 'Debian' -%}
bareos_repo:
  pkgrepo.managed:
    - humanname: {{ bareos.repo.humanname }} - {{ bareos.repo.version }}
    - name: deb {{ bareos.repo.url_base }}/{{ bareos.repo.version }}/{{ distro }} ./
    - file: {{ bareos.repo.file }}
    - keyid: {{ bareos.repo.keyid }}
    - keyserver: {{ bareos.repo.keyserver }}

{%- elif salt['grains.get']('os_family') == 'RedHat' %}
bareos_repo:
  pkgrepo.managed:
    - name: bareos
    - file: {{ bareos.repo.file }}
    - humanname: {{ bareos.repo.humanname }} - {{ bareos.repo.version }}
    - baseurl: {{ bareos.repo.url_base }}/{{ bareos.repo.version }}/{{ distro }}/
    - gpgcheck: 1
    - gpgkey: {{ bareos.repo.url_base }}/{{ bareos.repo.version }}/{{ distro }}/repodata/repomd.xml.key

{%- else %}
bareos_repo: {}
{%- endif %}
