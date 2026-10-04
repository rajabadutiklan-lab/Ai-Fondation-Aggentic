# AI Foundation Agentic

AI Business OS / Agentic Control Center.

## Prinsip utama

- **Automatic First**: pengguna cukup memberi tujuan, AI mengurus alur teknis.
- **Approval When Needed**: pembelian, biaya, perubahan berisiko, dan tindakan sensitif berhenti di Approval Center.
- **Manual as Backup**: konektor, API, token, webhook, dan detail teknis tetap tersedia di mode Advanced.
- **Human-readable Operations**: pengguna melihat progres bisnis, bukan log teknis mentah.
- **Company Isolation**: setiap perusahaan punya Company Agent, resource, konektor, budget, dan audit trail sendiri.
- **Safe Self-Improvement**: agent boleh mengusulkan/perbaiki workflow atau kode, tetapi perubahan harus diuji dan mengikuti policy/approval.

## Struktur

- `mobile/` — Flutter Android Control Center.
- `server/` — Backend FastAPI + worker, PostgreSQL, Redis, siap Docker/VPS.
- `docs/` — arsitektur, aturan agent, deployment, dan roadmap.
- `.github/workflows/` — CI build APK dan validasi backend.

## Hierarki agent

`AI Pusat -> Company Agent -> Division Manager -> Specialist Agent -> Worker/Automation`

## Modul inti

Control Center, Companies, Divisions, Agents, Tasks, Approval Center, Budget, KPI, Analytics, Connector Center, Automation, Audit Log, AI Model Router, Manual Override, Emergency Pause, and Self-Improvement Queue.

## Status

Fondasi awal. Repo ini khusus AI Foundation Agentic dan tidak bercampur dengan aplikasi Goyana Laundry.
