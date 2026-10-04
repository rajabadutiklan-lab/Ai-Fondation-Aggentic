from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from uuid import UUID, uuid4

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field

app = FastAPI(
    title="AI Foundation Agentic API",
    version="0.1.0",
    description="Backend control plane for the AI Business OS.",
)


class GoalStatus(str, Enum):
    queued = "queued"
    planning = "planning"
    waiting_approval = "waiting_approval"
    running = "running"
    completed = "completed"
    failed = "failed"


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


class PauseRequest(BaseModel):
    paused: bool
    reason: str = Field(default="Manual control from owner", max_length=500)


class SystemState(BaseModel):
    paused: bool
    pause_reason: str | None
    active_goals: int
    hierarchy: list[str]


_goals: dict[UUID, Goal] = {}
_paused = False
_pause_reason: str | None = None


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok", "service": "ai-foundation-agentic"}


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
        hierarchy=[
            "AI Pusat",
            "Company Agent",
            "Division Manager",
            "Specialist Agent",
            "Worker / Automation",
        ],
    )


@app.post("/v1/goals", response_model=Goal, status_code=201)
def create_goal(payload: GoalCreate) -> Goal:
    if _paused:
        raise HTTPException(
            status_code=423,
            detail="System is paused. Resume the system before creating a new goal.",
        )

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
        created_at=datetime.now(timezone.utc),
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


@app.post("/v1/emergency-pause", response_model=SystemState)
def set_emergency_pause(payload: PauseRequest) -> SystemState:
    global _paused, _pause_reason
    _paused = payload.paused
    _pause_reason = payload.reason if payload.paused else None
    return system_state()
