Host bastion
  HostName ${host}
  User admin
  IdentityFile ${private_key}
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel error
