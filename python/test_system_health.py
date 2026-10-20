import unittest
from unittest.mock import patch

import system_health


class SystemHealthTests(unittest.TestCase):

    def setUp(self):
        self.disk = type(
            "Disk", (), {"total": 1000, "used": 200, "free": 800}
        )()
        self.memory = {
            "total_mib": 1000,
            "available_mib": 700,
            "used_percent": 30.0,
        }

    @patch("system_health.check_service", return_value=True)
    @patch("system_health.get_cpu_usage", return_value=20.0)
    @patch("system_health.get_memory_usage")
    @patch("system_health.shutil.disk_usage")
    def test_health_check_returns_zero_when_healthy(
        self, mock_disk, mock_memory, mock_cpu, mock_services
    ):
        mock_disk.return_value = self.disk
        mock_memory.return_value = self.memory

        with patch("builtins.print"):
            result = system_health.main()

        self.assertEqual(result, 0)

    @patch("system_health.check_service", return_value=True)
    @patch("system_health.get_cpu_usage", return_value=20.0)
    @patch("system_health.get_memory_usage")
    @patch("system_health.shutil.disk_usage")
    def test_health_check_returns_one_when_disk_is_critical(
        self, mock_disk, mock_memory, mock_cpu, mock_services
    ):
        mock_disk.return_value = type(
            "Disk", (), {"total": 1000, "used": 900, "free": 100}
        )()
        mock_memory.return_value = self.memory

        with patch("builtins.print"):
            result = system_health.main()

        self.assertEqual(result, 1)

    @patch("system_health.check_service", return_value=True)
    @patch("system_health.get_cpu_usage", return_value=20.0)
    @patch("system_health.get_memory_usage")
    @patch("system_health.shutil.disk_usage")
    def test_health_check_returns_one_when_memory_is_critical(
        self, mock_disk, mock_memory, mock_cpu, mock_services
    ):
        mock_disk.return_value = self.disk
        mock_memory.return_value = {
            "total_mib": 1000,
            "available_mib": 50,
            "used_percent": 95.0,
        }

        with patch("builtins.print"):
            result = system_health.main()

        self.assertEqual(result, 1)

    @patch("system_health.check_service", return_value=True)
    @patch("system_health.get_cpu_usage", return_value=90.0)
    @patch("system_health.get_memory_usage")
    @patch("system_health.shutil.disk_usage")
    def test_health_check_returns_one_when_cpu_is_critical(
        self, mock_disk, mock_memory, mock_cpu, mock_services
    ):
        mock_disk.return_value = self.disk
        mock_memory.return_value = self.memory

        with patch("builtins.print"):
            result = system_health.main()

        self.assertEqual(result, 1)

    @patch("system_health.check_service", return_value=False)
    @patch("system_health.get_cpu_usage", return_value=20.0)
    @patch("system_health.get_memory_usage")
    @patch("system_health.shutil.disk_usage")
    def test_health_check_returns_one_when_service_is_down(
        self, mock_disk, mock_memory, mock_cpu, mock_services
    ):
        mock_disk.return_value = self.disk
        mock_memory.return_value = self.memory

        with patch("builtins.print"):
            result = system_health.main()

        self.assertEqual(result, 1)


if __name__ == "__main__":
    unittest.main()
