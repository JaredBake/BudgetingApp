"""Test controller connections"""
import pytest


class TestControllerConnections:
    """Test that all controllers are communicating"""
    
    def test_default_endpoint(self, api_client):
        """Check server is communicating"""
        response = api_client.get("/test")
        assert response.status_code == 200
    
    def test_users_controller(self, api_client):
        """Check User Controller is communicating"""
        response = api_client.get("/api/Users/")
        assert response.status_code == 200
    
    def test_funds_controller(self, api_client):
        """Check Fund Controller is communicating"""
        response = api_client.get("/api/Funds/")
        assert response.status_code == 200
    
    def test_accounts_controller(self, api_client):
        """Check Account Controller is communicating"""
        response = api_client.get("/api/Accounts/")
        assert response.status_code == 200
    
    def test_transactions_controller(self, api_client):
        """Check Transactions Controller is communicating"""
        response = api_client.get("/api/Transactions/")
        assert response.status_code == 200
    
    def test_seed_controller(self, api_client):
        """Check Seed Controller is communicating"""
        response = api_client.get("/api/Seed/")
        assert response.status_code == 200
    
    def test_stats_controller(self, api_client):
        """Check Stats Controller is communicating"""
        response = api_client.get("/api/Stats/")
        assert response.status_code == 200
    
    def test_auth_controller(self, api_client):
        """Check Auth Controller is communicating"""
        response = api_client.get("/api/Auth/")
        assert response.status_code == 200