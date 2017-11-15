# ##binname## systemd target

[Unit]
Description=##projname##
Documentation=man:##binname##
Documentation=##gh_url##
After=network.target httpd.service squid.service nfs-server.service mysqld.service named.service postfix.service
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/##binname##
TimeoutStopSec=10
KillMode=mixed
KillSignal=SIGTERM

User=##binname##
Restart=always
RestartSec=2s
LimitNOFILE=65536

WorkingDirectory=/var/lib/##binname##
WatchdogSec=30s

# Hardening
NoNewPrivileges=yes
CapabilityBoundingSet=
# Configure system call filtering
#SystemCallFilter=~@cpu-emulation @debug @keyring @module @mount @obsolete @raw-io @resources @clock @debug @keyring @mount @privileged @reboot @setuid @swap @memlock

ProtectSystem=strict
PrivateDevices=yes
PrivateUsers=yes
PrivateTmp=yes
ProtectHome=yes
ProtectKernelModules=true
ProtectKernelTunables=yes

StandardOutput=syslog+console
StandardError=syslog+console

ReadWriteDirectories=-/proc/self
ReadWriteDirectories=-/var/run
ReadWriteDirectories=-/var/lib/##binname##


[Install]
WantedBy=multi-user.target
