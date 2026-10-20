# System Health Automation

## Overview

A Python health-check script runs automatically on the RHEL server
using a systemd oneshot service and a systemd timer.

## Architecture

- Python: collects disk and memory usage.
- systemd service: executes the health check.
- systemd timer: schedules executions every five minutes.
- journald: stores execution output and errors.
- unittest: validates healthy and critical scenarios.

## Thresholds

| Resource | Threshold | Critical condition |
|----------|-----------|--------------------|
| Disk     | 80%       | Usage >= 80%       |
| Memory   | 90%       | Usage >= 90%       |

## Exit Codes

- 0: health check completed successfully.
- 1: at least one resource is critical.

## Useful Commands

Check the timer:

    systemctl status system-health.timer

List scheduled executions:

    systemctl list-timers system-health.timer

Run the check manually:

    sudo systemctl start system-health.service

Inspect logs:

    sudo journalctl -u system-health.service -n 50 --no-pager

Run unit tests:

    python3 -m unittest discover -s python -v

## Validation

The three unit tests pass:
- Healthy system returns exit code 0.
- Critical disk usage returns exit code 1.
- Critical memory usage returns exit code 1.

A separate controlled systemd failure test confirmed that exit code 1
is recorded as Result=exit-code and ExecMainStatus=1.

## Limitations

The timer runs checks and records results; it does not send notifications.
External alerting and automated remediation are not configured.
