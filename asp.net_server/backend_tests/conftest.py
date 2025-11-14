import pytest
import requests
from typing import Dict, Optional


class APIClient:
    """API Client for Budget App testing"""
    
    def __init__(self, base_url: str = "http://localhost:5284"):
        self.base_url = base_url
        self.session = requests.Session()
        self.admin_token: Optional[str] = None
        self.default_token: Optional[str] = None
        
    def set_bearer_token(self, token: str):
        """Set bearer token for requests"""
        self.session.headers.update({"Authorization": f"Bearer {token}"})
        
    def clear_token(self):
        """Clear bearer token"""
        if "Authorization" in self.session.headers:
            del self.session.headers["Authorization"]
    
    def get(self, endpoint: str, **kwargs):
        """GET request"""
        return self.session.get(f"{self.base_url}{endpoint}", **kwargs)
    
    def post(self, endpoint: str, json=None, **kwargs):
        """POST request"""
        return self.session.post(f"{self.base_url}{endpoint}", json=json, **kwargs)
    
    def put(self, endpoint: str, json=None, **kwargs):
        """PUT request"""
        return self.session.put(f"{self.base_url}{endpoint}", json=json, **kwargs)
    
    def delete(self, endpoint: str, **kwargs):
        """DELETE request"""
        return self.session.delete(f"{self.base_url}{endpoint}", **kwargs)


@pytest.fixture(scope="session")
def api_client():
    """Create API client for testing"""
    return APIClient()


@pytest.fixture(scope="session")
def admin_auth(api_client):
    """Authenticate as admin user and return token"""
    response = api_client.post("/api/Auth/login/", json={
        "email": "admin@gmail.com",
        "password": "admin123"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["authenticated"] is True
    token = data["token"]
    return token


@pytest.fixture(scope="session")
def default_auth(api_client):
    """Authenticate as default user and return token"""
    response = api_client.post("/api/Auth/login/", json={
        "username": "Default",
        "password": "default123"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["authenticated"] is True
    token = data["token"]
    return token


@pytest.fixture
def authenticated_client(api_client, admin_auth):
    """API client with admin authentication"""
    api_client.set_bearer_token(admin_auth)
    yield api_client
    api_client.clear_token()


@pytest.fixture
def default_authenticated_client(api_client, default_auth):
    """API client with default user authentication"""
    api_client.set_bearer_token(default_auth)
    yield api_client
    api_client.clear_token()