# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context -%}

{% if grains.os == 'Ubuntu' -%}
  {% set distro = 'x' ~ grains.os ~ '_' ~ grains.osrelease %}
{%- elif grains.os == 'Debian' %}
  {% set distro = grains.os ~ '_' ~ grains.osmajorrelease ~ '.0' %}
{%- elif grains.os == 'RedHat' %}
  {% set distro = 'RHEL' ~ '_' ~ grains.osmajorrelease %}
{%- else %}
  {% set distro = grains.os ~ '_' ~ grains.osmajorrelease %}
{%- endif %}
{% set url = bareos.repo.repo_url if bareos.repo.repo_url is defined else bareos.repo.url_base ~ '/' ~ bareos.repo.version ~ '/' ~ distro %}

{% if grains.os_family == 'Debian' -%}
bareos_repo:
  pkgrepo.managed:
    - humanname: {{ bareos.repo.humanname }} - {{ bareos.repo.version }}
    - name: deb {{ url }} ./
    - file: {{ bareos.repo.file }}
    {% if bareos.repo.key_url is defined -%}
    - key_url: {{ url }}/Release.key
    {% else -%}
    - keyid: {{ bareos.repo.keyid }}
    - keyserver: {{ bareos.repo.keyserver }}
    {% endif -%}

{%- elif grains.os_family == 'RedHat' %}
bareos_repo:
  pkgrepo.managed:
    - name: bareos
    - file: {{ bareos.repo.file }}
    - humanname: {{ bareos.repo.humanname }} - {{ bareos.repo.version }}
    - baseurl: {{ url }}/
    - gpgcheck: 1
    - gpgkey: {{ url }}/repodata/repomd.xml.key

{%- else %}
bareos_repo: {}
{%- endif %}
