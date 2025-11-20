"""Test Funds endpoints"""
import pytest


class TestFunds:
    """Test Funds CRUD operations with Admin auth"""
    
    def test_get_all_funds(self, authenticated_client):
        """Funds - GetAll"""
        response = authenticated_client.get("/api/Funds/GetAll")
        assert response.status_code == 200
        
        res = response.json()
        assert len(res) == 12
    
    def test_get_fund_by_id(self, authenticated_client):
        """Fund - GetOne (965)"""
        response = authenticated_client.get("/api/Funds/12")
        assert response.status_code == 200
        
        res = response.json()
        assert res["id"] == 12
        assert res["description"] == "Garden Renovation"
    
    def test_post_fund(self, authenticated_client):
        """Fund - Post"""
        response = authenticated_client.post("/api/Funds/", json={
            "userId": 1,
            "description": "test_fund",
            "goalAmount": {
                "amount": 100.12
            },
            "current": {
                "amount": 0.00,
                "currency": "$USD"
            }
        })
        assert response.status_code == 201
        
        res = response.json()
        assert res["goalAmount"]["amount"] == 100.12
        assert res["current"]["amount"] == 0
    
    def test_update_fund(self, authenticated_client):
        """Fund - Put (1001)"""
        response = authenticated_client.put("/api/Funds/", json={
            "id":13,
            "description": "test_fund_updated",
            "goalAmount": {
                "amount": 100.12,
                "currency": "$USD"
            },
            "current": {
                "amount": 0.00,
                "currency": "$USD"
            },
            "userFunds": []
        })
        assert response.status_code == 200
        
        res = response.json()
        assert res == True
    
    def test_delete_fund(self, authenticated_client):
        """Fund - Delete (1001)"""
        response = authenticated_client.delete("/api/Funds/13")
        assert response.status_code == 204