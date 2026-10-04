from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from uuid import UUID, uuid4

from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel, Field

app = FastAPI(
    title="AI Foundation Agentic API",
    version="0.3.0",
    description="Control plane for the Goyana AI Business OS.",
)


class GoalStatus(str, Enum):
    queued = "queued"
    planning = "planning"
    waiting_approval = "waiting_approval"
    running = "running"
    completed = "completed"
    failed = "failed"


class WorkStatus(str, Enum):
    queued = "queued"
    waiting_approval = "waiting_approval"
    running = "running"
    completed = "completed"
    failed = "failed"
    cancelled = "cancelled"


class ApprovalStatus(str, Enum):
    pending = "pending"
    approved = "approved"
    rejected = "rejected"


class RiskLevel(str, Enum):
    low = "low"
    medium = "medium"
    high = "high"
    critical = "critical"


class ConnectorStatus(str, Enum):
    not_configured = "not_configured"
    configured = "configured"
    needs_attention = "needs_attention"
    disabled = "disabled"


class ImprovementStatus(str, Enum):
    proposed = "proposed"
    approved = "approved"
    rejected = "rejected"
    implemented = "implemented"


class CompanyCreate(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    slug: str = Field(min_length=2, max_length=120)
    objective: str = Field(default="", max_length=1000)
    monthly_budget: float = Field(default=0, ge=0)


class Company(BaseModel):
    id: str
    name: str
    slug: str
    objective: str
    monthly_budget: float
    active: bool = True
    created_at: datetime


class DivisionCreate(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    purpose: str = Field(default="", max_length=1000)
    monthly_budget: float = Field(default=0, ge=0)


class Division(BaseModel):
    id: UUID
    company_id: str
    name: str
    purpose: str
    monthly_budget: float
    active: bool = True
    created_at: datetime


class SpecialistCreate(BaseModel):
    name: str = Field(min_length=2, max_length=120)
    capability: str = Field(min_length=2, max_length=500)


class Specialist(BaseModel):
    id: UUID
    division_id: UUID
    name: str
    capability: str
    active: bool = True
    created_at: datetime


class GoalCreate(BaseModel):
    objective: str = Field(min_length=3, max_length=2000)
    company_id: str = Field(default="default-company", min_length=1, max_length=120)
    requires_budget_approval: bool = False


class Goal(BaseModel):
    id: UUID
    objective: str
    company_id: str
    status: GoalStatus
    requires_budget_approval: bool
    created_at: datetime


class TaskCreate(BaseModel):
    title: str = Field(min_length=3, max_length=300)
    company_id: str = Field(min_length=1, max_length=120)
    division_id: UUID | None = None
    specialist_id: UUID | None = None
    goal_id: UUID | None = None
    risk_level: RiskLevel = RiskLevel.low
    estimated_cost: float = Field(default=0, ge=0)
    action_type: str = Field(default="internal", max_length=120)


class Task(BaseModel):
    id: UUID
    title: str
    company_id: str
    division_id: UUID | None
    specialist_id: UUID | None
    goal_id: UUID | None
    risk_level: RiskLevel
    estimated_cost: float
    action_type: str
    status: WorkStatus
    approval_id: UUID | None = None
    created_at: datetime


class Approval(BaseModel):
    id: UUID
    task_id: UUID
    reason: str
    risk_level: RiskLevel
    estimated_cost: float
    status: ApprovalStatus
    created_at: datetime
    resolved_at: datetime | None = None
    note: str = ""


class ApprovalDecision(BaseModel):
    approved: bool
    note: str = Field(default="", max_length=1000)


class PauseRequest(BaseModel):
    paused: bool
    reason: str = Field(default="Manual control from owner", max_length=500)


class AutonomyPolicy(BaseModel):
    auto_execute_low_risk: bool = True
    auto_execute_medium_risk: bool = True
    approval_for_high_risk: bool = True
    approval_for_external_publish: bool = True
    approval_for_purchases: bool = True
    approval_cost_threshold: float = Field(default=1, ge=0)
    max_auto_task_cost: float = Field(default=0, ge=0)


class ConnectorCreate(BaseModel):
    company_id: str = Field(min_length=1, max_length=120)
    kind: str = Field(min_length=2, max_length=80)
    name: str = Field(min_length=2, max_length=120)
    endpoint: str = Field(default="", max_length=500)
    auth_mode: str = Field(default="api_key", max_length=80)
    credential_ref: str = Field(default="", max_length=250)
    scopes: list[str] = Field(default_factory=list)
    enabled: bool = True


class Connector(BaseModel):
    id: UUID
    company_id: str
    kind: str
    name: str
    endpoint: str
    auth_mode: str
    credential_ref: str
    scopes: list[str]
    enabled: bool
    status: ConnectorStatus
    last_checked_at: datetime | None = None
    created_at: datetime


class Provider(BaseModel):
    id: str
    name: str
    purpose: str
    cost_tier: str
    capability_tier: str
    enabled: bool = True


class RouteResult(BaseModel):
    task_type: str
    provider_id: str
    reason: str


class ImprovementCreate(BaseModel):
    title: str = Field(min_length=3, max_length=250)
    description: str = Field(min_length=3, max_length=2000)
    risk_level: RiskLevel = RiskLevel.low
    expected_benefit: str = Field(default="", max_length=1000)


class ImprovementProposal(BaseModel):
    id: UUID
    title: str
    description: str
    risk_level: RiskLevel
    expected_benefit: str
    status: ImprovementStatus
    created_at: datetime
    resolved_at: datetime | None = None


class ImprovementDecision(BaseModel):
    approved: bool


class AuditEvent(BaseModel):
    id: UUID
    event_type: str
    message: str
    company_id: str | None = None
    created_at: datetime


class SystemState(BaseModel):
    paused: bool
    pause_reason: str | None
    active_goals: int
    active_tasks: int
    pending_approvals: int
    companies: int
    connectors: int
    improvements: int
    hierarchy: list[str]


class CompanyHierarchy(BaseModel):
    company: Company
    divisions: list[Division]
    specialists: list[Specialist]


class Dashboard(BaseModel):
    system: SystemState
    queued_tasks: int
    configured_connectors: int
    recent_events: list[AuditEvent]
    autonomy_policy: AutonomyPolicy


class PlanResult(BaseModel):
    goal: Goal
    tasks: list[Task]
    approvals_created: int


_goals: dict[UUID, Goal] = {}
_companies: dict[str, Company] = {}
_divisions: dict[UUID, Division] = {}
_specialists: dict[UUID, Specialist] = {}
_tasks: dict[UUID, Task] = {}
_approvals: dict[UUID, Approval] = {}
_connectors: dict[UUID, Connector] = {}
_improvements: dict[UUID, ImprovementProposal] = {}
_audit: list[AuditEvent] = []
_paused = False
_pause_reason: str | None = None
_policy = AutonomyPolicy()

_PROVIDER_REGISTRY = [
    Provider(id="fast", name="Fast Model", purpose="classification, extraction, summaries", cost_tier="low", capability_tier="light"),
    Provider(id="reasoning", name="Reasoning Model", purpose="planning, coding, strategy", cost_tier="medium", capability_tier="strong"),
    Provider(id="premium", name="Premium Model", purpose="high-impact decisions and difficult work", cost_tier="high", capability_tier="maximum"),
]

_CONNECTOR_CATALOG = [
    {"kind": "website", "name": "Website / CMS", "auth_modes": ["api_key", "basic", "oauth", "browser_agent"]},
    {"kind": "github", "name": "GitHub", "auth_modes": ["oauth", "token"]},
    {"kind": "whatsapp", "name": "WhatsApp Business", "auth_modes": ["api_key", "oauth"]},
    {"kind": "meta", "name": "Instagram & Facebook", "auth_modes": ["oauth"]},
    {"kind": "tiktok", "name": "TikTok", "auth_modes": ["oauth"]},
    {"kind": "google_search_console", "name": "Google Search Console", "auth_modes": ["oauth", "service_account"]},
    {"kind": "google_analytics", "name": "Google Analytics", "auth_modes": ["oauth", "service_account"]},
    {"kind": "domain_dns", "name": "Domain & DNS", "auth_modes": ["api_key", "oauth", "browser_agent"]},
    {"kind": "hosting", "name": "Hosting / VPS", "auth_modes": ["api_key", "ssh", "browser_agent"]},
    {"kind": "email", "name": "Email", "auth_modes": ["oauth", "smtp"]},
    {"kind": "payments", "name": "Payments", "auth_modes": ["api_key", "oauth"]},
]

_DIVISION_TEMPLATE = [
    ("Website", "Build, maintain and improve company websites", [
        ("SEO & Keyword Research", "keyword research, local SEO and ranking strategy"),
        ("Content Publishing", "content planning and scheduled publishing"),
        ("Search Console & Indexing", "indexing health and search visibility"),
        ("Web Analytics", "traffic, attribution and performance analysis"),
        ("Technical SEO", "performance, schema, crawlability and technical fixes"),
        ("Conversion / CRO", "conversion optimization and experiments"),
        ("Website Maintenance", "availability, updates, backups and fixes"),
    ]),
    ("Social Media", "Plan, publish, grow and analyze social channels", [
        ("Content Planning", "content calendar and campaign planning"),
        ("Trend Research", "keyword, hashtag and trend research"),
        ("Creative", "image, video and creative production briefs"),
        ("Publishing", "scheduling and publishing through official connectors"),
        ("Community", "comments, inbox and community workflows"),
        ("Social Analytics", "channel performance and growth analysis"),
    ]),
    ("Marketing", "Demand generation, campaigns and capital-efficient growth", [
        ("Campaign Strategy", "campaign planning and channel selection"),
        ("Ads", "paid media planning, optimization and measurement"),
        ("Offers", "offer design, pricing tests and promotion planning"),
    ]),
    ("CRM & Sales", "Manage leads, customers and follow-up", [
        ("Lead Management", "pipeline, scoring and lead routing"),
        ("Follow Up", "timely, contextual customer follow-up"),
        ("Cross Sell", "relevant cross-sell and upsell opportunities"),
    ]),
    ("WhatsApp", "Customer conversation and compliant outreach", [
        ("Human Conversation", "concise, contextual and non-repetitive conversation"),
        ("Automation", "trigger, template and workflow automation"),
        ("Outreach", "permission-aware targeted outreach"),
    ]),
    ("Finance", "Budget, cash flow and capital allocation", [
        ("Budget", "budget planning and guardrails"),
        ("Capital Allocation", "reinvestment and capital allocation proposals"),
        ("Finance Analytics", "revenue, cost and profitability analysis"),
    ]),
    ("Research", "Market, competitor and opportunity research", [
        ("Market Research", "market sizing, competitor and customer research"),
        ("Opportunity Discovery", "new business and expansion opportunity discovery"),
    ]),
    ("Engineering", "Build software, integrations and automation", [
        ("Website Coding", "website and web application engineering"),
        ("Workflow Engineering", "deterministic workflows, queues, retries and fallbacks"),
        ("Integrations", "API, webhook and connector engineering"),
        ("AI System Improvement", "safe continuous improvement of the agentic system"),
    ]),
]


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


def audit(event_type: str, message: str, company_id: str | None = None) -> None:
    _audit.append(AuditEvent(id=uuid4(), event_type=event_type, message=message, company_id=company_id, created_at=utc_now()))
    if len(_audit) > 500:
        del _audit[:100]


def ensure_company(company_id: str) -> Company:
    company = _companies.get(company_id)
    if company is None:
        company = Company(
            id=company_id,
            name=company_id.replace("-", " ").title(),
            slug=company_id,
            objective="Auto-provisioned company workspace",
            monthly_budget=0,
            created_at=utc_now(),
        )
        _companies[company_id] = company
        audit("company.auto_created", f"Company workspace {company.name} dibuat otomatis", company_id)
    return company


def task_requires_approval(payload: TaskCreate) -> bool:
    if payload.risk_level in {RiskLevel.high, RiskLevel.critical} and _policy.approval_for_high_risk:
        return True
    if payload.estimated_cost >= _policy.approval_cost_threshold and payload.estimated_cost > _policy.max_auto_task_cost:
        return True
    action = payload.action_type.lower()
    if _policy.approval_for_purchases and action in {"purchase", "payment", "domain_purchase", "hosting_purchase"}:
        return True
    if _policy.approval_for_external_publish and action in {"publish", "send_message", "campaign_send", "production_change"}:
        return True
    return False


def create_task_internal(payload: TaskCreate) -> Task:
    needs_approval = task_requires_approval(payload)
    task = Task(
        id=uuid4(),
        title=payload.title.strip(),
        company_id=payload.company_id,
        division_id=payload.division_id,
        specialist_id=payload.specialist_id,
        goal_id=payload.goal_id,
        risk_level=payload.risk_level,
        estimated_cost=payload.estimated_cost,
        action_type=payload.action_type,
        status=WorkStatus.waiting_approval if needs_approval else WorkStatus.queued,
        created_at=utc_now(),
    )
    _tasks[task.id] = task
    if needs_approval:
        approval = Approval(
            id=uuid4(),
            task_id=task.id,
            reason="Policy requires owner approval before this action can run",
            risk_level=task.risk_level,
            estimated_cost=task.estimated_cost,
            status=ApprovalStatus.pending,
            created_at=utc_now(),
        )
        _approvals[approval.id] = approval
        task.approval_id = approval.id
        _tasks[task.id] = task
        audit("approval.created", f"Approval dibuat untuk task: {task.title}", task.company_id)
    audit("task.created", f"Task dibuat: {task.title}", task.company_id)
    return task


ensure_company("default-company")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "ai-foundation-agentic", "version": "0.3.0"}


@app.get("/v1/system", response_model=SystemState)
def system_state() -> SystemState:
    return SystemState(
        paused=_paused,
        pause_reason=_pause_reason,
        active_goals=sum(1 for goal in _goals.values() if goal.status not in {GoalStatus.completed, GoalStatus.failed}),
        active_tasks=sum(1 for task in _tasks.values() if task.status not in {WorkStatus.completed, WorkStatus.failed, WorkStatus.cancelled}),
        pending_approvals=sum(1 for item in _approvals.values() if item.status == ApprovalStatus.pending),
        companies=len(_companies),
        connectors=len(_connectors),
        improvements=sum(1 for item in _improvements.values() if item.status == ImprovementStatus.proposed),
        hierarchy=["AI Pusat", "Company Agent", "Division Manager", "Specialist Agent", "Worker / Automation"],
    )


@app.get("/v1/dashboard", response_model=Dashboard)
def dashboard() -> Dashboard:
    return Dashboard(
        system=system_state(),
        queued_tasks=sum(1 for task in _tasks.values() if task.status == WorkStatus.queued),
        configured_connectors=sum(1 for item in _connectors.values() if item.status == ConnectorStatus.configured),
        recent_events=list(reversed(_audit[-10:])),
        autonomy_policy=_policy,
    )


@app.post("/v1/companies", response_model=Company, status_code=201)
def create_company(payload: CompanyCreate) -> Company:
    company_id = payload.slug.strip().lower().replace(" ", "-")
    if company_id in _companies:
        raise HTTPException(status_code=409, detail="Company already exists")
    company = Company(
        id=company_id,
        name=payload.name.strip(),
        slug=company_id,
        objective=payload.objective.strip(),
        monthly_budget=payload.monthly_budget,
        created_at=utc_now(),
    )
    _companies[company.id] = company
    audit("company.created", f"Company {company.name} dibuat", company.id)
    return company


@app.get("/v1/companies", response_model=list[Company])
def list_companies() -> list[Company]:
    return sorted(_companies.values(), key=lambda item: item.created_at)


@app.post("/v1/companies/{company_id}/bootstrap", response_model=CompanyHierarchy)
def bootstrap_company(company_id: str) -> CompanyHierarchy:
    company = ensure_company(company_id)
    if not any(item.company_id == company_id for item in _divisions.values()):
        for division_name, purpose, specialists in _DIVISION_TEMPLATE:
            division = Division(id=uuid4(), company_id=company_id, name=division_name, purpose=purpose, monthly_budget=0, created_at=utc_now())
            _divisions[division.id] = division
            for specialist_name, capability in specialists:
                specialist = Specialist(id=uuid4(), division_id=division.id, name=specialist_name, capability=capability, created_at=utc_now())
                _specialists[specialist.id] = specialist
        audit("company.bootstrapped", f"Struktur divisi otomatis dibuat untuk {company.name}", company_id)
    return company_hierarchy(company_id)


@app.post("/v1/companies/{company_id}/divisions", response_model=Division, status_code=201)
def create_division(company_id: str, payload: DivisionCreate) -> Division:
    ensure_company(company_id)
    division = Division(id=uuid4(), company_id=company_id, name=payload.name.strip(), purpose=payload.purpose.strip(), monthly_budget=payload.monthly_budget, created_at=utc_now())
    _divisions[division.id] = division
    audit("division.created", f"Divisi {division.name} dibuat", company_id)
    return division


@app.post("/v1/divisions/{division_id}/specialists", response_model=Specialist, status_code=201)
def create_specialist(division_id: UUID, payload: SpecialistCreate) -> Specialist:
    division = _divisions.get(division_id)
    if division is None:
        raise HTTPException(status_code=404, detail="Division not found")
    specialist = Specialist(id=uuid4(), division_id=division_id, name=payload.name.strip(), capability=payload.capability.strip(), created_at=utc_now())
    _specialists[specialist.id] = specialist
    audit("specialist.created", f"Specialist {specialist.name} dibuat", division.company_id)
    return specialist


@app.get("/v1/companies/{company_id}/hierarchy", response_model=CompanyHierarchy)
def company_hierarchy(company_id: str) -> CompanyHierarchy:
    company = _companies.get(company_id)
    if company is None:
        raise HTTPException(status_code=404, detail="Company not found")
    divisions = [item for item in _divisions.values() if item.company_id == company_id]
    division_ids = {item.id for item in divisions}
    specialists = [item for item in _specialists.values() if item.division_id in division_ids]
    return CompanyHierarchy(company=company, divisions=divisions, specialists=specialists)


@app.post("/v1/goals", response_model=Goal, status_code=201)
def create_goal(payload: GoalCreate) -> Goal:
    if _paused:
        raise HTTPException(status_code=423, detail="System is paused. Resume the system before creating a new goal.")
    ensure_company(payload.company_id)
    goal = Goal(
        id=uuid4(),
        objective=payload.objective.strip(),
        company_id=payload.company_id,
        status=GoalStatus.waiting_approval if payload.requires_budget_approval else GoalStatus.queued,
        requires_budget_approval=payload.requires_budget_approval,
        created_at=utc_now(),
    )
    _goals[goal.id] = goal
    audit("goal.created", f"Goal baru: {goal.objective}", goal.company_id)
    return goal


@app.get("/v1/goals", response_model=list[Goal])
def list_goals() -> list[Goal]:
    return sorted(_goals.values(), key=lambda goal: goal.created_at, reverse=True)


@app.get("/v1/goals/{goal_id}", response_model=Goal)
def get_goal(goal_id: UUID) -> Goal:
    goal = _goals.get(goal_id)
    if goal is None:
        raise HTTPException(status_code=404, detail="Goal not found")
    return goal


@app.post("/v1/goals/{goal_id}/plan", response_model=PlanResult)
def plan_goal(goal_id: UUID) -> PlanResult:
    if _paused:
        raise HTTPException(status_code=423, detail="System is paused")
    goal = _goals.get(goal_id)
    if goal is None:
        raise HTTPException(status_code=404, detail="Goal not found")
    if any(task.goal_id == goal_id for task in _tasks.values()):
        tasks = [task for task in _tasks.values() if task.goal_id == goal_id]
        return PlanResult(goal=goal, tasks=tasks, approvals_created=sum(1 for task in tasks if task.approval_id is not None))

    goal.status = GoalStatus.planning
    text = goal.objective.lower()
    blueprints: list[tuple[str, RiskLevel, str]] = [
        ("Riset konteks, pasar dan kebutuhan", RiskLevel.low, "research"),
        ("Susun strategi dan rencana kerja", RiskLevel.low, "planning"),
        ("Siapkan implementasi", RiskLevel.medium, "internal"),
        ("Quality check dan verifikasi", RiskLevel.low, "qa"),
        ("Pasang pengukuran hasil dan KPI", RiskLevel.low, "analytics"),
    ]
    if any(word in text for word in ["website", "web ", "landing page", "domain", "hosting"]):
        blueprints.extend([
            ("Riset nama domain dan ketersediaan", RiskLevel.low, "research"),
            ("Siapkan website dan deployment", RiskLevel.medium, "production_change"),
            ("Pembelian domain/hosting bila diperlukan", RiskLevel.high, "purchase"),
            ("SEO, analytics dan indexing", RiskLevel.low, "internal"),
        ])
    if any(word in text for word in ["instagram", "facebook", "tiktok", "sosmed", "social media"]):
        blueprints.extend([
            ("Siapkan strategi konten social media", RiskLevel.low, "planning"),
            ("Siapkan kalender dan materi konten", RiskLevel.low, "internal"),
            ("Publikasi konten setelah verifikasi", RiskLevel.medium, "publish"),
        ])
    if any(word in text for word in ["whatsapp", "wa ", "blast", "customer", "pelanggan"]):
        blueprints.extend([
            ("Segmentasi customer dan aturan relevansi", RiskLevel.low, "internal"),
            ("Siapkan percakapan/follow-up kontekstual", RiskLevel.low, "internal"),
            ("Kirim pesan hanya setelah policy terpenuhi", RiskLevel.medium, "send_message"),
        ])
    if any(word in text for word in ["beli", "bayar", "modal", "invest", "anggaran", "budget"]):
        blueprints.append(("Siapkan proposal biaya dan keputusan modal", RiskLevel.high, "payment"))

    tasks = [
        create_task_internal(TaskCreate(title=title, company_id=goal.company_id, goal_id=goal.id, risk_level=risk, action_type=action))
        for title, risk, action in blueprints
    ]
    goal.status = GoalStatus.waiting_approval if any(task.status == WorkStatus.waiting_approval for task in tasks) else GoalStatus.running
    _goals[goal.id] = goal
    audit("goal.planned", f"AI Pusat memecah goal menjadi {len(tasks)} task", goal.company_id)
    return PlanResult(goal=goal, tasks=tasks, approvals_created=sum(1 for task in tasks if task.approval_id is not None))


@app.post("/v1/tasks", response_model=Task, status_code=201)
def create_task(payload: TaskCreate) -> Task:
    if _paused:
        raise HTTPException(status_code=423, detail="System is paused")
    ensure_company(payload.company_id)
    if payload.division_id is not None and payload.division_id not in _divisions:
        raise HTTPException(status_code=404, detail="Division not found")
    if payload.specialist_id is not None and payload.specialist_id not in _specialists:
        raise HTTPException(status_code=404, detail="Specialist not found")
    if payload.goal_id is not None and payload.goal_id not in _goals:
        raise HTTPException(status_code=404, detail="Goal not found")
    return create_task_internal(payload)


@app.get("/v1/tasks", response_model=list[Task])
def list_tasks(status: WorkStatus | None = Query(default=None)) -> list[Task]:
    items = list(_tasks.values())
    if status is not None:
        items = [item for item in items if item.status == status]
    return sorted(items, key=lambda item: item.created_at, reverse=True)


@app.get("/v1/approvals", response_model=list[Approval])
def list_approvals(status: ApprovalStatus | None = Query(default=None)) -> list[Approval]:
    items = list(_approvals.values())
    if status is not None:
        items = [item for item in items if item.status == status]
    return sorted(items, key=lambda item: item.created_at, reverse=True)


@app.post("/v1/approvals/{approval_id}/decision", response_model=Approval)
def decide_approval(approval_id: UUID, payload: ApprovalDecision) -> Approval:
    approval = _approvals.get(approval_id)
    if approval is None:
        raise HTTPException(status_code=404, detail="Approval not found")
    if approval.status != ApprovalStatus.pending:
        raise HTTPException(status_code=409, detail="Approval already resolved")
    approval.status = ApprovalStatus.approved if payload.approved else ApprovalStatus.rejected
    approval.resolved_at = utc_now()
    approval.note = payload.note
    _approvals[approval.id] = approval
    task = _tasks[approval.task_id]
    task.status = WorkStatus.queued if payload.approved else WorkStatus.cancelled
    _tasks[task.id] = task
    audit("approval.resolved", f"Task {task.title}: {'disetujui' if payload.approved else 'ditolak'}", task.company_id)
    return approval


@app.get("/v1/connectors/catalog")
def connector_catalog() -> list[dict[str, object]]:
    return _CONNECTOR_CATALOG


@app.get("/v1/connectors", response_model=list[Connector])
def list_connectors(company_id: str | None = Query(default=None)) -> list[Connector]:
    items = list(_connectors.values())
    if company_id:
        items = [item for item in items if item.company_id == company_id]
    return sorted(items, key=lambda item: item.created_at, reverse=True)


@app.post("/v1/connectors", response_model=Connector, status_code=201)
def create_connector(payload: ConnectorCreate) -> Connector:
    ensure_company(payload.company_id)
    connector = Connector(
        id=uuid4(),
        company_id=payload.company_id,
        kind=payload.kind,
        name=payload.name,
        endpoint=payload.endpoint,
        auth_mode=payload.auth_mode,
        credential_ref=payload.credential_ref,
        scopes=payload.scopes,
        enabled=payload.enabled,
        status=ConnectorStatus.configured if payload.credential_ref else ConnectorStatus.not_configured,
        created_at=utc_now(),
    )
    _connectors[connector.id] = connector
    audit("connector.created", f"Connector {connector.name} ditambahkan", connector.company_id)
    return connector


@app.post("/v1/connectors/{connector_id}/check", response_model=Connector)
def check_connector(connector_id: UUID) -> Connector:
    connector = _connectors.get(connector_id)
    if connector is None:
        raise HTTPException(status_code=404, detail="Connector not found")
    connector.last_checked_at = utc_now()
    connector.status = ConnectorStatus.disabled if not connector.enabled else (ConnectorStatus.configured if connector.credential_ref else ConnectorStatus.needs_attention)
    _connectors[connector.id] = connector
    audit("connector.checked", f"Connector {connector.name} diperiksa: {connector.status.value}", connector.company_id)
    return connector


@app.get("/v1/ai/providers", response_model=list[Provider])
def list_providers() -> list[Provider]:
    return _PROVIDER_REGISTRY


@app.get("/v1/ai/route", response_model=RouteResult)
def route_ai(task_type: str = Query(default="general"), risk_level: RiskLevel = Query(default=RiskLevel.low)) -> RouteResult:
    kind = task_type.lower()
    if risk_level in {RiskLevel.high, RiskLevel.critical} or kind in {"strategy", "coding", "legal", "finance_decision"}:
        provider = _PROVIDER_REGISTRY[-1] if risk_level == RiskLevel.critical else _PROVIDER_REGISTRY[1]
        reason = "Task membutuhkan reasoning lebih kuat"
    elif kind in {"classify", "extract", "summarize", "tag", "routine"}:
        provider = _PROVIDER_REGISTRY[0]
        reason = "Task ringan diarahkan ke model hemat biaya"
    else:
        provider = _PROVIDER_REGISTRY[1]
        reason = "Default balanced routing"
    return RouteResult(task_type=task_type, provider_id=provider.id, reason=reason)


@app.get("/v1/policies/autonomy", response_model=AutonomyPolicy)
def get_autonomy_policy() -> AutonomyPolicy:
    return _policy


@app.put("/v1/policies/autonomy", response_model=AutonomyPolicy)
def update_autonomy_policy(payload: AutonomyPolicy) -> AutonomyPolicy:
    global _policy
    _policy = payload
    audit("policy.updated", "Autonomy policy diperbarui")
    return _policy


@app.get("/v1/improvements", response_model=list[ImprovementProposal])
def list_improvements() -> list[ImprovementProposal]:
    return sorted(_improvements.values(), key=lambda item: item.created_at, reverse=True)


@app.post("/v1/improvements", response_model=ImprovementProposal, status_code=201)
def create_improvement(payload: ImprovementCreate) -> ImprovementProposal:
    proposal = ImprovementProposal(
        id=uuid4(),
        title=payload.title.strip(),
        description=payload.description.strip(),
        risk_level=payload.risk_level,
        expected_benefit=payload.expected_benefit.strip(),
        status=ImprovementStatus.proposed,
        created_at=utc_now(),
    )
    _improvements[proposal.id] = proposal
    audit("improvement.proposed", f"Self-improvement proposal: {proposal.title}")
    return proposal


@app.post("/v1/improvements/{proposal_id}/decision", response_model=ImprovementProposal)
def decide_improvement(proposal_id: UUID, payload: ImprovementDecision) -> ImprovementProposal:
    proposal = _improvements.get(proposal_id)
    if proposal is None:
        raise HTTPException(status_code=404, detail="Improvement proposal not found")
    if proposal.status != ImprovementStatus.proposed:
        raise HTTPException(status_code=409, detail="Improvement proposal already resolved")
    proposal.status = ImprovementStatus.approved if payload.approved else ImprovementStatus.rejected
    proposal.resolved_at = utc_now()
    _improvements[proposal.id] = proposal
    audit("improvement.resolved", f"Self-improvement {proposal.title}: {proposal.status.value}")
    return proposal


@app.get("/v1/audit", response_model=list[AuditEvent])
def list_audit(limit: int = Query(default=100, ge=1, le=500)) -> list[AuditEvent]:
    return list(reversed(_audit[-limit:]))


@app.post("/v1/emergency-pause", response_model=SystemState)
def set_emergency_pause(payload: PauseRequest) -> SystemState:
    global _paused, _pause_reason
    _paused = payload.paused
    _pause_reason = payload.reason if payload.paused else None
    audit("system.pause" if payload.paused else "system.resume", payload.reason)
    return system_state()
