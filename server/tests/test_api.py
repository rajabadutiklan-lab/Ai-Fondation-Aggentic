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
    assert response.json()['version'] == '0.3.0'


def test_goal_is_autonomous_by_default_and_can_be_planned() -> None:
    resume_system()
    response = client.post(
        '/v1/goals',
        json={
            'objective': 'Buat website bisnis baru sampai siap tayang',
            'company_id': 'demo-company-v3',
        },
    )
    assert response.status_code == 201
    body = response.json()
    assert body['status'] == 'queued'

    plan = client.post(f"/v1/goals/{body['id']}/plan")
    assert plan.status_code == 200
    planned = plan.json()
    assert len(planned['tasks']) >= 8
    assert planned['approvals_created'] >= 2
    assert planned['goal']['status'] == 'waiting_approval'


def test_bootstrap_company_builds_full_org_chart() -> None:
    company = client.post(
        '/v1/companies',
        json={
            'name': 'RajaBadut V3',
            'slug': 'rajabadut-v3',
            'objective': 'Operate the business autonomously',
            'monthly_budget': 1000000,
        },
    )
    assert company.status_code == 201

    bootstrap = client.post('/v1/companies/rajabadut-v3/bootstrap')
    assert bootstrap.status_code == 200
    body = bootstrap.json()
    division_names = {item['name'] for item in body['divisions']}
    specialist_names = {item['name'] for item in body['specialists']}
    assert {'Website', 'Social Media', 'Marketing', 'CRM & Sales', 'WhatsApp', 'Finance', 'Research', 'Engineering'} <= division_names
    assert 'SEO & Keyword Research' in specialist_names
    assert 'Human Conversation' in specialist_names
    assert 'AI System Improvement' in specialist_names
    assert len(body['specialists']) >= 20


def test_low_risk_task_can_queue_without_approval() -> None:
    resume_system()
    response = client.post(
        '/v1/tasks',
        json={
            'title': 'Audit metadata halaman website',
            'company_id': 'demo-company-v3',
            'risk_level': 'low',
            'estimated_cost': 0,
            'action_type': 'internal',
        },
    )
    assert response.status_code == 201
    assert response.json()['status'] == 'queued'
    assert response.json()['approval_id'] is None


def test_external_publish_requires_approval() -> None:
    resume_system()
    task_response = client.post(
        '/v1/tasks',
        json={
            'title': 'Publish campaign ke social media',
            'company_id': 'demo-company-v3',
            'risk_level': 'medium',
            'estimated_cost': 0,
            'action_type': 'publish',
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


def test_paid_task_requires_approval_even_when_low_risk() -> None:
    resume_system()
    response = client.post(
        '/v1/tasks',
        json={
            'title': 'Pesan layanan eksternal',
            'company_id': 'demo-company-v3',
            'risk_level': 'low',
            'estimated_cost': 50000,
            'action_type': 'purchase',
        },
    )
    assert response.status_code == 201
    assert response.json()['status'] == 'waiting_approval'
    assert response.json()['approval_id'] is not None


def test_connector_catalog_and_manual_connector_fallback() -> None:
    catalog = client.get('/v1/connectors/catalog')
    assert catalog.status_code == 200
    kinds = {item['kind'] for item in catalog.json()}
    assert {'website', 'github', 'whatsapp', 'meta', 'tiktok', 'domain_dns', 'hosting'} <= kinds

    connector = client.post(
        '/v1/connectors',
        json={
            'company_id': 'demo-company-v3',
            'kind': 'website',
            'name': 'Website RajaBadut',
            'endpoint': 'https://example.test/api',
            'auth_mode': 'api_key',
            'credential_ref': 'vault://rajabadut/website-api',
            'scopes': ['read', 'write'],
            'enabled': True,
        },
    )
    assert connector.status_code == 201
    assert connector.json()['status'] == 'configured'
    assert connector.json()['credential_ref'].startswith('vault://')


def test_ai_router_uses_cost_and_risk_tiers() -> None:
    light = client.get('/v1/ai/route', params={'task_type': 'classify', 'risk_level': 'low'})
    assert light.status_code == 200
    assert light.json()['provider_id'] == 'fast'

    strong = client.get('/v1/ai/route', params={'task_type': 'coding', 'risk_level': 'high'})
    assert strong.status_code == 200
    assert strong.json()['provider_id'] == 'reasoning'

    premium = client.get('/v1/ai/route', params={'task_type': 'finance_decision', 'risk_level': 'critical'})
    assert premium.status_code == 200
    assert premium.json()['provider_id'] == 'premium'


def test_self_improvement_queue_has_owner_gate() -> None:
    proposal = client.post(
        '/v1/improvements',
        json={
            'title': 'Kurangi token untuk task repetitif',
            'description': 'Pindahkan dedupe dan status checks ke deterministic workflow.',
            'risk_level': 'medium',
            'expected_benefit': 'Lower AI spend and faster processing',
        },
    )
    assert proposal.status_code == 201
    proposal_id = proposal.json()['id']
    assert proposal.json()['status'] == 'proposed'

    decision = client.post(f'/v1/improvements/{proposal_id}/decision', json={'approved': True})
    assert decision.status_code == 200
    assert decision.json()['status'] == 'approved'


def test_dashboard_and_audit_are_visible() -> None:
    dashboard = client.get('/v1/dashboard')
    assert dashboard.status_code == 200
    body = dashboard.json()
    assert 'system' in body
    assert 'autonomy_policy' in body
    assert isinstance(body['recent_events'], list)

    audit = client.get('/v1/audit?limit=10')
    assert audit.status_code == 200
    assert len(audit.json()) > 0


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
            'company_id': 'demo-company-v3',
        },
    )
    assert blocked_goal.status_code == 423

    blocked_task = client.post(
        '/v1/tasks',
        json={
            'title': 'Task yang tidak boleh masuk saat pause',
            'company_id': 'demo-company-v3',
            'risk_level': 'low',
        },
    )
    assert blocked_task.status_code == 423

    resume_system()
