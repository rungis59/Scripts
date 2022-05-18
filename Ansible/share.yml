---
- name: Backup directory is shared on win1
  hosts: win1.example.com
  tasks:
    - name: Backup directory exists
      win_file:
        path: C:\shares\backup
        state: directory
    - name: Share is present
      win_share:
        name: backup
        description: Critical backup files
        path: C:\shares\backup
        full: devops
        state: present

- name: File is backed up from win2
  hosts: win2.example.com
  tasks:
    - name: Example file created for backup
      win_copy:
        content: Hello. This is an example.
        dest: C:\Users\devops\Documents\logs.txt
    - name: Logs copied to backup share
      win_copy:
        src: C:\Users\devops\Documents\logs.txt
        dest: \\WIN1\backup\logs.txt
        remote_src: yes
