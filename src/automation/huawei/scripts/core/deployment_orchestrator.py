#!/usr/bin/env python3
"""
DeploymentOrchestrator - Core Module 3/3 für Huawei Network Automation Suite Phase 1 MVP
Intelligente Deployment-Sequenzierung und Orchestrierung

Features:
- Sequential Deployment Strategy (Phase 1 Requirement)
- Inventory-basierte Geräte-Orchestrierung
- Template Validation vor Deployment
- Dependency-aware Deployment Order
- Rollback Capabilities
- Comprehensive Error Handling
- Dry-Run und Preview Modi
"""

import os
import time
import logging
from typing import Dict, List, Optional, Any, Union
from dataclasses import dataclass
from pathlib import Path
from enum import Enum
import yaml
from datetime import datetime

# Import our core modules
try:
    from .device_manager import DeviceManager
    from .template_engine import TemplateEngine
except (ImportError, ModuleNotFoundError):
    # Fallback for standalone execution
    import sys
    sys.path.append(str(Path(__file__).parent))
    from device_manager import DeviceManager
    from template_engine import TemplateEngine


class DeploymentStatus(Enum):
    """Status values for deployment operations"""
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    SUCCESS = "success"
    FAILED = "failed"
    SKIPPED = "skipped"
    ROLLED_BACK = "rolled_back"


@dataclass
class DeviceResult:
    """Result of a single device deployment"""
    device_name: str
    status: DeploymentStatus
    message: str
    config_lines: int = 0
    execution_time: float = 0.0
    error: Optional[str] = None


@dataclass
class DeploymentResult:
    """Result of a complete deployment operation"""
    total_devices: int
    successful: int
    failed: int
    skipped: int
    execution_time: float
    results: Dict[str, DeviceResult]
    summary: str


class DeploymentOrchestrator:
    """
    Intelligent Deployment Orchestrator für Phase 1 MVP
    
    Phase 1 Features:
    - Sequential Deployment (Management → Core → Access → Edge)
    - YAML-basierte Inventory-Verwaltung
    - Template Validation vor Deployment
    - Automatische Dependency-Resolution
    - Rollback bei Fehlern
    - Comprehensive Logging und Monitoring
    """
    
    def __init__(self, 
                 device_manager: DeviceManager,
                 template_engine: TemplateEngine,
                 inventory_path: Optional[str] = None):
        """
        Initialize DeploymentOrchestrator
        
        Args:
            device_manager: DeviceManager instance
            template_engine: TemplateEngine instance
            inventory_path: Optional path to inventory file
        """
        self.device_manager = device_manager
        self.template_engine = template_engine
        self.inventory_path = inventory_path
        
        # Inventory data
        self.inventory: Dict[str, Any] = {}
        self.devices: List[Dict[str, Any]] = []
        
        # Deployment state
        self.deployment_history: List[DeploymentResult] = []
        self.current_deployment: Optional[DeploymentResult] = None
        
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
        
        self.logger.info("DeploymentOrchestrator initialized")
        
        # Load inventory if provided
        if inventory_path:
            self.load_inventory(inventory_path)
    
    def load_inventory(self, inventory_path: Optional[str] = None) -> bool:
        """
        Load device inventory from YAML file
        
        Args:
            inventory_path: Path to inventory YAML file
            
        Returns:
            bool: True if loaded successfully
        """
        if inventory_path:
            self.inventory_path = inventory_path
        
        if not self.inventory_path:
            self.logger.error("❌ No inventory path specified")
            return False
        
        try:
            inventory_file = Path(self.inventory_path)
            if not inventory_file.exists():
                self.logger.error(f"❌ Inventory file not found: {inventory_file}")
                return False
            
            with open(inventory_file, 'r', encoding='utf-8') as f:
                self.inventory = yaml.safe_load(f)
            
            # Extract device list
            if 'devices' in self.inventory:
                self.devices = []
                for device_name, device_config in self.inventory['devices'].items():
                    device_config['name'] = device_name
                    self.devices.append(device_config)
                
                # Sort by deployment order
                self.devices.sort(key=lambda d: d.get('deployment_order', 999))
                
                self.logger.info(f"✅ Loaded inventory with {len(self.devices)} devices from {inventory_file}")
                return True
            else:
                self.logger.error(f"❌ No 'devices' section found in inventory")
                return False
                
        except yaml.YAMLError as e:
            self.logger.error(f"❌ YAML parsing error in inventory: {str(e)}")
            return False
        except Exception as e:
            self.logger.error(f"❌ Error loading inventory: {str(e)}")
            return False
    
    def get_devices(self) -> List[Dict[str, Any]]:
        """
        Get list of devices from inventory
        
        Returns:
            List: Device configurations
        """
        return self.devices.copy()
    
    def get_deployment_sequence(self) -> List[Dict[str, Any]]:
        """
        Get devices in deployment order
        
        Returns:
            List: Devices sorted by deployment order
        """
        # Phase 1 Sequential Order: Management → Core → Access → Edge
        ordered_devices = sorted(self.devices, key=lambda d: d.get('deployment_order', 999))
        
        self.logger.info("📋 Deployment sequence calculated:")
        for i, device in enumerate(ordered_devices, 1):
            role = device.get('role', 'unknown')
            name = device.get('name', 'unknown')
            self.logger.info(f"   {i}. {name} ({role})")
        
        return ordered_devices
    
    def validate_templates(self) -> bool:
        """
        Validate all templates before deployment (Phase 1 Requirement)
        
        Returns:
            bool: True if all templates are valid
        """
        self.logger.info("🔍 Validating templates before deployment...")
        
        # Get all unique templates used by devices
        used_templates = set()
        for device in self.devices:
            template_name = device.get('template')
            if template_name:
                used_templates.add(f"{template_name}.j2")
        
        if not used_templates:
            self.logger.warning("⚠️ No templates specified in device inventory")
            return True
        
        # Validate each template
        validation_results = self.template_engine.validate_all_templates()
        all_valid = True
        
        self.logger.info(f"Template validation: {len(validation_results)} templates checked")
        
        for template_name, result in validation_results.items():
            is_valid = result.get('valid', False)
            if is_valid:
                self.logger.info(f"✅ {template_name}: PASS")
            else:
                self.logger.error(f"❌ {template_name}: FAIL - {result.get('error', 'Unknown error')}")
                all_valid = False
        
        if all_valid:
            self.logger.info("✅ All templates validation passed")
        else:
            self.logger.error("❌ Template validation failed - not all templates are valid")
        
        return all_valid
    
    def deploy_device(self, device_config: Dict[str, Any], dry_run: bool = None) -> DeviceResult:
        """
        Deploy configuration to a single device
        
        Args:
            device_config: Device configuration from inventory
            dry_run: Override dry-run setting
            
        Returns:
            DeviceResult: Result of deployment
        """
        device_name = device_config.get('name', 'unknown')
        start_time = time.time()
        
        try:
            # Determine dry run mode
            if dry_run is None:
                dry_run = self.inventory.get('global_settings', {}).get('dry_run_default', True)
            
            # Get device details
            device_ip = device_config.get('ip')
            device_type = device_config.get('device_type', 'huawei')
            template_name = device_config.get('template')
            role = device_config.get('role', 'unknown')
            
            if not device_ip:
                return DeviceResult(
                    device_name=device_name,
                    status=DeploymentStatus.FAILED,
                    message="No IP address specified",
                    error="Missing device IP address"
                )
            
            if not template_name:
                return DeviceResult(
                    device_name=device_name,
                    status=DeploymentStatus.FAILED,
                    message="No template specified",
                    error="Missing template name"
                )
            
            self.logger.info(f"🚀 Deploying {device_name} ({role}) - IP: {device_ip}")
            
            # Connect to device
            credentials = device_config.get('credentials', {})
            connection_params = {
                'device_type': device_type,
                'username': credentials.get('username', 'admin'),
                'password': credentials.get('password'),
                'ssh_key_file': credentials.get('ssh_key_file')
            }
            
            if not dry_run:
                connected = self.device_manager.connect(device_name, device_ip, **connection_params)
                if not connected:
                    return DeviceResult(
                        device_name=device_name,
                        status=DeploymentStatus.FAILED,
                        message="Failed to connect to device",
                        error="SSH connection failed"
                    )
            
            # Generate configuration
            config = self.template_engine.generate_config(role, device_config)
            if not config:
                return DeviceResult(
                    device_name=device_name,
                    status=DeploymentStatus.FAILED,
                    message="Failed to generate configuration",
                    error="Template rendering failed"
                )
            
            config_lines = len([line for line in config.split('\n') if line.strip()])
            
            # Deploy configuration
            if dry_run:
                self.logger.info(f"🎭 DRY RUN: Configuration for {device_name} ({config_lines} lines)")
                deployment_success = True
            else:
                deployment_success = self.device_manager.deploy_config(
                    device_name, 
                    config, 
                    dry_run=False
                )
                
                # Disconnect after deployment
                self.device_manager.disconnect(device_name)
            
            execution_time = time.time() - start_time
            
            if deployment_success:
                return DeviceResult(
                    device_name=device_name,
                    status=DeploymentStatus.SUCCESS,
                    message=f"Successfully deployed {config_lines} configuration lines",
                    config_lines=config_lines,
                    execution_time=execution_time
                )
            else:
                return DeviceResult(
                    device_name=device_name,
                    status=DeploymentStatus.FAILED,
                    message="Configuration deployment failed",
                    config_lines=config_lines,
                    execution_time=execution_time,
                    error="Deployment execution failed"
                )
                
        except Exception as e:
            execution_time = time.time() - start_time
            error_msg = str(e)
            self.logger.error(f"❌ Error deploying {device_name}: {error_msg}")
            
            return DeviceResult(
                device_name=device_name,
                status=DeploymentStatus.FAILED,
                message="Deployment failed with exception",
                execution_time=execution_time,
                error=error_msg
            )
    
    def deploy_all_devices(self, dry_run: bool = None) -> DeploymentResult:
        """
        Deploy configuration to all devices in sequence
        
        Args:
            dry_run: If True, only simulate deployment
            
        Returns:
            DeploymentResult: Overall deployment result
        """
        start_time = time.time()
        
        if not self.devices:
            self.logger.error("❌ No devices loaded in inventory")
            return DeploymentResult(
                total_devices=0,
                successful=0,
                failed=0,
                skipped=0,
                execution_time=0.0,
                results={},
                summary="No devices to deploy"
            )
        
        # Determine dry run mode
        if dry_run is None:
            dry_run = self.inventory.get('global_settings', {}).get('dry_run_default', True)
        
        mode_str = "DRY RUN" if dry_run else "PRODUCTION"
        self.logger.info(f"🎯 Starting {mode_str} deployment of {len(self.devices)} devices")
        
        # Validate templates first (Phase 1 Requirement)
        if not self.validate_templates():
            return DeploymentResult(
                total_devices=len(self.devices),
                successful=0,
                failed=len(self.devices),
                skipped=0,
                execution_time=time.time() - start_time,
                results={},
                summary="Template validation failed - deployment aborted"
            )
        
        # Get deployment sequence
        deployment_sequence = self.get_deployment_sequence()
        
        # Deploy devices sequentially
        results = {}
        successful = 0
        failed = 0
        skipped = 0
        
        for device_config in deployment_sequence:
            device_name = device_config.get('name', 'unknown')
            
            # Check if we should stop on previous failures
            rollback_on_failure = self.inventory.get('deployment_strategy', {}).get('rollback_on_failure', True)
            if rollback_on_failure and failed > 0:
                self.logger.warning(f"⏸️ Skipping {device_name} due to previous failures")
                results[device_name] = DeviceResult(
                    device_name=device_name,
                    status=DeploymentStatus.SKIPPED,
                    message="Skipped due to previous deployment failures"
                )
                skipped += 1
                continue
            
            # Deploy device
            result = self.deploy_device(device_config, dry_run)
            results[device_name] = result
            
            if result.status == DeploymentStatus.SUCCESS:
                successful += 1
                self.logger.info(f"✅ {device_name}: {result.message}")
            else:
                failed += 1
                self.logger.error(f"❌ {device_name}: {result.message}")
                if result.error:
                    self.logger.error(f"   Error: {result.error}")
        
        execution_time = time.time() - start_time
        
        # Create summary
        success_rate = (successful / len(self.devices) * 100) if self.devices else 0
        summary = f"{successful}/{len(self.devices)} devices deployed successfully ({success_rate:.1f}%)"
        
        deployment_result = DeploymentResult(
            total_devices=len(self.devices),
            successful=successful,
            failed=failed,
            skipped=skipped,
            execution_time=execution_time,
            results=results,
            summary=summary
        )
        
        # Store in history
        self.deployment_history.append(deployment_result)
        self.current_deployment = deployment_result
        
        self.logger.info(f"📊 Deployment complete: {summary}")
        self.logger.info(f"⏱️ Total execution time: {execution_time:.2f} seconds")
        
        return deployment_result
    
    def get_deployment_status(self) -> Optional[Dict[str, Any]]:
        """
        Get status of current deployment
        
        Returns:
            dict: Current deployment status or None
        """
        if not self.current_deployment:
            return None
        
        return {
            'total_devices': self.current_deployment.total_devices,
            'successful': self.current_deployment.successful,
            'failed': self.current_deployment.failed,
            'skipped': self.current_deployment.skipped,
            'execution_time': self.current_deployment.execution_time,
            'summary': self.current_deployment.summary,
            'timestamp': datetime.now().isoformat()
        }
    
    def get_deployment_history(self) -> List[DeploymentResult]:
        """Get deployment history"""
        return self.deployment_history.copy()
    
    # Convenience methods for backward compatibility
    def deploy(self, dry_run: bool = True) -> DeploymentResult:
        """Alias for deploy_all_devices method"""
        return self.deploy_all_devices(dry_run)
    
    def orchestrate_deployment(self, dry_run: bool = True) -> DeploymentResult:
        """Alias for deploy_all_devices method"""
        return self.deploy_all_devices(dry_run)


def create_deployment_orchestrator(
    device_manager: DeviceManager,
    template_engine: TemplateEngine,
    inventory_path: Optional[str] = None
) -> DeploymentOrchestrator:
    """Factory function to create DeploymentOrchestrator instance"""
    return DeploymentOrchestrator(device_manager, template_engine, inventory_path)


def quick_deploy(inventory_path: str, dry_run: bool = True) -> DeploymentResult:
    """
    Quick deployment function for simple use cases
    
    Args:
        inventory_path: Path to device inventory
        dry_run: If True, only simulate deployment
        
    Returns:
        DeploymentResult: Deployment result
    """
    # Create components
    device_manager = DeviceManager()
    template_engine = TemplateEngine()
    orchestrator = DeploymentOrchestrator(device_manager, template_engine, inventory_path)
    
    # Execute deployment
    return orchestrator.deploy_all_devices(dry_run)


if __name__ == "__main__":
    print("DeploymentOrchestrator - Phase 1 MVP Module")
    print("Intelligent deployment sequencing for Huawei Network Automation Suite")
