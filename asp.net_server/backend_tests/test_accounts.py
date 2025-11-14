"""Test Accounts endpoints"""
import pytest


class TestAccounts:
    """Test Accounts CRUD operations with Admin auth"""
    
    def test_get_all_accounts(self, authenticated_client):
        """Account - GetAll"""
        response = authenticated_client.get("/api/Accounts/GetAll")
        assert response.status_code == 200
    
    def test_get_account_by_id(self, authenticated_client):
        """Account - GetOne (16)"""
        response = authenticated_client.get("/api/Accounts/16")
        assert response.status_code == 200
        
        res = response.json()
        assert res["name"] == "Account 16"
    
    def test_post_account(self, authenticated_client):
        """Account - Post"""
        response = authenticated_client.post("/api/Accounts/", json={
            "name": "Savings",
            "accountType": 1,
            "balance": {
                "amount": 2000,
                "currency": "$USD"
            }
        })
        assert response.status_code == 201
        
        res = response.json()
        assert res["name"] == "Savings"
    
    def test_update_account(self, authenticated_client):
        """Account - Update"""
        response = authenticated_client.put("/api/Accounts/", json={
            "id": 3,
            "userId": 3,
            "name": "Savings-Updated",
            "accountType": 1,
            "balance": {
                "amount": 2000,
                "currency": "$USD"
            }
        })
        assert response.status_code == 200
    
    def test_delete_account(self, authenticated_client):
        """Account - Delete"""
        response = authenticated_client.delete("/api/Accounts/3")
        assert response.status_code == 204


class TestUserAccount:
    """Test UserAccount relationship operations"""
    
    def test_user_account_workflow(self, authenticated_client):
        """Test complete UserAccount workflow: belongs check, join, remove"""
        # Test belongs (before join)
        response = authenticated_client.get("/api/Accounts/User", json={
            "userId": 2,
            "accountId": 51
        })
        assert response.status_code == 200
        assert response.json() is True
        
        # Remove user from account
        response = authenticated_client.delete("/api/Accounts/User", json={
            "userId": 2,
            "accountId": 51
        })
        assert response.status_code == 200
        
        # Join user to account
        response = authenticated_client.post("/api/Accounts/User", json={
            "userId": 2,
            "accountId": 51
        })
        assert response.status_code == 200
        
        # Test belongs (after remove)
        response = authenticated_client.get("/api/Accounts/User", json={
            "userId": 2,
            "accountId": 51
        })
        assert response.status_code == 200
        assert response.json() is False


class TestAccountsDefaultAuth:
    """Test Accounts endpoints with Default user auth (should fail)"""
    
    def test_get_account_fail(self, default_authenticated_client):
        """Account - GetOne - Default User (should fail)"""
        response = default_authenticated_client.get("/api/Accounts/16")
        assert response.status_code == 403
    
    def test_update_account_fail(self, default_authenticated_client):
        """Account - Update - Default User (should fail)"""
        response = default_authenticated_client.put("/api/Accounts/", json={
            "id": 3,
            "userId": 3,
            "name": "Savings-Updated",
            "accountType": 1,
            "balance": {
                "amount": 2000,
                "currency": "$USD"
            }
        })
        assert response.status_code == 403
    
    def test_delete_account_fail(self, default_authenticated_client):
        """Account - Delete - Default User (should fail)"""
        response = default_authenticated_client.delete("/api/Accounts/3")
        assert response.status_code == 403
    
    def test_user_account_test_belongs_fail(self, default_authenticated_client):
        """Account - TestBelongs - Default User (should fail)"""
        response = default_authenticated_client.get("/api/Accounts/User", json={
            "userId": 2,
            "accountId": 51
        })
        assert response.status_code == 403
    
    def test_user_account_remove_fail(self, default_authenticated_client):
        """Account - RemoveUser - Default User (should fail)"""
        response = default_authenticated_client.delete("/api/Accounts/User", json={
            "userId": 2,
            "accountId": 51
        })
        assert response.status_code == 403
    
    def test_user_account_join_fail(self, default_authenticated_client):
        """Account - JoinUser - Default User (should fail)"""
        response = default_authenticated_client.post("/api/Accounts/User", json={
            "userId": 3,
            "accountId": 2
        })
        assert response.status_code == 403