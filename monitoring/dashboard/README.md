# CloudOps SRE Lab — Infrastructure Dashboard

Lightweight infrastructure monitoring dashboard built with HTML, CSS,
JavaScript, Prometheus and Node Exporter.

## Features

- CPU utilization monitoring
- Memory utilization monitoring
- Root filesystem free space
- Rolling 15-minute browser-side history
- OK, WARNING and CRITICAL visual states
- Automatic refresh every 15 seconds

## Architecture

EC2 instance (Amazon Linux 2023)
- Node Exporter: 127.0.0.1:9100
- Prometheus: 127.0.0.1:9090
- Dashboard: served locally on the RHEL management host
- SSH tunnels provide private access

No monitoring ports are exposed publicly.

## Alert thresholds

| Metric | Warning | Critical |
|---|---:|---:|
| CPU utilization | >= 70% | >= 90% |
| Memory utilization | >= 80% | >= 90% |
| Root disk available | <= 2 GiB | <= 1 GiB |

## Limitations

- History is stored in browser memory and is lost when the page is reloaded.
- Alerts are displayed in the browser; they do not send external notifications.
- The dashboard requires an active SSH tunnel to the Prometheus API.
