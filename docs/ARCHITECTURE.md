# Architecture Blueprint

## Control model

Owner -> AI Pusat -> Company Agent -> Division Manager -> Specialist Agent -> Worker / Automation.

The owner should normally interact only with goals, approvals, budgets, summaries, and exceptions. Technical configuration exists as an Advanced/backup path.

## Digital office per company

Each company is a visible workspace containing:

- strategy and goals
- divisions and specialists
- tasks and schedules
- KPI and analytics
- connectors
- budget and spending proposals
- approvals
- audit log
- knowledge and lessons

## Default divisions

### Website
SEO & Keyword Research, Content Publishing, Search Console & Indexing, Web Analytics, Technical SEO, Conversion/CRO, Website Maintenance.

### Social Media
Content Planning, Trend Research, Creative, Publishing, Community, Social Analytics.

### Marketing
Campaign Strategy, Ads, Offers.

### CRM & Sales
Lead Management, Follow Up, Cross Sell.

### WhatsApp
Human Conversation, Automation, Outreach.

### Finance
Budget, Capital Allocation, Finance Analytics.

### Research
Market Research, Opportunity Discovery.

### Engineering
Website Coding, Workflow Engineering, Integrations, AI System Improvement.

## Goal lifecycle

1. Owner gives a business objective.
2. AI Pusat identifies the company and relevant divisions.
3. Planner decomposes the goal into tasks.
4. Policy engine classifies risk, external side effects, and cost.
5. Safe internal work can queue automatically.
6. Purchase, spending, external publish/send, production change, and high-risk work generate owner approval.
7. Workers execute through connected tools.
8. Results are measured against KPI.
9. Lessons go into company knowledge.
10. Self-improvement may propose better workflows or code.

## AI cost strategy

- Deterministic code for scheduling, status checks, calculations, dedupe, routing, retries, and repetitive ETL.
- Fast/cheap model for classification, extraction, tagging, summarization.
- Strong reasoning model for planning, coding, and strategy.
- Premium model only for difficult/high-impact reasoning.
- Cache reusable outputs and avoid repeated prompts for unchanged inputs.

## Connector strategy

Connectors are capability adapters, not UI-only settings. Each connector has a company owner, scopes, endpoint, auth mode, secret reference, status, and audit history.

Secrets should live outside the mobile app and repository, ideally in a secret manager/Vault or environment injection on the VPS.

Initial connector families:

- Website / CMS
- GitHub
- WhatsApp Business
- Instagram / Facebook
- TikTok
- Google Search Console
- Google Analytics
- Domain / DNS
- Hosting / VPS
- Email
- Payments

When no official API is available, a browser-agent adapter can be added, but official APIs are preferred for reliability and account safety.

## Self-improvement

The system should improve its process without blindly rewriting itself in production.

Loop:

Observe -> Analyze -> Propose -> Sandbox/Test -> Approve when needed -> Deploy -> Measure -> Learn.

Low-risk workflow optimizations may later be auto-deployed if tests and rollback checks pass. Security, credentials, spending, destructive changes, production infrastructure, and sensitive customer actions stay behind stronger gates.

## VPS deployment principle

Goyana Laundry and AI Foundation Agentic may share one VPS initially, but must remain separate Docker stacks, networks, environment files, storage, and databases. This makes later migration to a dedicated Agentic VPS straightforward.

## Android role

Android is the remote control, not the brain. It shows:

- what AI is doing
- company status
- approvals
- connectors
- KPI and notifications
- audit history
- emergency controls
- text/voice commands to AI Pusat

The backend on VPS remains the source of truth for orchestration and data.
