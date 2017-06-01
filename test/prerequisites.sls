# To test that all the states apply correctly, we need a database installed,
# so this state is just to install a bare mysql server

{% if salt['grains.get']('osfinger') == 'CentOS Linux-7' %}
  {% set pkgs = ['mariadb-server', 'mariadb'] %}
  {% set daemon = 'mariadb' %}
{% elif salt['grains.get']('osfinger') == 'CentOS-6' %}
  {% set pkgs = ['mysql-server', 'mysql'] %}
  {% set daemon = 'mysqld' %}
{% else %}
  {% set pkgs = ['mysql-server', 'mysql-client'] %}
  {% set daemon = 'mysql' %}
{% endif %}

mysql_server:
  pkg.installed:
    - pkgs: {{ pkgs }}
  service.running:
    - name: {{ daemon }}
    - require:
      - pkg: mysql_server
    - require_in:
      - cmd: bareos_database_create
