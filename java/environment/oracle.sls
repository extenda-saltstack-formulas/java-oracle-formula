{% set java_version = pillar.java.environment.get('version', '7') %}
{% set java_release = pillar.java.environment.get('release', 'latest') %}
{% set java_build = pillar.java.environment.get('build', 'latest') %}
{% set java_home = pillar.java.environment.get('java_home', '/opt/java')%}

{%- set tmp_dir = '/tmp/java' %}
{%- set java_real_home = '/opt' %}
{%- set source_url = 'https://github.com/frekele/oracle-java/releases/download/' + java_version + 'u' + java_release + '-b' + java_build + '/jdk-' + java_version + 'u' + java_release + '-linux-x64.tar.gz' %}
{%- set oracle_file_name = 'jdk-' + java_version + 'u' + java_release + '-linux-x64.tar.gz' %}
{%- set java_dir = java_real_home + '/jdk1.' + java_version + '.0_' + java_release %}

{{ tmp_dir }}:
  file.directory:
  - user: root
  - group: root
  - mode: 755
  - makedirs: True

{{ oracle_file_name }}:
  cmd.run:
    - name: "curl -L {{ source_url }} -o {{ tmp_dir }}/{{ oracle_file_name }}"
    - creates: "{{ tmp_dir }}/{{ oracle_file_name }}"
    - require:
      - file: {{ tmp_dir }}

unpack_java_source:
  archive.extracted:
    - name: {{ java_real_home }}
    - source: "{{ tmp_dir }}/{{ oracle_file_name }}"
    - require:
      - cmd: {{ oracle_file_name }}

java_install:
  alternatives.install:
    - name: java
    - link: /usr/bin/java
    - path: "{{ java_dir }}/bin/java"
    - priority: 1

java_alternatives_set:
  alternatives.set:
    - name: java
    - path: "{{ java_dir }}/bin/java"

set_java_home:
  file.append:
    - name: /etc/profile.d/java_home.sh
    - text: export JAVA_HOME={{ java_dir }}
