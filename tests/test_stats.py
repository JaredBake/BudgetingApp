"""Test Stats endpoints"""
import pytest


class TestStats:
    """Test Stats endpoints with Admin auth"""
    
    def test_stats_overview(self, authenticated_client):
        """Stats - Overview"""
        response = authenticated_client.get("/api/Stats/overview")
        assert response.status_code == 200
    
    def test_user_accounts_count(self, authenticated_client):
        """Stats - User Accounts Count"""
        response = authenticated_client.get("/api/Stats/users/1/accounts")
        assert response.status_code == 200