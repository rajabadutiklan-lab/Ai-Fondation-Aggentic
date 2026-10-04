from pathlib import Path
import sys

from fastapi.testclient import TestClient

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from main import app

client = TestClient(app)


def resume_system() -> None:
    client.post('/v1/emergency-pause', json={'paused': False, 'reason': 'test resume'})


def test_health() -> None:
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json()['status'] == 'ok'
    assert response.json()['version'] == '0.2.0'


def test_goal_requires_approval_by_default() -> None:
    resume_system()
    response = client.post(
        '/v1/goals',
        json={
            'objective': 'Buat website bisnis baru sampai siap tayang',
            'company_id': 'demo-company',
        },
    )
    assert response.status_code == 201
    body = response.json()
    assert body['status'] == 'waiting_approval'
    assert body['company_id'] == 'demo-company'


def test_company_division_specialist_hierarchy() -> None:
    company = client.post(
        '/v1/companies',
        json={
            'name': 'RajaBadut',
            'slug': 'rajabadut-test',
            'objective': 'Menjadi company workspace otomatis',
            'monthly_budget': 1000000,
        },
    )
    assert company.status_code == 201

    division = client.post(
        '/v1/companies/rajabadut-test/divisions',
        json={
            'name': 'Website',
            'purpose': 'SEO, publishing, analytics, maintenance',
            'monthly_budget': 250000,
        },
    )
    assert division.status_code == 201
    division_id = division.json()['id']

    specialist = client.post(
        f'/v1/divisions/{division_id}/specialists',
        json={'name': 'SEO Specialist', 'capability': 'Keyword research and technical SEO'},
    )
    assert specialist.status_code == 201

    hierarchy = client.get('/v1/companies/rajabadut-test/hierarchy')
    assert hierarchy.status_code == 200
    body = hierarchy.json()
    assert body['company']['name'] == 'RajaBadut'
    assert len(body['divisions']) == 1
    assert len(body['specialists']) == 1
    assert body['specialists'][0]['name'] == 'SEO Specialist'


def test_low_risk_task_can_queue_without_approval() -> None:
    resume_system()
    response = client.post(
        '/v1/tasks',
        json={
            'title': 'Audit metadata halaman website',
            'company_id': 'demo-company',
            'risk_level': 'low',
            'estimated_cost': 0,
        },
    )
    assert response.status_code == 201
    assert response.json()['status'] == 'queued'
    assert response.json()['approval_id'] is None


def test_high_risk_task_is_gated_by_approval() -> None:
    resume_system()
    task_response = client.post(
        '/v1/tasks',
        json={
            'title': 'Deploy perubahan produksi',
            'company_id': 'demo-company',
            'risk_level': 'high',
            'estimated_cost': 0,
        },
    )
    assert task_response.status_code == 201
    task = task_response.json()
    assert task['status'] == 'waiting_approval'
    assert task['approval_id'] is not None

    approval_id = task['approval_id']
    decision = client.post(
        f'/v1/approvals/{approval_id}/decision',
        json={'approved': True, 'note': 'Owner approved for test'},
    )
    assert decision.status_code == 200
    assert decision.json()['status'] == 'approved'

    tasks = client.get('/v1/tasks').json()
    approved_task = next(item for item in tasks if item['id'] == task['id'])
    assert approved_task['status'] == 'queued'


def test_paid_task_requires_approval_even_when_low_risk() -> None:
    resume_system()
    response = client.post(
        '/v1/tasks',
        json={
            'title': 'Pesan layanan eksternal',
            'company_id': 'demo-company',
            'risk_level': 'low',
            'estimated_cost': 50000,
        },
    )
    assert response.status_code == 201
    assert response.json()['status'] == 'waiting_approval'
    assert response.json()['approval_id'] is not None


def test_emergency_pause_blocks_new_goals_and_tasks() -> None:
    pause_response = client.post(
        '/v1/emergency-pause',
        json={'paused': True, 'reason': 'Owner requested pause'},
    )
    assert pause_response.status_code == 200
    assert pause_response.json()['paused'] is True

    blocked_goal = client.post(
        '/v1/goals',
        json={
            'objective': 'Goal yang tidak boleh masuk saat pause',
            'company_id': 'demo-company',
        },
    )
    assert blocked_goal.status_code == 423

    blocked_task = client.post(
        '/v1/tasks',
        json={
            'title': 'Task yang tidak boleh masuk saat pause',
            'company_id': 'demo-company',
            'risk_level': 'low',
        },
    )
    assert blocked_task.status_code == 423

    resume_system()
