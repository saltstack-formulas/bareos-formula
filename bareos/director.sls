# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set dir_config = bareos.director.config if bareos.director.config is defined else {} %}
{% set require_password = ['client', 'console', 'director', 'storage'] %}
{% set backend_db_pkg = "bareos-database-" + bareos.director.database.backend %}
{% set pkgs = [bareos.director.pkg, backend_db_pkg] %}

include:
  - bareos.generate_password
{% if bareos.use_upstream_repo %}
  - bareos.repo
{% endif %}

{% for pkg in pkgs %}
{{ pkg }}:
  pkg.installed:
    - version: {{ bareos.version }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}
    {% if salt['pillar.get']('bareos:generate_unique_password', False) %}
    - require_in:
      - file: bareos_password_file
    {% endif %}
{% endfor %}

install_director_plugins:
  pkg.installed:
    - pkgs: {{ bareos.director.plugins }}
    {% if bareos.use_upstream_repo %}
    - require:
      - pkgrepo: bareos_repo
    {% endif %}

{% if dir_config != {} %}
cleanup_director_default_config:
  file.directory:
    - name: {{ bareos.config_dir }}/{{ bareos.director.config_dir }}
    - mode: 750
    - user: {{ bareos.system_user }}
    - group: {{ bareos.system_group }}
    - clean: true
    - onchanges:
      - pkg: bareos-director

create_director_dir:
  file.directory:
    - name: {{ bareos.config_dir }}/{{ bareos.director.config_dir }}/director
    - mode: 750
    - user: {{ bareos.system_user }}
    - group: {{ bareos.system_group }}

bareos_director_cfg_file:
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.director.config_dir }}/director/{{ bareos.director.config_file }}
    - source: salt://bareos/files/bareos-config.jinja
    - context:
        config: {{ dir_config|yaml() }}
        default_password: {{ bareos.default_password }}
        require_password: {{ require_password }}
    - template: jinja
    - mode: 640
    - user: {{ bareos.system_user }}
    - group: {{ bareos.system_group }}
    - require:
      - pkg: bareos-director
    - watch_in:
      - service: bareos_director_service
{% endif %}

bareos_director_service:
  service.running:
    - name: {{ bareos.director.service }}
    - enable: true
    - require:
      - pkg: bareos-director

{% if bareos.director.database.manage %}
  {% if bareos.director.database.backend == 'postgresql' %}
    {% set db_user = 'postgres' %}
    {% set sql_cmd_db_exist = 'psql -tc "\l" | grep ' ~ bareos.director.database.dbname  %}
    {% set sql_cmd_table_exist = 'psql -tc "\dt" ' ~bareos.director.database.dbname ~ ' | grep -i media' %}
    {% set sql_cmd_user_exist = 'psql -tc "\du"|grep ' ~ bareos.director.database.user  %}
  {% else %}
    {% set db_user = 'root' %}
    {% set sql_cmd_db_exist = 'mysql -e "show databases" | grep ' ~ bareos.director.database.dbname %}
    {% set sql_cmd_table_exist = 'mysql -e "show tables" ' ~ bareos.director.database.dbname ~ ' | grep -i media' %}
    {% set sql_cmd_user_exist = 'mysql -e "select user from user" mysql | grep ' ~ bareos.director.database.user  %}
  {% endif %}
{% set create_cmd = '/usr/lib/bareos/scripts/create_bareos_database ' %}
{% set populate_cmd = '/usr/lib/bareos/scripts/make_bareos_tables ' %}
{% set grant_cmd = '/usr/lib/bareos/scripts/grant_bareos_privileges ' %}

bareos_database_create:
  cmd.run:
    - name: {{ create_cmd }} {{ bareos.director.database.backend }}
    - unless: {{ sql_cmd_db_exist }}
    - runas: {{ db_user }}
    - require:
      - pkg:  bareos-director
    - watch:
      - pkg: bareos-director
    - watch_in:
      - service: bareos_director_service

bareos_database_populate:
  cmd.run:
    - name: {{ populate_cmd }} {{ bareos.director.database.backend }}
    - unless: {{ sql_cmd_table_exist }}
    - runas: {{ db_user }}
    - require:
      - cmd: bareos_database_create
    - watch:
      - pkg: bareos-director
    - watch_in:
      - service: bareos_director_service

bareos_database_grant:
  cmd.run:
    - name: {{ grant_cmd }} {{ bareos.director.database.backend }}
    - unless: {{ sql_cmd_user_exist }}
    - runas: {{ db_user }}
    - require:
      - cmd: bareos_database_populate
    - watch:
      - pkg: bareos-director
    - watch_in:
      - service: bareos_director_service
{% endif %}
