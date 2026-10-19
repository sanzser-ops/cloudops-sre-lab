#!/usr/bin/env python3

import json
import os
import platform
import shutil
import socket
import sys

DISK_THRESHOLD = 80
MEMORY_THRESHOLD = 90

def get_memory_usage():
    values = {}

    with open("/proc/meminfo", encoding="utf-8") as file:
        for line in file:
            key, value = line.split(":", 1)
            values[key] = int(value.strip().split()[0])

    total = values["MemTotal"]
    available = values["MemAvailable"]

    return {
        "total_mib": round(total / 1024),
        "available_mib": round(available / 1024),
        "used_percent": round((total - available) / total * 100, 1),
    }

def main():
    disk = shutil.disk_usage("/")
    disk_used_percent = round(disk.used / disk.total * 100, 1)
    memory = get_memory_usage()

    checks = {
        "disk": {
            "used_percent": disk_used_percent,
            "threshold_percent": DISK_THRESHOLD,
            "status": "CRITICAL" if disk_used_percent >= DISK_THRESHOLD else "OK",
        },
        "memory": {
            **memory,
            "threshold_percent": MEMORY_THRESHOLD,
            "status": "CRITICAL" if memory["used_percent"] >= MEMORY_THRESHOLD else "OK",
        },
    }

    overall_status = (
        "CRITICAL"
        if any(check["status"] == "CRITICAL" for check in checks.values())
        else "OK"
    )

    report = {
        "hostname": socket.gethostname(),
        "os": platform.platform(),
        "python_version": platform.python_version(),
        "cpu_cores": os.cpu_count(),
        "status": overall_status,
        "checks": checks,
    }

    print(json.dumps(report, indent=2))
    return 1 if overall_status == "CRITICAL" else 0

if __name__ == "__main__":
    sys.exit(main())
