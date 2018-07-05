{% from "bareos/map.jinja" import bareos with context %}

create_director_dynamic_config_dir:
  file.directory:
    - name: {{ bareos.config_dir }}/{{ bareos.director.config_dir }}/{{ bareos.director.dynamic_config.config_dir }}
    - mode: 750
    - user: {{ bareos.system_user }}
    - user: {{ bareos.system_group }}

bareos_dynamic_clients:
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.director.config_dir }}/{{ bareos.director.dynamic_config.config_dir }}/{{ bareos.director.dynamic_config.clients_config_file }}
    - source: salt://bareos/files/bareos-dynamic-clients.jinja
    - template: jinja
    - mode: 640
    - user: {{ bareos.system_user }}
    - user: {{ bareos.system_group }}
    - watch_in:
      - service: bareos_director_dynamic_config_service

bareos_dynamic_cfg:
  file.managed:
    - name: {{ bareos.config_dir }}/{{ bareos.director.config_dir }}/{{ bareos.director.dynamic_config.config_dir }}/{{ bareos.director.dynamic_config.config_file }}
    - source: salt://bareos/files/bareos-dynamic-config.jinja
    - template: jinja
    - mode: 640
    - user: {{ bareos.system_user }}
    - user: {{ bareos.system_group }}
    - watch_in:
      - service: bareos_director_dynamic_config_service

bareos_director_dynamic_config_service:
  service.running:
    - name: {{ bareos.director.service }}
    - enable: true
