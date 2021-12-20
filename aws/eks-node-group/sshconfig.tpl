Host bastion
  HostName ${bastion_address}
  User admin
  IdentityFile ${bastion_private_key}
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel error
Host ${node_group_cidr_wildcard}
  User ec2-user
  IdentityFile ${node_group_private_key}
  ProxyJump bastion
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
  LogLevel error
