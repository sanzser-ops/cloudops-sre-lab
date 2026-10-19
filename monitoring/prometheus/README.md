# Prometheus Monitoring and Alerting

## Overview

Prometheus collects Linux host metrics from Node Exporter and evaluates
alerting rules for CPU usage, memory usage, and root filesystem capacity.

## Architecture

- Prometheus: collects metrics and evaluates alerting rules.
- Node Exporter: exposes Linux host metrics.
- Alerting rules: detect sustained resource pressure.
- Dashboard: displays current metrics and active Prometheus alerts.

## Alert Rules

| Alert | Severity | Condition | Duration |
|---|---|---|---|
| HighCPUUsage | Warning | CPU usage > 70% | 5 minutes |
| HighMemoryUsage | Warning | Memory usage > 80% | 5 minutes |
| CriticalMemoryUsage | Critical | Memory usage > 90% | 2 minutes |
| LowRootDiskSpace | Warning | Root filesystem free space < 2 GiB | 5 minutes |
| CriticalRootDiskSpace | Critical | Root filesystem free space < 1 GiB | 2 minutes |

The `for` duration requires the condition to persist before the alert fires.

## File Structure

- `README.md`: documentation.
- `rules/host-alerts.yml`: host alerting rules.

## Validate the Rules

Run on the Prometheus host:

    sudo /usr/local/bin/promtool check rules /etc/prometheus/rules/host-alerts.yml

Validate the full configuration:

    sudo /usr/local/bin/promtool check config /etc/prometheus/prometheus.yml

Restart Prometheus after changing rules:

    sudo systemctl restart prometheus
    sudo systemctl status prometheus --no-pager

## Inspect Alerts

List loaded rules:

    curl -s http://127.0.0.1:9090/api/v1/rules

Check pending and firing alerts:

    curl -s http://127.0.0.1:9090/api/v1/alerts

## Notifications and Limitations

The dashboard displays current metrics and active Prometheus alerts.
Alertmanager and external notifications such as email or chat are not
configured yet.

## Threshold Guidance

These thresholds are initial lab defaults, not universal production
standards. Tune them to the workload, baseline metrics, and service
objectives before using similar rules in production.
