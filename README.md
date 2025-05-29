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
/srv/projects/
├── config.txt           (Dev)
├── dev_notes.txt        (Dev)
├── help.txt             (Guest)
├── index.html           (Dev)
├── license.txt          (Guest)
├── project_spec.txt     (Dev)
├── readme.txt           (Guest)
├── styles.css           (Dev)
├── task_manager.txt     (Dev)
├── touch_admin.txt
└── touch_dev.txt
```
---

## Log & Monitoring

| File / Perintah                     | Fungsi                                      |
|------------------------------------|---------------------------------------------|
| `sudo cat /var/log/sysmon.log`     | Monitoring sistem                           |
| `sudo cat /var/log/audit_summary.log` | Log audit ringkasan aktivitas sistem     |
| `sudo getent passwd`               | Melihat isi file `/etc/passwd`              |
| `sudo getent shadow`               | Melihat isi file `/etc/shadow`              |

---
