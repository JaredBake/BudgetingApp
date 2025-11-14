"""Test Database seed endpoints"""
import pytest


class TestDatabase:
    """Test Database seed operations with Admin auth"""
    
    def test_seed_database(self, authenticated_client):
        """Database seeded with mockdata"""
        response = authenticated_client.post("/api/Seed/")
        assert response.status_code == 200


class TestDatabaseDefaultAuth:
    """Test Database seed with Default user auth (should fail)"""
    
    def test_seed_database_unauthorized(self, default_authenticated_client):
        """Database unauthorized - Default User"""
        response = default_authenticated_client.post("/api/Seed/")
        assert response.status_code == 403