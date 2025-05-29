#!/bin/bash

# Periksa apakah dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Jalankan skrip ini sebagai root (gunakan sudo)."
    exit 1
fi

# 1. Buat direktori /srv/projects
mkdir -p /srv/projects
echo "[✓] Direktori /srv/projects dibuat."

# 2. Pastikan grup developer ada
groupadd -f developer
echo "[✓] Grup developer tersedia."

# 3. Ubah kepemilikan direktori ke grup developer
chown root:developer /srv/projects
chmod 770 /srv/projects
echo "[✓] Kepemilikan dan izin direktori diatur."

# 4. Buat file realistis untuk proyek
# readme.txt (dibaca guest)
cat << EOF > /srv/projects/readme.txt
Task Manager Project
====================
This project is a simple task management tool.
To run: Configure settings in config.txt and execute task_manager.txt logic.
See project_spec.txt for details.
EOF

# project_spec.txt (dibaca guest)
cat << EOF > /srv/projects/project_spec.txt
Project Specification: Task Manager
==================================
Features:
- Create and delete tasks
- Assign tasks to users
- Set due dates
Requirements:
- Python 3.9+
- SQLite database
EOF

# dev_notes.txt (hanya developer)
cat << EOF > /srv/projects/dev_notes.txt
Developer Notes
=================
- 2023-11-01: Added task creation logic
- TODO: Implement user authentication
- Bug: Fix database connection timeout
EOF

# task_manager.txt (hanya developer)
cat << EOF > /srv/projects/task_manager.txt
Task Manager Logic
==================
Pseudocode:
1. Connect to SQLite DB
2. Create task (title, assignee, due_date)
3. Save to tasks table
4. Display task list
EOF

# config.txt (hanya developer)
cat << EOF > /srv/projects/config.txt
[task_manager]
db_path=/var/db/tasks.db
max_tasks=100
log_level=debug
EOF

# index.html (dibaca developer)
cat << EOF > /srv/projects/index.html
<!DOCTYPE html>
<html>
<head>
    <title>Task Manager</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
    <h1>Welcome to Task Manager</h1>
    <p>A simple tool to manage your tasks.</p>
</body>
</html>
EOF

# styles.css (hanya developer)
cat << EOF > /srv/projects/styles.css
body {
    font-family: Arial, sans-serif;
    margin: 20px;
}
h1 {
    color: #333;
}
EOF

# Tambahan file license.txt (dibaca guest)
cat << EOF > /srv/projects/license.txt
MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy...
EOF

# Tambahan file help.txt (dibaca guest)
cat << EOF > /srv/projects/help.txt
Help File - Task Manager

Usage:
1. Open application
2. Create a task
3. Assign it and set deadline

For more help, contact admin.
EOF

echo "[✓] File proyek dibuat."

# 5. Atur kepemilikan dan izin file
chown -R root:developer /srv/projects
chmod -R 770 /srv/projects
echo "[✓] Kepemilikan dan izin file diatur."

# 6. Pastikan ACL diaktifkan
apt-get update
apt-get install -y acl
echo "[✓] Paket ACL diinstal."

for user in guest1 guest2; do
    setfacl -m u:$user:rx /srv/projects
done

# 7. Atur ACL untuk guest1 dan guest2: hanya baca readme.txt dan index.html
for user in guest1 guest2; do
    setfacl -m u:$user:r /srv/projects/readme.txt
    setfacl -m u:$user:r /srv/projects/license.txt
    setfacl -m u:$user:r /srv/projects/help.txt
    echo "[✓] ACL untuk $user diatur."
done

# 8. Pastikan nologinuser tidak memiliki akses
setfacl -m u:nologinuser:- /srv/projects
echo "[✓] ACL untuk nologinuser diatur."

# 9. Tampilkan status untuk verifikasi
echo "[✓] Status izin direktori:"
ls -ld /srv/projects
echo "[✓] Status izin file:"
ls -l /srv/projects
echo "[✓] Status ACL direktori:"
getfacl /srv/projects
echo "[✓] Status ACL readme.txt:"
getfacl /srv/projects/readme.txt
echo "[✓] Status ACL index.html:"
getfacl /srv/projects/index.html

echo "[✓] Pengaturan folder sharing selesai."