sh <<SCRIPT

  # add GPG key
  rpm --import http://packages.treasure-data.com/redhat/RPM-GPG-KEY-td-agent

  # add treasure data repository to yum
  cat >/etc/yum.repos.d/td.repo <<'EOF';
[treasuredata]
name=TreasureData
baseurl=http://packages.treasure-data.com/redhat/\$basearch
gpgcheck=1
gpgkey=http://packages.treasure-data.com/redhat/RPM-GPG-KEY-td-agent
EOF

  # update your sources
  #yes n | yum update

  # install the toolbelt
  yes | yum install -y td-agent

SCRIPT
