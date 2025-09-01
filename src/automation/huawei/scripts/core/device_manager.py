#!/usr/bin/env python3
"""
DeviceManager - Core Module 1/3 für Huawei Network Automation Suite Phase 1 MVP
SSH-basierte Geräteverbindung und Konfigurationsmanagement

Features:
- SSH Key-basierte Authentifizierung (keine Passwörter)
- Python 3.13 kompatibel (kein telnetlib)
- Retry-Mechanismen und Fehlerbehandlung
- Verbindungs-Pooling und Wiederverwendung
- Dry-Run Capabilities
- Logging und Monitoring
"""

import os
import time
import logging
from typing import Dict, List, Optional, Any, Union
from dataclasses import dataclass
from pathlib import Path
import subprocess

try:
    from netmiko import ConnectHandler
    from netmiko.exceptions import NetmikoTimeoutException, NetmikoAuthenticationException, NetmikoBaseException
except ImportError:
    print("ERROR: netmiko not installed. Run: pip install netmiko>=4.6.0")
    raise


@dataclass
class ConnectionConfig:
    """Konfiguration für SSH-Verbindungen"""
    timeout: int = 30
    keepalive: int = 30
    max_retries: int = 3
    retry_delay: int = 5
    ssh_key_file: str = "~/.ssh/huawei_automation_rsa"
    default_username: str = "admin"
    
    
class DeviceManager:
    """
    Manages SSH connections and configuration deployment to Huawei devices
    
    Phase 1 MVP Features:
    - SSH key-basierte Authentifizierung
    - Verbindungsmanagement mit Retry-Logik
    - Konfigurationsdeployment mit Dry-Run
    - Fehlerbehandlung und Logging
    - Python 3.13 kompatibel (kein telnetlib)
    """
    
    def __init__(self, config: Optional[ConnectionConfig] = None):
        """Initialize DeviceManager mit Konfiguration"""
        self.config = config or ConnectionConfig()
        self.connections: Dict[str, ConnectHandler] = {}
        self.connection_status: Dict[str, bool] = {}
        
        # Setup logging
        self.logger = logging.getLogger(__name__)
        if not self.logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)
            self.logger.setLevel(logging.INFO)
            
        self.logger.info("DeviceManager initialized for Phase 1 MVP")
    
    def connect(self, device_name: str, device_ip: str, **kwargs) -> bool:
        """
        Establish SSH connection to a Huawei device
        
        Args:
            device_name: Unique device identifier
            device_ip: IP address of device
            **kwargs: Additional connection parameters
            
        Returns:
            bool: True if connection successful
        """
        if device_name in self.connections:
            if self.is_connected(device_name):
                self.logger.info(f"✅ Device {device_name} already connected")
                return True
            else:
                # Clean up dead connection
                self._cleanup_connection(device_name)
        
        # Determine device type for netmiko
        device_type = kwargs.get('device_type', 'huawei')
        username = kwargs.get('username', self.config.default_username)
        password = kwargs.get('password')
        ssh_key_file = kwargs.get('ssh_key_file', self.config.ssh_key_file)
        
        # Expand SSH key file path
        ssh_key_path = Path(ssh_key_file).expanduser()
        
        # Connection parameters for netmiko
        connection_params = {
            'device_type': device_type,
            'host': device_ip,
            'username': username,
            'timeout': self.config.timeout,
            'keepalive': self.config.keepalive,
            'session_timeout': 60
        }
        
        # Use SSH key if available, otherwise password
        if ssh_key_path.exists():
            connection_params['use_keys'] = True
            connection_params['key_file'] = str(ssh_key_path)
            self.logger.info(f"🔑 Using SSH key authentication: {ssh_key_path}")
        elif password:
            connection_params['password'] = password
            self.logger.info(f"🔒 Using password authentication")
        else:
            self.logger.error(f"❌ No SSH key or password provided for {device_name}")
            return False
        
        # Attempt connection with retries
        for attempt in range(self.config.max_retries):
            try:
                self.logger.info(f"🔗 Connecting to {device_name} ({device_ip}) - Attempt {attempt + 1}")
                
                connection = ConnectHandler(**connection_params)
                
                # Test connection with a simple command
                output = connection.send_command("display version", read_timeout=10)
                if "VRP" in output or "Huawei" in output:
                    self.connections[device_name] = connection
                    self.connection_status[device_name] = True
                    self.logger.info(f"✅ Successfully connected to {device_name}")
                    return True
                else:
                    self.logger.warning(f"⚠️ Connection established but device verification failed for {device_name}")
                    connection.disconnect()
                    
            except NetmikoTimeoutException:
                self.logger.warning(f"⏰ Timeout connecting to {device_name} - Attempt {attempt + 1}")
            except NetmikoAuthenticationException:
                self.logger.error(f"🔐 Authentication failed for {device_name}")
                break  # Don't retry authentication failures
            except NetmikoBaseException as e:
                self.logger.warning(f"⚠️ Connection error for {device_name}: {str(e)} - Attempt {attempt + 1}")
            except Exception as e:
                self.logger.error(f"❌ Unexpected error connecting to {device_name}: {str(e)}")
                break
            
            if attempt < self.config.max_retries - 1:
                self.logger.info(f"⏳ Waiting {self.config.retry_delay} seconds before retry...")
                time.sleep(self.config.retry_delay)
        
        self.connection_status[device_name] = False
        self.logger.error(f"❌ Failed to connect to {device_name} after {self.config.max_retries} attempts")
        return False
    
    def disconnect(self, device_name: str) -> bool:
        """
        Disconnect from a device
        
        Args:
            device_name: Device to disconnect from
            
        Returns:
            bool: True if disconnection successful
        """
        if device_name not in self.connections:
            self.logger.warning(f"⚠️ Device {device_name} not connected")
            return True
        
        try:
            self.connections[device_name].disconnect()
            self._cleanup_connection(device_name)
            self.logger.info(f"✅ Disconnected from {device_name}")
            return True
        except Exception as e:
            self.logger.error(f"❌ Error disconnecting from {device_name}: {str(e)}")
            self._cleanup_connection(device_name)  # Clean up anyway
            return False
    
    def disconnect_all(self) -> None:
        """Disconnect from all devices"""
        device_names = list(self.connections.keys())
        for device_name in device_names:
            self.disconnect(device_name)
    
    def is_connected(self, device_name: str) -> bool:
        """
        Check if device is connected and responsive
        
        Args:
            device_name: Device to check
            
        Returns:
            bool: True if connected and responsive
        """
        if device_name not in self.connections:
            return False
        
        try:
            # Test with a simple command
            self.connections[device_name].send_command("display clock", read_timeout=5)
            self.connection_status[device_name] = True
            return True
        except Exception:
            self.connection_status[device_name] = False
            self._cleanup_connection(device_name)
            return False
    
    def send_command(self, device_name: str, command: str, **kwargs) -> Optional[str]:
        """
        Send a command to a device
        
        Args:
            device_name: Target device
            command: Command to send
            **kwargs: Additional parameters
            
        Returns:
            str: Command output or None if failed
        """
        if not self.is_connected(device_name):
            self.logger.error(f"❌ Device {device_name} not connected")
            return None
        
        try:
            read_timeout = kwargs.get('read_timeout', 30)
            output = self.connections[device_name].send_command(
                command, 
                read_timeout=read_timeout
            )
            self.logger.debug(f"📤 Sent command to {device_name}: {command}")
            return output
        except Exception as e:
            self.logger.error(f"❌ Error sending command to {device_name}: {str(e)}")
            return None
    
    def send_config_set(self, device_name: str, config_commands: List[str], **kwargs) -> bool:
        """
        Send configuration commands to a device
        
        Args:
            device_name: Target device
            config_commands: List of configuration commands
            **kwargs: Additional parameters
            
        Returns:
            bool: True if successful
        """
        if not self.is_connected(device_name):
            self.logger.error(f"❌ Device {device_name} not connected")
            return False
        
        try:
            dry_run = kwargs.get('dry_run', False)
            
            if dry_run:
                self.logger.info(f"🎭 DRY RUN: Would send {len(config_commands)} commands to {device_name}")
                for i, cmd in enumerate(config_commands, 1):
                    self.logger.info(f"   {i:3d}: {cmd}")
                return True
            
            # Send configuration commands
            output = self.connections[device_name].send_config_set(
                config_commands,
                cmd_verify=kwargs.get('cmd_verify', True)
            )
            
            # Save configuration
            save_config = kwargs.get('save_config', True)
            if save_config:
                save_output = self.connections[device_name].save_config()
                self.logger.info(f"💾 Configuration saved on {device_name}")
            
            self.logger.info(f"✅ Successfully sent {len(config_commands)} commands to {device_name}")
            return True
            
        except Exception as e:
            self.logger.error(f"❌ Error sending config to {device_name}: {str(e)}")
            return False
    
    def deploy_config(self, device_name: str, configuration: str, dry_run: bool = False) -> bool:
        """
        Deploy a complete configuration to a device
        
        Args:
            device_name: Target device
            configuration: Configuration text
            dry_run: If True, only simulate the deployment
            
        Returns:
            bool: True if successful
        """
        if not configuration.strip():
            self.logger.warning(f"⚠️ Empty configuration for {device_name}")
            return False
        
        # Split configuration into individual commands
        config_lines = [
            line.strip() 
            for line in configuration.split('\n') 
            if line.strip() and not line.strip().startswith('#')
        ]
        
        if not config_lines:
            self.logger.warning(f"⚠️ No valid configuration commands for {device_name}")
            return False
        
        self.logger.info(f"🚀 Deploying configuration to {device_name} ({len(config_lines)} commands)")
        
        if dry_run:
            self.logger.info(f"🎭 DRY RUN MODE - Configuration preview for {device_name}:")
            for i, line in enumerate(config_lines[:20], 1):  # Show first 20 lines
                self.logger.info(f"   {i:3d}: {line}")
            if len(config_lines) > 20:
                self.logger.info(f"   ... and {len(config_lines) - 20} more lines")
            return True
        
        return self.send_config_set(device_name, config_lines, save_config=True)
    
    def get_device_info(self, device_name: str) -> Optional[Dict[str, Any]]:
        """
        Get basic device information
        
        Args:
            device_name: Target device
            
        Returns:
            dict: Device information or None if failed
        """
        if not self.is_connected(device_name):
            return None
        
        try:
            info = {}
            
            # Get version information
            version_output = self.send_command(device_name, "display version")
            if version_output:
                info['version_output'] = version_output
                # Parse basic info (simplified for Phase 1)
                lines = version_output.split('\n')
                for line in lines:
                    if 'VRP' in line and 'Version' in line:
                        info['software_version'] = line.strip()
                        break
            
            # Get hostname
            hostname_output = self.send_command(device_name, "display current-configuration | include sysname")
            if hostname_output:
                info['hostname'] = hostname_output.strip()
            
            # Get uptime
            clock_output = self.send_command(device_name, "display clock")
            if clock_output:
                info['current_time'] = clock_output.strip()
            
            info['connection_status'] = 'connected'
            info['device_name'] = device_name
            
            return info
            
        except Exception as e:
            self.logger.error(f"❌ Error getting device info for {device_name}: {str(e)}")
            return None
    
    def get_connection_status(self) -> Dict[str, bool]:
        """Get connection status for all devices"""
        return self.connection_status.copy()
    
    def _cleanup_connection(self, device_name: str) -> None:
        """Clean up connection references"""
        self.connections.pop(device_name, None)
        self.connection_status.pop(device_name, None)
    
    # Convenience methods for backward compatibility
    def connect_device(self, device_name: str, device_ip: str, **kwargs) -> bool:
        """Alias for connect method"""
        return self.connect(device_name, device_ip, **kwargs)
    
    def deploy_configuration(self, device_name: str, configuration: str, dry_run: bool = False) -> bool:
        """Alias for deploy_config method"""
        return self.deploy_config(device_name, configuration, dry_run)


def create_device_manager(config: Optional[ConnectionConfig] = None) -> DeviceManager:
    """Factory function to create DeviceManager instance"""
    return DeviceManager(config)


def test_connection(device_ip: str, username: str = "admin", password: str = "admin123") -> bool:
    """
    Test SSH connectivity to a device
    
    Args:
        device_ip: IP address to test
        username: SSH username
        password: SSH password
        
    Returns:
        bool: True if connection successful
    """
    manager = DeviceManager()
    return manager.connect("test_device", device_ip, username=username, password=password)


if __name__ == "__main__":
    print("DeviceManager - Phase 1 MVP Module")
    print("SSH-based device management for Huawei Network Automation Suite")
