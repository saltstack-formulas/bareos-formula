# -*- coding: utf-8 -*-
# vim: ft=sls
{% from "bareos/map.jinja" import bareos with context %}
{% set dir_config = bareos.director.config if bareos.director.config is defined else {} %}
{% set require_password = ['client', 'console', 'director', 'storage'] %}
{% set pkgs = [bareos.director.pkg, bareos.director.database.backend_pkq] + bareos.director.plugins %}

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

{% if bareos.director.database.manage %}
  {% if bareos.director.database.backend_pkq == 'bareos-database-postgresql' %}
    {% set su_prefix = 'su postgres -c ' %}
    {% set sql_cmd_db_exist = 'psql -tc "\l"|grep ' ~ bareos.director.database.dbname  %}
    {% set sql_cmd_table_exist = 'psql -tc "\dt" ' ~bareos.director.database.dbname ~ ' |grep -i media' %}
    {% set sql_cmd_user_exist = 'psql -tc "\du"|grep ' ~ bareos.director.database.user  %}
  {% else %}
    {% set su_prefix = '' %}
    {% set sql_cmd_db_exist = 'mysql -e "show databases" |grep ' ~ bareos.director.database.dbname %}
    {% set sql_cmd_table_exist = 'mysql -e "show tables" ' ~ bareos.director.database.dbname ~ ' |grep -i media' %}
    {% set sql_cmd_user_exist = 'mysql -e "select user from user" mysql |grep ' ~ bareos.director.database.user  %}
  {% endif %}
{% set create_cmd = su_prefix ~ '/usr/lib/bareos/scripts/create_bareos_database' %}
{% set populate_cmd = su_prefix ~ '/usr/lib/bareos/scripts/make_bareos_tables' %}
{% set grant_cmd = su_prefix ~ '/usr/lib/bareos/scripts/grant_bareos_privileges' %}
bareos_database_create:
  cmd.run:
    - name: {{ create_cmd }}
    - unless: {{ su_prefix }}{{ sql_cmd_db_exist }}
    - require:
      - pkg: bareos_director
    - watch:
      - pkg: bareos_director
    - watch_in:
      - service: bareos_director

bareos_database_populate:
  cmd.run:
    - name: {{ populate_cmd }}
    - unless: {{ su_prefix }}{{ sql_cmd_table_exist }}
    - require:
      - cmd: bareos_database_create
    - watch:
      - pkg: bareos_director
    - watch_in:
      - service: bareos_director
bareos_database_grant:
  cmd.run:
    - name: {{ grant_cmd }}
    - unless: {{ su_prefix }}{{ sql_cmd_user_exist }}
    - require:
      - cmd: bareos_database_populate
    - watch:
      - pkg: bareos_director
    - watch_in:
      - service: bareos_director
{% endif %}
