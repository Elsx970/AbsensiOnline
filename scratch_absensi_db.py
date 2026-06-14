import paramiko
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('165.22.241.192', 22, 'root', 'anime008@Asd')
stdin, stdout, stderr = ssh.exec_command('mysql absensi_db -e "DESCRIBE absensi;"')
print(stdout.read().decode())
