---
- name: Example archive deployed and permissions set
  hosts: win1.example.com
  tasks:
    - name: Temp directory created
      win_file:
        path: C:\Temp\DO417\payload
        state: directory

    - name: Zip archive is copied
      win_copy:
        src: files/example.zip
        dest: C:\Temp\DO417\example.zip

    - name: Zip archive is unzipped
      win_unzip:
        src: C:\Temp\DO417\example.zip
        dest: C:\Temp\DO417\payload
        delete_archive: yes

    - name: Payload is copied to the Desktop
      win_robocopy:
        src: C:\Temp\DO417\payload
        dest: C:\Users\devops\Desktop\example

    - name: Shortcut created
      win_shortcut:
        src: '%UserProfile%\Desktop\example\example.txt'
        dest: '%UserProfile%\Desktop\example-txt.lnk'

    - name: Example.txt write permissions are denied
      win_acl:
        path: C:\Users\devops\Desktop\example\example.txt
        user: devops
        rights: Write
        type: deny
        state: present

    - name: Not-runnable.ps1 execution is denied
      win_acl:
        path: C:\Users\devops\Desktop\example\not-runnable.ps1
        user: devops
        rights: ReadAndExecute
        type: deny
        state: present

    - name: Runnable.ps1 is owned by SYSTEM
      win_owner:
        path: C:\Users\devops\Desktop\example\runnable.ps1
        user: SYSTEM
