#!/bin/bash
SQL_FILE="add_users.sql"

cat > $SQL_FILE << 'EOF'
CREATE TABLE IF NOT EXISTS system_users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL,
    uid INTEGER NOT NULL,
    gid INTEGER NOT NULL,
    home_directory VARCHAR(255),
    shell VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Iniciar transacción para insertar usuarios
BEGIN TRANSACTION;
EOF

getent passwd | grep "/bin/bash$" | while IFS=: read -r username password uid gid gecos home shell; do
    username_escaped=$(echo "$username" | sed "s/'/''/g")
    home_escaped=$(echo "$home" | sed "s/'/''/g")
    shell_escaped=$(echo "$shell" | sed "s/'/''/g")
    gecos_escaped=$(echo "$gecos" | sed "s/'/''/g")

    echo "INSERT INTO system_users (username, uid, gid, home_directory, shell) VALUES ('$username_escaped', $uid, $gid, '$home_escaped', '$shell_escaped');" >> $SQL_FILE
done

echo "COMMIT;" >> $SQL_FILE

echo "Script SQL generado: $SQL_FILE"
echo "Para ejecutarlo en SQLite: sqlite3 usuarios.db < $SQL_FILE"
echo "Para ejecutarlo en MySQL: mysql -u usuario -p base_datos < $SQL_FILE"
