from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from uuid import UUID, uuid4

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(
    title="AI Foundation Agentic API",
    version="0.2.0",
    description="Backend control plane for the AI Business OS.",
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
    requires_budget_approval: bool = True


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


class Task(BaseModel):
    id: UUID
    title: str
    company_id: str
    division_id: UUID | None
    specialist_id: UUID | None
    goal_id: UUID | None
    risk_level: RiskLevel
    estimated_cost: float
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


class ApprovalDecision(BaseModel):
    approved: bool
    note: str = Field(default="", max_length=1000)


class PauseRequest(BaseModel):
    paused: bool
    reason: str = Field(default="Manual control from owner", max_length=500)


class SystemState(BaseModel):
    paused: bool
    pause_reason: str | None
    active_goals: int
    active_tasks: int
    pending_approvals: int
    companies: int
    hierarchy: list[str]


class CompanyHierarchy(BaseModel):
    company: Company
    divisions: list[Division]
    specialists: list[Specialist]


_goals: dict[UUID, Goal] = {}
_companies: dict[str, Company] = {}
_divisions: dict[UUID, Division] = {}
_specialists: dict[UUID, Specialist] = {}
_tasks: dict[UUID, Task] = {}
_approvals: dict[UUID, Approval] = {}
_paused = False
_pause_reason: str | None = None


def utc_now() -> datetime:
    return datetime.now(timezone.utc)


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
    return company


def task_requires_approval(payload: TaskCreate) -> bool:
    return payload.risk_level in {RiskLevel.high, RiskLevel.critical} or payload.estimated_cost > 0


ensure_company("default-company")


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "ai-foundation-agentic", "version": "0.2.0"}


@app.get("/v1/system", response_model=SystemState)
def system_state() -> SystemState:
    return SystemState(
        paused=_paused,
        pause_reason=_pause_reason,
        active_goals=sum(
            1
            for goal in _goals.values()
            if goal.status not in {GoalStatus.completed, GoalStatus.failed}
        ),
        active_tasks=sum(
            1
            for task in _tasks.values()
            if task.status not in {WorkStatus.completed, WorkStatus.failed, WorkStatus.cancelled}
        ),
        pending_approvals=sum(1 for item in _approvals.values() if item.status == ApprovalStatus.pending),
        companies=len(_companies),
        hierarchy=[
            "AI Pusat",
            "Company Agent",
            "Division Manager",
            "Specialist Agent",
            "Worker / Automation",
        ],
    )


@app.post("/v1/companies", response_model=Company, status_code=201)
def create_company(payload: CompanyCreate) -> Company:
    company_id = payload.slug.strip().lower()
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
    return company


@app.get("/v1/companies", response_model=list[Company])
def list_companies() -> list[Company]:
    return sorted(_companies.values(), key=lambda item: item.created_at)


@app.post("/v1/companies/{company_id}/divisions", response_model=Division, status_code=201)
def create_division(company_id: str, payload: DivisionCreate) -> Division:
    ensure_company(company_id)
    division = Division(
        id=uuid4(),
        company_id=company_id,
        name=payload.name.strip(),
        purpose=payload.purpose.strip(),
        monthly_budget=payload.monthly_budget,
        created_at=utc_now(),
    )
    _divisions[division.id] = division
    return division


@app.post("/v1/divisions/{division_id}/specialists", response_model=Specialist, status_code=201)
def create_specialist(division_id: UUID, payload: SpecialistCreate) -> Specialist:
    if division_id not in _divisions:
        raise HTTPException(status_code=404, detail="Division not found")
    specialist = Specialist(
        id=uuid4(),
        division_id=division_id,
        name=payload.name.strip(),
        capability=payload.capability.strip(),
        created_at=utc_now(),
    )
    _specialists[specialist.id] = specialist
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
        raise HTTPException(
            status_code=423,
            detail="System is paused. Resume the system before creating a new goal.",
        )

    ensure_company(payload.company_id)
    goal = Goal(
        id=uuid4(),
        objective=payload.objective.strip(),
        company_id=payload.company_id,
        status=(
            GoalStatus.waiting_approval
            if payload.requires_budget_approval
            else GoalStatus.queued
        ),
        requires_budget_approval=payload.requires_budget_approval,
        created_at=utc_now(),
    )
    _goals[goal.id] = goal
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
        status=WorkStatus.waiting_approval if needs_approval else WorkStatus.queued,
        created_at=utc_now(),
    )
    _tasks[task.id] = task

    if needs_approval:
        approval = Approval(
            id=uuid4(),
            task_id=task.id,
            reason="Risk or budget policy requires owner approval",
            risk_level=task.risk_level,
            estimated_cost=task.estimated_cost,
            status=ApprovalStatus.pending,
            created_at=utc_now(),
        )
        _approvals[approval.id] = approval
        task.approval_id = approval.id
        _tasks[task.id] = task
    return task


@app.get("/v1/tasks", response_model=list[Task])
def list_tasks() -> list[Task]:
    return sorted(_tasks.values(), key=lambda item: item.created_at, reverse=True)


@app.get("/v1/approvals", response_model=list[Approval])
def list_approvals() -> list[Approval]:
    return sorted(_approvals.values(), key=lambda item: item.created_at, reverse=True)


@app.post("/v1/approvals/{approval_id}/decision", response_model=Approval)
def decide_approval(approval_id: UUID, payload: ApprovalDecision) -> Approval:
    approval = _approvals.get(approval_id)
    if approval is None:
        raise HTTPException(status_code=404, detail="Approval not found")
    if approval.status != ApprovalStatus.pending:
        raise HTTPException(status_code=409, detail="Approval already resolved")

    approval.status = ApprovalStatus.approved if payload.approved else ApprovalStatus.rejected
    approval.resolved_at = utc_now()
    _approvals[approval.id] = approval

    task = _tasks[approval.task_id]
    task.status = WorkStatus.queued if payload.approved else WorkStatus.cancelled
    _tasks[task.id] = task
    return approval


@app.post("/v1/emergency-pause", response_model=SystemState)
def set_emergency_pause(payload: PauseRequest) -> SystemState:
    global _paused, _pause_reason
    _paused = payload.paused
    _pause_reason = payload.reason if payload.paused else None
    return system_state()
