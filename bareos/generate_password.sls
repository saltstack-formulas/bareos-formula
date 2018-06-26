{% from "bareos/map.jinja" import bareos with context %}

{% if salt['pillar.get']('bareos:generate_unique_password', False) %}
bareos_password_file:
  file.managed:
    - name: {{ bareos.config_dir }}/password.conf
    - mode: 640
    - user: {{ bareos.system_user }}
    - group: {{ bareos.system_group }}
    - makedirs: True
    - contents: "Password = {{ salt['random.get_str']() }}"
    - replace: False
{% endif %}
