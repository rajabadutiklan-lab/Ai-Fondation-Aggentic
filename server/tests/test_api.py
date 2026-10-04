from fastapi.testclient import TestClient

from main import app

client = TestClient(app)


def test_health() -> None:
    response = client.get('/health')
    assert response.status_code == 200
    assert response.json()['status'] == 'ok'


def test_goal_requires_approval_by_default() -> None:
    client.post('/v1/emergency-pause', json={'paused': False, 'reason': 'test'})
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


def test_emergency_pause_blocks_new_goals() -> None:
    pause_response = client.post(
        '/v1/emergency-pause',
        json={'paused': True, 'reason': 'Owner requested pause'},
    )
    assert pause_response.status_code == 200
    assert pause_response.json()['paused'] is True

    blocked = client.post(
        '/v1/goals',
        json={
            'objective': 'Goal yang tidak boleh masuk saat pause',
            'company_id': 'demo-company',
        },
    )
    assert blocked.status_code == 423

    client.post('/v1/emergency-pause', json={'paused': False, 'reason': 'resume'})
