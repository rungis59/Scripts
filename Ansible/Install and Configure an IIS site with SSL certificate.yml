- name: Install and Configure an IIS site with SSL certificate
  hosts: win1.example.com

  tasks:
    - name: IIS and .Net 4.5 are installed
      win_feature:
        name:
          - Web-Server
          - NET-Framework-Core
          - Web-Asp-Net45
        include_management_tools: True
        state: present

    - name: Logs directory is created
      win_file:
        path: C:\sites\logs
        state: directory

    - name: Site directory is created
      win_file:
        path: C:\sites\windows
        state: directory

    - name: Index page for site is installed
      win_copy:
        src: files/index.html
        dest: C:\sites\windows\index.html

    - name: Previous IIS site is removed
      win_iis_website:
        name: DO417-variables
        state: absent

    - name: IIS site is created
      win_iis_website:
        name: DO417-windows
        state: started
        port: 8080
        ip: "*"
        hostname: "{{ inventory_hostname }}"
        application_pool: DefaultAppPool
        physical_path: C:\sites\windows
        parameters: logfile.directory:C:\sites\logs

    - name: Firewall rule is enabled
      win_firewall_rule:
        name: HTTP
        localport: "{{ item }}"
        action: allow
        direction: in
        protocol: tcp
        state: present
        enabled: yes
      loop:
        - 8080
        - 8888

    - name: IIS binding is retrieved
      win_shell: Get-IISSiteBinding "DO417-windows"
      changed_when: false
      register: iis_ssl_stat

    - name: SSL is queried
      win_shell: dir cert:\localmachine\my\
      ignore_errors: True
      changed_when: False
      register: ssl_status

    - name: SSL certificate is generated
      win_shell: >
        New-SelfSignedCertificate
        -DnsName "{{ inventory_hostname }}"
        -CertStoreLocation cert:\LocalMachine\My
        -KeyExportPolicy Exportable
      when: "'win1' not in ssl_status.stdout"

    - name: IIS site is configured
      block:
        - name: Certificate thumbprint is retrieved
          win_shell: >
            (Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object
            {$_.Subject -match "{{ inventory_hostname }}"}).Thumbprint;
          register: cert_thumbprint

        - name: SSL binding is added
          win_iis_webbinding:
            name: DO417-windows
            protocol: https
            port: 8888
            ip: "*"
            certificate_hash: "{{ cert_thumbprint.stdout | trim }}"
            state: present

        - name: IIS site is restarted
          win_iis_website:
            name: DO417-windows
            state: started

      when: "'8888' not in iis_ssl_stat.stdout"
