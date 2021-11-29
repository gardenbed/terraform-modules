Host bastion
  HostName ${dns_name}
  User admin
  IdentityFile ${private_key}
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel error
