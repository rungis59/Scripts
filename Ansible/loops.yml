---
- name: IIS and debugging tools installed
  hosts: win1.example.com
  tasks:
    - name: IIS is installed
      win_feature:
        name: Web-Server
        state: present

    - name: Disk facts are gathered
      win_disk_facts:

    - name: Debug tools are installed
      win_feature:
        name: "{{ item }}"
        state: present
      loop:
        - Web-Custom-Logging
        - Web-Log-Libraries
        - Web-Request-Monitor
        - Web-Http-Tracing
        - Web-Mgmt-Tools
      when: size_remaining >= minimum_bytes
      vars:
        minimum_bytes: "{{ '10 GB' | human_to_bytes }}"
        # For simplicity, we only select the space available from the first volume of the
        # first partition of the first disk on our classroom managed host.
        first_volume: "{{ ansible_facts.disks[0].partitions[0].volumes[0] }}"
        size_remaining: "{{ first_volume.size_remaining }}"

    - name: Server is rebooted
      win_reboot:
