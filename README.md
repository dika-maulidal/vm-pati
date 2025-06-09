## Cheat Sheet Linux User Management

| Perintah                            | Fungsi                                                                 |
|-------------------------------------|------------------------------------------------------------------------|
| `sudo apt install openssh-server`  | Install SSH server                                                     |
| `sudo service ssh start`           | Menjalankan SSH service                                                |
| `getent group [nama_group]`        | Melihat anggota dari grup tertentu                                     |
| `groups [nama_user]`               | Melihat grup yang dimiliki user tertentu                               |
| `sudo chage -l [nama_user]`        | Mengecek status expired/tanggal kadaluarsa password user              |
| `sudo passwd [nama_user]`          | Mengganti password user                                                |
| `su - [nama_user]`                 | Login sebagai user lain                                                |

---

## Struktur Direktori
```
/srv/projects/ [setup.sh]
├── boleh-baca.txt           (Anggota 3)
├── dev1.txt                 (Dev)
├── dev2.txt                 (Dev)
├── secret1.txt              (Dev)
├── secret2.txt              (Dev)
├── umum.txt                 (Dev)
├── subdir1/
│   └── subfile1.txt         (Dev)
├── subdir2/
│   ├── boleh-baca-2.txt     (Anggota 3)
│   └── subfile2.txt         (Dev)
└── public_for_anggota3/     (Anggota 3 full access)
    ├── file1.txt
    └── file2.txt
```

## Log & Monitoring

| File / Perintah                     | Fungsi                                      |
|------------------------------------|---------------------------------------------|
| `sudo cat /var/log/sysmon.log`     | Monitoring sistem                           |
| `sudo cat /var/log/audit_summary.log` | Log audit ringkasan aktivitas sistem     |
| `sudo getent passwd`               | Melihat isi file `/etc/passwd`              |
| `sudo getent shadow`               | Melihat isi file `/etc/shadow`              |

---

# Pengujian DNS
```
nslookup dev.corpX.local
nslookup git.corpX.local
nslookup mail.corpX.local

dig dev.corpX.local
dig git.corpX.local

host mail.corpX.local
```