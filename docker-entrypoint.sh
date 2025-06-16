#!/bin/bash

set -e

USERNAME=${USER:-vscode}
USER_UID=${UID:-1000}
USER_GID=${GID:-1000}

echo "🔧 Creating user $USERNAME (UID=$USER_UID, GID=$USER_GID)"
if ! getent group "$USER_GID" >/dev/null; then
    groupadd -g "$USER_GID" "$USERNAME"
fi
if ! id "$USERNAME" >/dev/null 2>&1; then
    useradd -m -u "$USER_UID" -g "$USER_GID" -s /bin/bash "$USERNAME"
fi

# 🔁 Switch to new user
exec su - "$USERNAME"
