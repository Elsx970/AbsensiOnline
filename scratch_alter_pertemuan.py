import paramiko
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('165.22.241.192', 22, 'root', 'anime008@Asd')
sql = """
ALTER TABLE lokasi ADD COLUMN pertemuan INT DEFAULT 1 AFTER nama_lokasi;
"""
stdin, stdout, stderr = ssh.exec_command(f'mysql absensi_db -e "{sql}"')
print(stdout.read().decode())
print(stderr.read().decode())
