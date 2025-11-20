"""Test Users endpoints"""
import pytest


class TestUsers:
    """Test Users CRUD operations with Admin auth"""
    
    def test_get_all_users(self, authenticated_client):
        """Users - GetAll"""
        response = authenticated_client.get("/api/Users/GetAll")
        assert response.status_code == 200
    
    def test_get_user_by_id(self, authenticated_client):
        """Users - GetOne (3)"""
        response = authenticated_client.get("/api/Users/3")
        assert response.status_code == 200
        
        res = response.json()
        assert res["id"] == 3
        assert res["credentials"]["name"] == "Charizard Smith"
        assert res["userAccounts"][0]["accountId"] == 16
    
    def test_post_user(self, authenticated_client):
        """Users - Post"""
        response = authenticated_client.post("/api/Users/PostUser", json={
            "UserName": "testDummy",
            "Name": "Shawn Crook,",
            "Password": "password123",
            "Email": "test@gmail.com"
        })
        assert response.status_code == 201       
    

    def test_change_password(self, authenticated_client, api_client):
        """User - Change Password"""
        response = authenticated_client.put("/api/Users/password/", json={
            "Id": "1",
            "password": "temporaryBADpassword1234"
        })
        assert response.status_code == 201

        response = api_client.post("/api/Auth/login/", json={
            "email": "admin@gmail.com",
            "password": "admin123"
        })

        res = response.json()
        assert response.status_code == 401
        assert res["authenticated"] is False

        response = api_client.post("/api/Auth/login/", json={
            "email": "admin@gmail.com",
            "password": "temporaryBADpassword1234"
        })

        res = response.json()
        assert response.status_code == 200
        assert res["authenticated"] is True

        response = authenticated_client.put("/api/Users/password/", json={
            "Id": "1",
            "password": "admin123"
        })
        assert response.status_code == 201


class TestUsersDefaultAuthFail:
    """Test Users endpoints with Default user auth (should fail)"""  
    
    def test_get_user_other_fail(self, default_authenticated_client):
        """Users - GetOne - Default User (other user - should fail)"""
        response = default_authenticated_client.get("/api/Users/3")
        assert response.status_code == 403
    
    def test_get_all_users_fail(self, default_authenticated_client):
        """Users - GetAll - Default User (should fail)"""
        response = default_authenticated_client.get("/api/Users/GetAll")
        assert response.status_code == 403
    
    def test_post_user_fail(self, default_authenticated_client):
        """Users - Post - Default User (should fail)"""
        response = default_authenticated_client.post("/api/Users/PostUser", json={
            "UserName": "testDummy",
            "Name": "Shawn Crook,",
            "Password": "password123",
            "Email": "test@gmail.com"
        })
        assert response.status_code == 403
    
    def test_update_user_fail(self, default_authenticated_client):
        """User - Put - Default User (should fail)"""
        response = default_authenticated_client.put("/api/Users/26", json={
            "name": "Updated_name,",
            "userName": "testDummy",
            "email": "test@gmail.com"
        })
        assert response.status_code == 403

    def test_update_user_fail_promote(self, default_authenticated_client):
        """User - Put - Default User (can't promote self to admin)"""
        response = default_authenticated_client.put("/api/Users/2", json={
            "name": "Updated_name,",
            "userName": "testDummy",
            "email": "test@gmail.com",
            "role": "0"
        })
        assert response.status_code == 400
    
    def test_delete_user_fail(self, default_authenticated_client):
        """Users - Delete - Default User (should fail)"""
        response = default_authenticated_client.delete("/api/Users/5")
        assert response.status_code == 403

class TestUsersDefaultAuthPass:
    """Test Users endpoints with Default user auth (should pass)"""
    
    def test_get_user_own(self, default_authenticated_client):
        """Users - GetOne - Default User (own record)"""
        response = default_authenticated_client.get("/api/Users/2")
        assert response.status_code == 200
        
        res = response.json()
        assert res["id"] == 2
        assert res["credentials"]["name"] == "Default"  
   
    
    def test_update_user_pass(self, default_authenticated_client):
        """User - Put - Default User (should pass)"""
        response = default_authenticated_client.put("/api/Users/2", json={
            "name": "Default_Updated",
            "userName": "Default",
            "email": "default@gmail.com",
        })

        assert response.status_code == 201

        res = response.json()
        assert res["credentials"]["name"] == "Default_Updated"  
        assert res["id"] == 2

        response = default_authenticated_client.put("/api/Users/2", json={
            "name": "Default_Updated,",
            "userName": "Default",
            "email": "default@gmail.com"
        })
        assert response.status_code == 201

        response = default_authenticated_client.put("/api/Users/2", json={
            "name": "Default",
            "userName": "Default",
            "email": "default@gmail.com"
        })
        assert response.status_code == 201
    
    def test_delete_user_(self, test_authenticated_client):
        """Users - Delete - Default User (should pass)"""

        response = test_authenticated_client.get("/api/Users/29")
        assert response.status_code == 200
        
        res = response.json()
        assert res["id"] == 29
        assert res["credentials"]["name"] == "BadTest" 

        response = test_authenticated_client.delete("/api/Users/29")
        assert response.status_code == 200

        response = test_authenticated_client.get("/api/Users/29")
        assert response.status_code == 404