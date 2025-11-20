"""Test Transactions endpoints"""
import pytest


class TestTransactions:
    """Test Transactions CRUD operations with Admin auth"""
    
    def test_get_all_transactions(self, authenticated_client):
        """Transactions - GetAll"""
        response = authenticated_client.get("/api/Transactions/GetAll")
        assert response.status_code == 200
        
        res = response.json()
        assert len(res) == 957
    
    def test_get_transaction_by_id(self, authenticated_client):
        """Transactions - GetOne (957)"""
        response = authenticated_client.get("/api/Transactions/957")
        assert response.status_code == 200
        
        res = response.json()
        assert res["id"] == 957
    
    def test_post_transaction(self, authenticated_client):
        """Transaction - Post"""
        response = authenticated_client.post("/api/Transactions/", json={
            "accountId": 12,
            "money": {
                "amount": 75,
                "currency": "$USD"
            },
            "type": 1
        })
        assert response.status_code == 201
        
        res = response.json()
        assert res["money"]["amount"] == 75
    
    def test_update_transaction(self, authenticated_client):
        """Transaction - Put (1001)"""
        response = authenticated_client.put("/api/Transactions/", json={
            "id": 1001,
            "accountId": 12,
            "date": "2025-10-05T23:23:15.6748797Z",
            "money": {
                "amount": 65,
                "currency": "$USD"
            },
            "type": 1
        })
        assert response.status_code == 204
    
    def test_delete_transaction(self, authenticated_client):
        """Transaction - Delete (1001)"""
        response = authenticated_client.delete("/api/Transactions/1001")
        assert response.status_code == 204