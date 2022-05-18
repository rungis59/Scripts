---
- name: Manage page files
  hosts: Windows

  tasks:
    - name: Obtain page file information
      win_pagefile:
      register: orig_pagefile_info

    - name: Show original page file information
      debug:
        var: orig_pagefile_info

    - name: Manage page files on virtual machines
      win_pagefile:
        remove_all: "{{ pagefile['remove'] }}"
        automatic: "{{ pagefile['auto'] }}"
      register: new_pagefile_info

    - name: Show new page file information
      debug:
        var: new_pagefile_info

    - name: Show current memory information
      debug:
        var: ansible_facts['memtotal_mb']
