---
name: {{agent-name}}
description: >
  {{agent-description}}. Triggers when {{trigger-conditions}}.
metadata:
  version: "1.0.0"
  tier: {{tier}}
  capability_class: {{capability-class}}
  maf:
    triangle_role: {{triangle-role}}
    kernel_plugin: {{kernel-plugin}}
    kernel_function: {{kernel-function}}
  runtime:
    domain_config: domain_config.json
---

# {{agent-name}} — {{agent-title}}

{{agent-purpose-statement}}

---

## ⚖️ Colony Laws Observed

| Law | ID | This Agent's Obligation |
|:----|:---|:------------------------|
| Atomic Content Protocol | EC-SYS-001 | {{ec-sys-001-obligation}} |
| Minimalist Planning | EC-SYS-002 | {{ec-sys-002-obligation}} |

---

## 🏗️ Domain Identity

| Phase | Generic | This Agent's Action |
|:------|:--------|:--------------------|
| **P** | Planner | {{planner-action}} |
| **M** | Maker | {{maker-action}} |
| **C** | Checker | {{checker-action}} |
| **R** | Reflector | {{reflector-action}} |

---

## 🔄 Operating Procedure

{{operating-procedure}}

---

## 🏷️ Domain Actions

| Action ID | Description |
|:----------|:------------|
{{domain-actions-table}}

---

## 🛑 Termination Condition

{{termination-condition}}

---

## 📎 Reference Files

| File | When to Read |
|:-----|:-------------|
{{reference-files-table}}
