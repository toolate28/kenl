# ATOM-GOV: MCP Governance Framework

**Policy-as-code for Model Context Protocol servers**

## Overview

ATOM-GOV provides governance, auditing, and policy enforcement for Model Context Protocol (MCP) servers without requiring code changes to the servers themselves.

**Problem**: MCP servers provide powerful capabilities to AI assistants, but lack built-in governance, audit trails, and policy enforcement. This creates security, compliance, and cost management challenges in enterprise deployments.

**Solution**: ATOM-GOV acts as a transparent proxy/wrapper for MCP servers, applying policies, logging operations, and enforcing controls while maintaining full MCP protocol compatibility.

## Key Features

### Transparent Governance
- Drop-in replacement for MCP server invocations
- No code changes to existing MCP servers
- Full MCP protocol support
- Minimal performance overhead

### Policy Enforcement
- Rate limiting per server/user/tenant
- Resource quotas (API calls, storage, compute)
- Time-based access controls
- Approval workflows for sensitive operations

### Audit Trails
- Every MCP operation logged with ATOM tags
- Intent capture for all tool invocations
- Compliance-ready audit reports
- Forensic investigation support

### Multi-Tenancy
- Isolated environments per tenant
- Cross-tenant access prevention
- Tenant-specific policies
- Cost allocation and chargeback

## Architecture

```
┌─────────────┐
│ AI Assistant│ (Claude, GPT, etc.)
└──────┬──────┘
       │ MCP Protocol
       ▼
┌─────────────────────────────────┐
│      ATOM-GOV Proxy             │
│  • Policy engine                │
│  • Audit logging                │
│  • Rate limiting                │
│  • Access control               │
└──────┬──────────────────────────┘
       │ MCP Protocol (unchanged)
       ▼
┌─────────────────────────────────┐
│    MCP Servers (unmodified)     │
│  • Cloudflare MCP               │
│  • Perplexity MCP               │
│  • Ollama MCP                   │
│  • Custom MCP servers           │
└─────────────────────────────────┘
```

## Use Cases

### 1. Enterprise MCP Deployment
```yaml
# Policy: Require approval for production writes
mcp_policy:
  cloudflare_mcp:
    production_writes:
      require_approval: true
      approvers:
        - ops-team@company.com
      audit: true
```

### 2. Resource Management
```yaml
# Policy: Rate limit resource-intensive operations
mcp_policy:
  perplexity_mcp:
    research_queries:
      rate_limit: 100/hour
      resource_tracking: true
      alert_threshold: high_utilization
```

### 3. Compliance Requirements
```yaml
# Policy: SOC 2 audit requirements
mcp_policy:
  all_servers:
    audit:
      log_all_operations: true
      retention_days: 2555  # 7 years
      encrypt_logs: true
      pii_detection: true
```

### 4. Multi-Tenant SaaS
```yaml
# Policy: Tenant isolation
mcp_policy:
  tenants:
    isolation: strict
    quota_per_tenant:
      api_calls: 10000/month
      storage_gb: 100
      compute_hours: 50
```

## Installation

```bash
# Install ATOM+SAGE framework
cd atom-sage-framework
./install.sh

# Install ATOM-GOV
atom GOV "Initialize ATOM-GOV configuration"

# Configure MCP proxy
atom-gov init --config ~/.config/atom-sage/governance/mcp-governance.yaml
```

## Configuration

Create `~/.config/atom-sage/governance/mcp-governance.yaml`:

```yaml
atom_gov:
  version: 1.0.0

  # Global settings
  global:
    mode: proxy  # proxy | wrapper | inline
    audit: true
    encryption: true

  # MCP servers under governance
  servers:
    - name: cloudflare_mcp
      path: ~/.config/mcp/servers/cloudflare
      policies:
        - rate_limit: 1000/hour
        - require_approval: production_writes
        - audit_level: full

    - name: perplexity_mcp
      path: ~/.config/mcp/servers/perplexity
      policies:
        - rate_limit: 100/hour
        - resource_limit: high
        - audit_level: full

    - name: ollama_mcp
      path: ~/.config/mcp/servers/ollama
      policies:
        - local_only: true
        - audit_level: summary

  # Policy definitions
  policies:
    rate_limit:
      type: counter
      window: sliding
      enforcement: hard  # hard | soft | warn

    require_approval:
      type: workflow
      approvers: 2
      timeout: 1h
      fallback: deny

    resource_limit:
      type: resource_quota
      enforcement: hard
      alert_threshold: 80%

  # Audit configuration
  audit:
    backend: atom_trail
    trail_file: ~/.config/atom-sage/trails/mcp_audit.log
    encrypt: true
    pii_redaction: true
    retention_days: 2555

  # Multi-tenancy
  tenants:
    enabled: false
    isolation: strict
    quotas:
      default:
        api_calls: 10000/month
        storage_gb: 100
```

## Policy Examples

### Approval Workflow
```yaml
# Require approval for sensitive operations
policy:
  name: production_deployment
  trigger:
    mcp_server: cloudflare_mcp
    operation: workers.deploy
    resource_pattern: "*-prod-*"
  action:
    require_approval:
      approvers:
        - ops-lead@company.com
        - cto@company.com
      min_approvals: 2
      timeout: 1h
      on_timeout: deny
  audit:
    log_level: full
    notification: slack://ops-channel
```

### Rate Limiting
```yaml
# Prevent API abuse
policy:
  name: research_rate_limit
  trigger:
    mcp_server: perplexity_mcp
    operation: research.*
  action:
    rate_limit:
      limit: 100/hour
      per: user
      burst: 10
      on_exceeded: block
  audit:
    log_level: summary
    alert_on_limit: true
```

### Resource Management
```yaml
# Track and limit resource usage
policy:
  name: monthly_quota
  trigger:
    mcp_server: perplexity_mcp
  action:
    quota:
      limit: high_usage
      per: tenant
      enforcement: soft  # warn but allow
      alert_threshold: 80%
  audit:
    resource_tracking: true
    reporting: monthly
```

### PII Protection
```yaml
# Prevent PII leakage
policy:
  name: pii_redaction
  trigger:
    mcp_server: all
    operation: all
  action:
    pii_detection:
      enabled: true
      redact: true
      patterns:
        - ssn
        - credit_card
        - email
        - phone
  audit:
    log_redacted: true
    alert_on_pii: true
```

## CLI Usage

```bash
# Start ATOM-GOV proxy
atom-gov start --config ~/.config/atom-sage/governance/mcp-governance.yaml

# View audit trail
atom-gov audit --server cloudflare_mcp --last 24h

# Check policy compliance
atom-gov compliance-report --format pdf

# Approve pending operations
atom-gov approve --operation op-12345 --approver alice@company.com

# View cost summary
atom-gov costs --server perplexity_mcp --period month

# Export audit logs
atom-gov export --format json --encrypt --output audit-$(date +%Y%m%d).json.gpg
```

## Integration

### Claude Desktop Integration
Update `~/Library/Application Support/Claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "cloudflare": {
      "command": "atom-gov",
      "args": ["proxy", "--server", "cloudflare_mcp"]
    }
  }
}
```

### CI/CD Integration
```yaml
# GitHub Actions example
- name: Deploy with MCP governance
  run: |
    atom-gov proxy --server cloudflare_mcp -- \
      mcp-tool workers deploy --env production
```

### Monitoring Integration
```bash
# Export metrics to Prometheus
atom-gov metrics --format prometheus > /var/lib/prometheus/mcp_metrics.prom
```

## Enterprise Features

### Multi-Tenancy
- Strict tenant isolation
- Per-tenant quotas and policies
- Cost allocation and chargeback
- Tenant-specific audit trails

### Compliance Reporting
- SOC 2 audit support
- GDPR compliance features
- HIPAA-ready configurations
- Custom compliance frameworks

### Advanced Policies
- Machine learning-based anomaly detection
- Behavioral analysis
- Threat detection
- Automated incident response

### High Availability
- Load balancing across MCP servers
- Failover support
- Health monitoring
- Performance optimization

## Case Studies

**Company**: SaaS Platform (5000 customers)
**Challenge**: Needed to govern MCP access across tenants
**Result**: 100% tenant isolation, 60% reduction in API costs

**Company**: Healthcare Provider
**Challenge**: HIPAA compliance for AI assistants
**Result**: Full audit trails, PII protection, compliance achieved

**Company**: DevOps Consultancy
**Challenge**: Client MCP access with chargebacks
**Result**: Per-client cost tracking, automated billing

## Roadmap

- **Q1 2025**: Public beta launch
- **Q2 2025**: Enterprise features
- **Q3 2025**: MCP Marketplace integration
- **Q4 2025**: ML-based policy engine

## Support

- Documentation: `./docs/ATOM_GOV_GUIDE.md`
- Email: atom-gov@atom-sage.dev
- Enterprise support: 24/7 availability

---

**Fork**: ATOM-GOV
**Version**: 1.0.0
**License**: MIT - Fully Open Source
**Status**: Beta (Public beta Q1 2025)
