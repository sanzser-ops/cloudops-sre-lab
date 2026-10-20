# System Health Automation

## Overview

A Python health-check script runs automatically on the RHEL server
using a systemd oneshot service and a systemd timer every five minutes.

## Architecture

- Python: collects CPU, disk and memory usage and checks critical services.
- systemd service: executes the health check.
- systemd timer: schedules executions every five minutes.
- journald: stores execution output and errors.
- unittest: validates healthy and critical scenarios.

## Thresholds

| Check | Threshold | Critical condition |
|-------|-----------|--------------------|
| CPU | 80% | Usage >= 80% |
| Disk | 80% | Usage >= 80% |
| Memory | 90% | Usage >= 90% |
| chronyd | Active | Service is not active |
| prometheus | Active | Service is not active |
| node_exporter | Active | Service is not active |

CPU usage is calculated from two samples of /proc/stat.
Memory usage is calculated using MemAvailable from /proc/meminfo.
Disk usage is measured for the root filesystem.

## Output and Exit Codes

The script prints a JSON report containing host information,
resource usage, individual check statuses and the overall status.

- 0: all checks are OK.
- 1: at least one resource or service is critical.

## Useful Commands

Check the timer:

    systemctl status system-health.timer

List scheduled executions:

    systemctl list-timers system-health.timer

Run the check manually:

    python3 python/system_health.py

Run the systemd service:

    sudo systemctl start system-health.service

Inspect logs:

    sudo journalctl -u system-health.service -n 50 --no-pager

Run unit tests:

    python3 -m unittest discover -s python -v

## Validation

Five unit tests pass:
- Healthy system returns exit code 0.
- Critical disk usage returns exit code 1.
- Critical memory usage returns exit code 1.
- Critical CPU usage returns exit code 1.
- An inactive critical service returns exit code 1.

A real execution returned status OK and exit code 0.
The systemd timer was verified to run every five minutes,
and journald confirmed a successful execution.

A separate controlled systemd failure test confirmed that exit code 1
is recorded as Result=exit-code and ExecMainStatus=1.

## Limitations

The timer runs checks and records results; it does not send notifications.
External alerting and automated remediation are not configured.
Service checks verify whether systemd reports each service as active;
they do not verify application-level health.
