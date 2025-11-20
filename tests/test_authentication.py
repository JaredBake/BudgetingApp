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
    

    # We probably shouldn't be updating / deleting the admin user if we plan to continue using it...

    
    # def test_update_user(self, authenticated_client):
    #     """User - Put (26)"""
    #     response = authenticated_client.put("/api/Users/26", json={
    #         "name": "Updated_name,",
    #         "userName": "testDummy",
    #         "email": "test@gmail.com"
    #     })
    #     assert response.status_code == 201
    
    # def test_delete_user(self, authenticated_client):
    #     """Users - Delete"""
    #     response = authenticated_client.delete("/api/Users/5")
    #     assert response.status_code == 200
    
    # def test_change_password(self, authenticated_client):
    #     """User - Change Password"""
    #     response = authenticated_client.put("/api/Users/password/", json={
    #         "Id": "1",
    #         "password": "admin1234"
    #     })
    #     assert response.status_code == 201


class TestUsersDefaultAuth:
    """Test Users endpoints with Default user auth (should fail)"""
    
    def test_get_user_own(self, default_authenticated_client):
        """Users - GetOne - Default User (own record)"""
        response = default_authenticated_client.get("/api/Users/2")
        assert response.status_code == 200
        
        res = response.json()
        assert res["id"] == 2
        assert res["credentials"]["name"] == "Default"
    
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
    
    def test_delete_user_fail(self, default_authenticated_client):
        """Users - Delete - Default User (should fail)"""
        response = default_authenticated_client.delete("/api/Users/5")
        assert response.status_code == 403