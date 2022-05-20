---
- name: Install packages
  hosts: win1.example.com

  tasks:
    - name: Handle package installation
      block:
        - name: Copy package to target host
          win_copy:
            src: files/7z.exe
            dest: C:\Users\student\Downloads\

        - name: Install package
          win_package:
            path: C:\Users\student\Downloads\7z.exe
            product_id: 7-Zip
            arguments: /S
            state: present

      rescue:
        - debug:
            msg: "Sorry, it didn't work out :("

        - name: Attempt uninstall
          win_package:
            path: C:\Program Files\7-Zip\Uninstall.exe
            product_id: 7-Zip
            arguments: /S
            state: absent
          ignore_errors: yes

      always:
        - name: Clean up installation package
          win_file:
            path: C:\Users\student\Downloads\7z.exe
            state: absent
