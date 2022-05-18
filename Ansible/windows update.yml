- name: Manage updates on systems
  hosts: all
  vars:
    log_file: C:\Windows\Temp\ansible_available_updates.txt
    KB: 'KB4465065'
    # Visit https://gitlab.example.com/profile/personal_access_tokens to
    # generate a new token. Make sure to give the token API access.
    #
    # You can pass the token to this variable to into the "Variables" frame in
    # Ansible Tower.
    access_token: ""

  tasks:
    - name: Microsoft update servers are queried
      win_updates:
        category_names: SecurityUpdates
        state: searched
        log_path: "{{ log_file }}"

    - name: Available security updates are captured
      win_shell: "type {{ log_file }}"
      register: file_output

    - name: Available updates found
      debug:
        msg: "Available updates found!"
      when: "'Adding update' in file_output.stdout"

    - name: MSU package is retrieved on hosts
      win_uri:
        url: >
          https://gitlab.example.com/student/updates/raw/master/files/{{ KB }}.msu
        dest: C:\Windows\Temp\{{ KB }}.msu
        validate_certs: no
        force_basic_auth: true
        method: GET
        headers:
          PRIVATE-TOKEN: "{{ access_token }}"

    - name: MSU package is installed
      win_hotfix:
        hotfix_kb: "{{ KB }}"
        source: C:\Windows\Temp\{{ KB }}.msu
        state: present

    - name: Security updates are applied
      win_updates:
        category_name:
          - Updates
        whitelist:
          - KB4494174
          - KB4346084
      register: updates_status

    - name: Server is rebooted
      win_reboot:
      when: updates_status.reboot_required

- name: Install packages on systems
  hosts: all
  vars:
    packages:
      - Putty
      - Wireshark

  tasks:
    - name: Chocolatey is installed
      win_chocolatey:
        name: chocolatey
        state: present

    - name: Packages are installed
      win_chocolatey:
        name: "{{ packages }}"
        state: present
        pinned: true
      register: install_result

    - name: Server is rebooted
      win_reboot:
      when: install_result.changed and install_result.rc == 3010
