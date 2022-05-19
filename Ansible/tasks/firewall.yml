---
  - name: Firewall rule is enabled
    win_firewall_rule:
      name: HTTP
      localport: "{{ iis_site_port }}"
      action: allow
      direction: in
      protocol: tcp
      state: present
      enabled: yes