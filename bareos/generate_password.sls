{% if salt['pillar.get']('bareos:generate_unique_password', False) %}
/etc/bareos/bareos-dir.d/password.conf:
  file.managed:
    - contents: "Password: {{ salt['random.get_str']() }}"
    - replace: False
{% endif %}
