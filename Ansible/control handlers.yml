---
- name: Control review lab
  hosts: all

  tasks:

    - name: Web server feature is installed on win1
      win_feature:
        name: Web-Server
        state: present
      notify: Machine is restarted
      when: "'win1' in inventory_hostname"

    - name: Web server is started on win1
      win_service:
        name: W3Svc
        state: started
      when: "'win1' in inventory_hostname"

    - name: Website index.html created on win1
      win_copy:
        content: "win1.example.com"
        dest: C:\Inetpub\wwwroot\index.html
      when: "'win1' in inventory_hostname"

    - name: Web security features are installed on win1
      win_feature:
        name: "{{ item }}"
        state: present
      loop:
        - Web-Security
        - Web-Basic-Auth
        - Web-IP-Security
      notify: Machine is restarted
      when: "'win1' in inventory_hostname"

    - name: Security updates applied on win2
      win_updates:
        category_names: SecurityUpdates
      notify: Machine is restarted
      when: "'win2' in inventory_hostname"


  handlers:

    - name: Machine is restarted
      win_reboot:
