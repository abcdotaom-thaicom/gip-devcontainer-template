#!/bin/bash
set -euo pipefail

export VENV=${VENV:-/opt/venv}
export SNAP_HOME=${SNAP_HOME:-/opt/snap}
export JAVA_HOME=${JAVA_HOME:-/usr/lib/jvm/java-17-openjdk-amd64}
export PATH="${VENV}/bin:${PATH}"
export PYTHONPATH="${VENV}/lib/python3.10/site-packages:${PYTHONPATH:-}"

# 1) เตรียม snappy ให้ ROOT เสมอ (devcontainer ใช้ root)
if [ ! -f "/root/.snap/snap-python/snappy/__init__.py" ]; then
  echo "[entrypoint] snappy-conf for HOME=/root"
  HOME=/root "${SNAP_HOME}/bin/snappy-conf" "${VENV}/bin/python" || true
fi

# 2) ผูก .pth ให้ Python มองเห็น snappy (ชี้ไปที่ /root/.snap)
if [ -d "/root/.snap/snap-python" ]; then
  echo "/root/.snap/snap-python" > "${VENV}/lib/python3.10/site-packages/zz_snappy.pth"
fi

# (ออปชัน) 3) ถ้ามี USER จริงใน env และโฮมอยู่ ให้เตรียมล่วงหน้าให้เขาด้วย (แต่ยังคงรันเป็น root)
if [ -n "${USER:-}" ] && [ -d "/home/${USER:-}" ]; then
  USER_HOME="/home/${USER}"
  if [ ! -f "${USER_HOME}/.snap/snap-python/snappy/__init__.py" ]; then
    echo "[entrypoint] pre-config snappy for ${USER} at HOME=${USER_HOME}"
    # สร้างไฟล์ลงโฮม user ด้วยสิทธิ์ root (ให้เขามีพร้อมเวลา exec เป็น user)
    HOME="${USER_HOME}" "${SNAP_HOME}/bin/snappy-conf" "${VENV}/bin/python" || true
    chown -R "${USER}:${USER}" "${USER_HOME}/.snap" || true
  fi
fi

# 4) sanity log (non-fatal)
python - <<'PY'
try:
    import sys
    from osgeo import gdal
    print(f"[sanity] Python:", sys.version.split()[0])
    print(f"[sanity] GDAL (C):", gdal.VersionInfo())
    try:
        from snappy import ProductIO
        print("[sanity] snappy OK:", ProductIO)
    except Exception as e:
        print("[WARN] snappy import failed:", repr(e))
except Exception as e:
    print("[WARN] GDAL/snappy sanity failed:", repr(e))
PY

# 5) hand over to CMD (root)
exec "$@"
