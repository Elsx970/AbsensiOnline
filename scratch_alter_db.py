import paramiko
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
ssh.connect('165.22.241.192', 22, 'root', 'anime008@Asd')
sql = """
ALTER TABLE lokasi 
ADD COLUMN tanggal DATE NULL AFTER radius,
ADD COLUMN jam_mulai TIME NULL AFTER tanggal,
ADD COLUMN jam_selesai TIME NULL AFTER jam_mulai;
"""
stdin, stdout, stderr = ssh.exec_command(f'mysql absensi_db -e "{sql}"')
print(stdout.read().decode())
print(stderr.read().decode())
