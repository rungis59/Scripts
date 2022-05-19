---
  - name: Logs directory is created
    win_file:
      path: C:\sites\logs
      state: directory

  - name: Site directory is created
    win_file:
      path: "{{ iis_site_path }}"
      state: directory

  - name: Index page for site is installed
    win_copy:
      src: 'files/index.html'
      dest: '{{ iis_site_path }}\index.html'

  - name: IIS site is created
    win_iis_website:
      name: "{{ iis_site_name }}"
      state: started
      port: "{{ iis_site_port }}"
      ip: "*"
      hostname: "{{ inventory_hostname }}"
      application_pool: DefaultAppPool
      physical_path: "{{ iis_site_path }}"
      parameters: logfile.directory:C:\sites\logs