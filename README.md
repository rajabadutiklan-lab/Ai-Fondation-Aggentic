# AI Foundation Agentic

AI Business OS / Agentic Control Center untuk mengelola banyak perusahaan dari satu AI Pusat.

## Prinsip utama

- **Automatic First**: owner cukup memberi tujuan, AI mengurus alur teknis.
- **Approval When Needed**: pembelian, biaya, publikasi eksternal, perubahan produksi, dan aksi berisiko berhenti di Approval Center.
- **Manual as Backup**: konektor, API, token reference, webhook, dan detail teknis tetap tersedia bila dibutuhkan.
- **Human-readable Operations**: dashboard menampilkan progres bisnis, bukan log teknis mentah.
- **Company Isolation**: setiap perusahaan punya Company Agent, divisi, specialist, konektor, budget, dan audit trail sendiri.
- **Safe Self-Improvement**: AI boleh mengusulkan peningkatan sistem, tetapi perubahan berisiko tetap melewati kontrol owner.
- **Cost-aware AI Router**: task ringan diarahkan ke model hemat, reasoning berat ke model yang lebih kuat.

## Hierarki

`AI Pusat -> Company Agent -> Division Manager -> Specialist Agent -> Worker / Automation`

## Foundation v3

Backend sekarang menyediakan:

- Company workspace dan auto-bootstrap struktur divisi.
- Website, Social Media, Marketing, CRM & Sales, WhatsApp, Finance, Research, dan Engineering.
- Specialist untuk SEO, publishing, Search Console, analytics, CRO, creative, outreach, capital allocation, coding, workflow engineering, integration, dan AI system improvement.
- Goal planner yang memecah tujuan menjadi task.
- Risk policy dan Approval Center.
- Emergency Pause.
- Connector Center: website/CMS, GitHub, WhatsApp, Meta, TikTok, Search Console, Analytics, domain/DNS, hosting/VPS, email, payments.
- AI Model Router berbasis kompleksitas/risiko.
- Self-Improvement Queue.
- Audit Log.
- Dashboard API.

Android Flutter Control Center sekarang memiliki 5 area utama:

1. Beranda / AI Pusat.
2. Perusahaan.
3. Approval Center.
4. Konektor.
5. Sistem AI.

APK mempunyai **Preview Offline** agar desain dan alur dapat diperiksa di HP walaupun backend VPS belum dipasang. Ketika backend terhubung, tombol aksi memakai API sungguhan.

## Struktur repo

- `mobile/` — Flutter Android Control Center.
- `server/` — FastAPI control plane.
- `docker-compose.yml` — stack VPS terisolasi.
- `docs/` — blueprint dan aturan sistem.
- `.github/workflows/` — backend tests, Flutter analyze, build APK, artifact.

## Batas foundation saat ini

Foundation v3 adalah control plane dan arsitektur kerja. Eksekusi nyata ke provider eksternal tetap membutuhkan credential/API resmi masing-masing provider dan worker connector yang sesuai. Secret tidak boleh ditaruh langsung di aplikasi; sistem memakai `credential_ref` untuk mengarah ke secret manager/Vault.

Repo ini **khusus AI Foundation Agentic**. Repo aplikasi Goyana Laundry tidak disentuh.
