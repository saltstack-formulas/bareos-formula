{% from "bareos/map.jinja" import bareos with context -%}

{% if salt['grains.get']('os_family') == 'Debian' -%}
bareos_repo:
  pkgrepo.managed:
    - humanname: {{ bareos.repo.humanname }}
    - name: deb {{ bareos.repo.url_base }}/{{ bareos.repo.flavour }}/{{ bareos.repo.distro }} ./
    - file: {{ bareos.repo.file }}
    - keyid: {{ bareos.repo.keyid }}
    - keyserver: {{ bareos.repo.keyserver }}

{%- elif salt['grains.get']('os_family') == 'RedHat' and
         salt['grains.get']('osmajorrelease')[0] >= '6' %}
bareos_repo:
  pkgrepo.managed:
    - name: bareos
    - humanname: BareOS Official Repository - $basearch
    - baseurl: http://repo.bareos.com/bareos/{{ bareos.version_repo }}/rhel/{{ grains['osmajorrelease'][0] }}/$basearch/
    - gpgcheck: 1
    - gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX
    - require:
      - file: bareos_repo_gpg_file

bareos_non_supported_repo:
  pkgrepo.managed:
    - name: bareos_non_supported
    - humanname: BareOS Official Repository non-supported - $basearch
    - baseurl: http://repo.bareos.com/non-supported/rhel/{{ grains['osmajorrelease'][0] }}/$basearch/
    - gpgcheck: 1
    - gpgkey: file:///etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX
    - require:
      - file: bareos_repo_gpg_file

bareos_repo_gpg_file:
  file.managed:
    - name: /etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX
    - source: {{ files_switch('bareos',
                              ['/tmp/bareos-official-repo.gpg']) }}
{%- else %}
bareos_repo: {}
{%- endif %}
