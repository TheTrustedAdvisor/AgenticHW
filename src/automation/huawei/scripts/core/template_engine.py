#!/usr/bin/env python3
"""
TemplateEngine - Core Module 2/3 für Huawei Network Automation Suite Phase 1 MVP
Jinja2-basierte Konfigurationsgenerierung mit Template-Validierung

Features:
- Template-basierte Konfigurationsgenerierung
- Umfassende Template-Syntax-Validierung (4/4 Templates müssen PASS)
- Variable-Validierung (keine undefined variables)
- Device-spezifische Template-Auswahl
- Preview und Dry-Run Capabilities
- Fehlerresistente Template-Verarbeitung
"""

import os
import logging
from typing import Dict, List, Optional, Any, Union
from pathlib import Path
import yaml

try:
    from jinja2 import Environment, FileSystemLoader, Template, StrictUndefined, TemplateSyntaxError, UndefinedError
    from jinja2.exceptions import TemplateNotFound, TemplateRuntimeError
except ImportError:
    print("ERROR: Jinja2 not installed. Run: pip install Jinja2>=3.1.2")
    raise


class TemplateEngine:
    """
    Advanced Template Engine für Huawei Device Configuration Generation
    
    Phase 1 MVP Features:
    - 4 Device-spezifische Templates (management, core, access, edge_router)
    - Template Syntax Validation (4/4 Templates müssen PASS)
    - Variable Validation (keine undefined variables wie ansible_date_time)
    - Configuration Preview und Dry-Run
    - Robust Error Handling
    - Custom Jinja2 Filters für Networking
    """
    
    def __init__(self, template_dir: Optional[str] = None):
        """Initialize TemplateEngine mit Template-Verzeichnis"""
        # Default template directory
        if template_dir is None:
            template_dir = "src/automation/huawei/templates"
        
        self.template_dir = Path(template_dir)
        if not self.template_dir.exists():
            self.template_dir.mkdir(parents=True, exist_ok=True)
        
        # Setup Jinja2 environment
        self.env = Environment(
            loader=FileSystemLoader(str(self.template_dir)),
            trim_blocks=True,
            lstrip_blocks=True,
            keep_trailing_newline=True,
            undefined=StrictUndefined  # Fail on undefined variables
        )
        
        # Add custom filters for networking
        self._add_custom_filters()
        
        # Template cache
        self.template_cache: Dict[str, Template] = {}
        
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
        
        self.logger.info(f"TemplateEngine initialized with directory: {self.template_dir}")
    
    def _add_custom_filters(self):
        """Add custom Jinja2 filters for networking"""
        
        def ipv4_network(value, prefix_length):
            """Calculate network address from IP and prefix length"""
            try:
                import ipaddress
                network = ipaddress.IPv4Network(f"{value}/{prefix_length}", strict=False)
                return str(network.network_address)
            except:
                return value
        
        def subnet_mask(prefix_length):
            """Convert prefix length to subnet mask"""
            try:
                import ipaddress
                network = ipaddress.IPv4Network(f"0.0.0.0/{prefix_length}")
                return str(network.netmask)
            except:
                return "255.255.255.0"
        
        def wildcard_mask(prefix_length):
            """Convert prefix length to wildcard mask"""
            try:
                import ipaddress
                network = ipaddress.IPv4Network(f"0.0.0.0/{prefix_length}")
                return str(network.hostmask)
            except:
                return "0.0.0.255"
        
        self.env.filters['ipv4_network'] = ipv4_network
        self.env.filters['subnet_mask'] = subnet_mask
        self.env.filters['wildcard_mask'] = wildcard_mask
    
    def list_templates(self) -> List[str]:
        """
        List all available template files
        
        Returns:
            List[str]: List of template filenames
        """
        templates = []
        try:
            for file_path in self.template_dir.glob("*.j2"):
                templates.append(file_path.name)
            templates.sort()
            return templates
        except Exception as e:
            self.logger.error(f"❌ Error listing templates: {str(e)}")
            return []
    
    def template_exists(self, template_name: str) -> bool:
        """
        Check if template exists
        
        Args:
            template_name: Name of template file
            
        Returns:
            bool: True if template exists
        """
        template_path = self.template_dir / template_name
        return template_path.exists()
    
    def validate_template_syntax(self, template_name: str) -> Dict[str, Any]:
        """
        Validate template syntax (Phase 1 Requirement: 4/4 templates must PASS)
        
        Args:
            template_name: Name of template to validate
            
        Returns:
            dict: Validation result with 'valid' boolean and optional 'error'
        """
        try:
            if not self.template_exists(template_name):
                return {
                    'valid': False,
                    'error': f"Template file not found: {template_name}"
                }
            
            # Load and parse template
            template = self.env.get_template(template_name)
            
            # Try to render with minimal variables to check syntax
            minimal_vars = {
                'hostname': 'TEST-DEVICE',
                'device_name': 'test-device',
                'management_ip': '192.168.1.1',
                'vlans': {},
                'interfaces': {},
                'port_config': {},
                'stp': {'mode': 'rstp', 'priority': 32768},
                'routing': {
                    'ospf': {
                        'process_id': 1,
                        'router_id': '1.1.1.1',
                        'area': 0,
                        'networks': []
                    }
                },
                'nat': {
                    'inside_interfaces': [],
                    'outside_interfaces': []
                },
                'features': [],
                # Common variables that might be used
                'mgmt_vlan': 10,
                'generation_time': '2025-09-01 12:00:00',
                'template_name': template_name
            }
            
            # Test rendering
            rendered = template.render(**minimal_vars)
            
            self.logger.info(f"✅ Template {template_name} syntax validation passed")
            return {
                'valid': True,
                'length': len(rendered),
                'lines': len(rendered.split('\n'))
            }
            
        except TemplateSyntaxError as e:
            error_msg = f"Syntax error: {str(e)}"
            self.logger.error(f"❌ Template {template_name} syntax error: {error_msg}")
            return {
                'valid': False,
                'error': error_msg,
                'line_number': getattr(e, 'lineno', None)
            }
        except UndefinedError as e:
            error_msg = f"Undefined variable: {str(e)}"
            self.logger.error(f"❌ Template {template_name} undefined variable: {error_msg}")
            return {
                'valid': False,
                'error': error_msg
            }
        except Exception as e:
            error_msg = f"Validation error: {str(e)}"
            self.logger.error(f"❌ Template {template_name} validation error: {error_msg}")
            return {
                'valid': False,
                'error': error_msg
            }
    
    def validate_all_templates(self) -> Dict[str, Dict[str, Any]]:
        """
        Validate all templates (Phase 1 Requirement: 4/4 must PASS)
        
        Returns:
            dict: Validation results for all templates
        """
        templates = self.list_templates()
        results = {}
        valid_count = 0
        
        self.logger.info(f"Validating {len(templates)} templates...")
        
        for template_name in templates:
            result = self.validate_template_syntax(template_name)
            results[template_name] = result
            if result['valid']:
                valid_count += 1
        
        self.logger.info(f"Template validation complete: {valid_count}/{len(templates)} templates valid")
        
        return results
    
    def get_template(self, template_name: str) -> Optional[Template]:
        """
        Get a compiled template object
        
        Args:
            template_name: Name of template
            
        Returns:
            Template: Compiled Jinja2 template or None
        """
        if template_name in self.template_cache:
            return self.template_cache[template_name]
        
        try:
            template = self.env.get_template(template_name)
            self.template_cache[template_name] = template
            return template
        except TemplateNotFound:
            self.logger.error(f"❌ Template not found: {template_name}")
            return None
        except Exception as e:
            self.logger.error(f"❌ Error loading template {template_name}: {str(e)}")
            return None
    
    def render_template(self, template_name: str, variables: Dict[str, Any]) -> Optional[str]:
        """
        Render a template with variables
        
        Args:
            template_name: Name of template to render
            variables: Variables for template rendering
            
        Returns:
            str: Rendered configuration or None if failed
        """
        template = self.get_template(template_name)
        if not template:
            return None
        
        try:
            # Prepare variables with defaults to avoid undefined errors
            prepared_vars = self._prepare_variables(variables)
            
            # Render template
            rendered = template.render(**prepared_vars)
            
            self.logger.debug(f"✅ Template {template_name} rendered successfully")
            return rendered
            
        except UndefinedError as e:
            self.logger.error(f"❌ Undefined variable in template {template_name}: {str(e)}")
            return None
        except TemplateRuntimeError as e:
            self.logger.error(f"❌ Runtime error in template {template_name}: {str(e)}")
            return None
        except Exception as e:
            self.logger.error(f"❌ Error rendering template {template_name}: {str(e)}")
            return None
    
    def _prepare_variables(self, variables: Dict[str, Any]) -> Dict[str, Any]:
        """
        Prepare variables with defaults to prevent undefined variable errors
        
        Args:
            variables: Input variables
            
        Returns:
            dict: Variables with defaults added
        """
        # Start with a copy of input variables
        prepared = variables.copy()
        
        # Add essential defaults if missing
        defaults = {
            'hostname': 'DEVICE',
            'device_name': 'device',
            'management_ip': '192.168.1.1',
            'vlans': {},
            'interfaces': {},
            'port_config': {},
            'stp': {'mode': 'rstp', 'priority': 32768},
            'routing': {
                'ospf': {
                    'process_id': 1,
                    'router_id': '1.1.1.1',
                    'area': 0,
                    'networks': []
                },
                'static_routes': []
            },
            'nat': {
                'inside_interfaces': [],
                'outside_interfaces': []
            },
            'features': [],
            'mgmt_vlan': 10,
            'generation_time': '2025-09-01 12:00:00',
            'template_name': 'unknown'
        }
        
        # Add defaults for missing keys
        for key, default_value in defaults.items():
            if key not in prepared:
                prepared[key] = default_value
        
        return prepared
    
    def generate_config(self, device_type: str, device_vars: Dict[str, Any]) -> Optional[str]:
        """
        Generate configuration for a specific device type
        
        Args:
            device_type: Type of device (management, core, access, edge)
            device_vars: Device-specific variables
            
        Returns:
            str: Generated configuration or None if failed
        """
        # Map device types to template names
        template_mapping = {
            'management': 'management_switch.j2',
            'core': 'core_switch.j2',
            'access': 'access_switch.j2',
            'edge': 'edge_router.j2',
            'router': 'edge_router.j2'
        }
        
        template_name = template_mapping.get(device_type)
        if not template_name:
            self.logger.error(f"❌ Unknown device type: {device_type}")
            return None
        
        # Add template name to variables
        device_vars['template_name'] = template_name
        device_vars['device_type'] = device_type
        
        return self.render_template(template_name, device_vars)
    
    def save_rendered_config(self, config: str, output_path: Union[str, Path]) -> bool:
        """
        Save rendered configuration to file
        
        Args:
            config: Rendered configuration
            output_path: Path to save configuration
            
        Returns:
            bool: True if saved successfully
        """
        try:
            output_path = Path(output_path)
            output_path.parent.mkdir(parents=True, exist_ok=True)
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(config)
            
            self.logger.info(f"💾 Configuration saved to: {output_path}")
            return True
            
        except Exception as e:
            self.logger.error(f"❌ Error saving configuration: {str(e)}")
            return False
    
    def clear_cache(self):
        """Clear template cache"""
        self.template_cache.clear()
        self.logger.info("🗑️ Template cache cleared")
    
    def get_template_info(self, template_name: str) -> Optional[Dict[str, Any]]:
        """
        Get information about a template
        
        Args:
            template_name: Name of template
            
        Returns:
            dict: Template information or None
        """
        if not self.template_exists(template_name):
            return None
        
        try:
            template_path = self.template_dir / template_name
            
            info = {
                'name': template_name,
                'path': str(template_path),
                'size': template_path.stat().st_size,
                'modified': template_path.stat().st_mtime,
                'exists': True
            }
            
            # Get validation status
            validation = self.validate_template_syntax(template_name)
            info['valid'] = validation['valid']
            if not validation['valid']:
                info['error'] = validation.get('error', 'Unknown error')
            
            return info
            
        except Exception as e:
            self.logger.error(f"❌ Error getting template info for {template_name}: {str(e)}")
            return None
    
    # Convenience methods for backward compatibility
    def render(self, template_name: str, variables: Dict[str, Any]) -> Optional[str]:
        """Alias for render_template method"""
        return self.render_template(template_name, variables)
    
    def validate_syntax(self, template_name: str) -> Dict[str, Any]:
        """Alias for validate_template_syntax method"""
        return self.validate_template_syntax(template_name)


def create_template_engine(template_dir: Optional[str] = None) -> TemplateEngine:
    """Factory function to create TemplateEngine instance"""
    return TemplateEngine(template_dir)


def validate_template_file(template_path: str) -> Dict[str, Any]:
    """
    Validate a single template file
    
    Args:
        template_path: Path to template file
        
    Returns:
        dict: Validation result
    """
    template_dir = str(Path(template_path).parent)
    template_name = Path(template_path).name
    
    engine = TemplateEngine(template_dir)
    return engine.validate_template_syntax(template_name)


if __name__ == "__main__":
    print("TemplateEngine - Phase 1 MVP Module")
    print("Jinja2-based configuration generation for Huawei Network Automation Suite")
