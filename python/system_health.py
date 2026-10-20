#!/usr/bin/env python3

import json
import os
import platform
import shutil
import socket
import subprocess
import sys
import time

DISK_THRESHOLD = 80
MEMORY_THRESHOLD = 90
CPU_THRESHOLD = 80
CRITICAL_SERVICES = ["chronyd", "prometheus", "node_exporter"]


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


def get_cpu_usage(interval=1):
    with open("/proc/stat", encoding="utf-8") as file:
        values1 = list(map(int, file.readline().split()[1:]))

    time.sleep(interval)

    with open("/proc/stat", encoding="utf-8") as file:
        values2 = list(map(int, file.readline().split()[1:]))

    idle1 = values1[3] + values1[4]
    idle2 = values2[3] + values2[4]
    total1 = sum(values1)
    total2 = sum(values2)

    total_delta = total2 - total1
    idle_delta = idle2 - idle1

    if total_delta <= 0:
        return 0.0

    return round((1 - idle_delta / total_delta) * 100, 1)


def check_service(service):
    result = subprocess.run(
        ["/usr/bin/systemctl", "is-active", "--quiet", service],
        check=False,
        capture_output=True,
        text=True,
        timeout=5,
    )
    return result.returncode == 0


def main():
    disk = shutil.disk_usage("/")
    disk_used_percent = round(disk.used / disk.total * 100, 1)
    memory = get_memory_usage()
    cpu_used_percent = get_cpu_usage()

    checks = {
        "cpu": {
            "used_percent": cpu_used_percent,
            "threshold_percent": CPU_THRESHOLD,
            "status": "CRITICAL"
            if cpu_used_percent >= CPU_THRESHOLD else "OK",
        },
        "disk": {
            "used_percent": disk_used_percent,
            "threshold_percent": DISK_THRESHOLD,
            "status": "CRITICAL"
            if disk_used_percent >= DISK_THRESHOLD else "OK",
        },
        "memory": {
            **memory,
            "threshold_percent": MEMORY_THRESHOLD,
            "status": "CRITICAL"
            if memory["used_percent"] >= MEMORY_THRESHOLD else "OK",
        },
        "services": {
            service: {
                "status": "OK" if check_service(service) else "CRITICAL"
            }
            for service in CRITICAL_SERVICES
        },
    }

    overall_status = (
        "CRITICAL"
        if any(
            item["status"] == "CRITICAL"
            for name, item in checks.items()
            if name != "services"
        )
        or any(
            service["status"] == "CRITICAL"
            for service in checks["services"].values()
        )
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
