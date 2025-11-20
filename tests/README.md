# Budget App API Test Suite

This is a comprehensive pytest test suite converted from Insomnia REST API tests for the Budget App.

## Project Structure

```
budget_app_tests/
├── conftest.py                 # Pytest configuration and fixtures
├── pytest.ini                  # Pytest settings
├── requirements.txt            # Python dependencies
├── README.md                   # This file
└── tests/
    ├── test_controllers.py     # Controller connection tests
    ├── test_authentication.py  # Authentication flow tests
    ├── test_users.py          # User CRUD operations
    ├── test_accounts.py       # Account CRUD operations
    ├── test_funds.py          # Fund CRUD operations
    ├── test_transactions.py   # Transaction CRUD operations
    ├── test_stats.py          # Statistics endpoints
    └── test_database.py       # Database seeding tests
```

## Setup

1. **Install Python 3.8+**

2. **Create a virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Ensure your Budget App API is running:**
```bash
# Your API should be running on localhost:5284
```

## Running Tests

### Run all tests
```bash
pytest
```

### Run specific test file
```bash
pytest tests/test_users.py
```

### Run specific test class
```bash
pytest tests/test_users.py::TestUsers
```

### Run specific test
```bash
pytest tests/test_users.py::TestUsers::test_get_all_users
```

### Run with verbose output
```bash
pytest -v
```

### Run with coverage report
```bash
pytest --cov=. --cov-report=html
```

### Run only smoke tests (quick validation)
```bash
pytest -m smoke
```

### Generate HTML report
```bash
pytest --html=report.html --self-contained-html
```

## Test Categories

### Controller Tests (`test_controllers.py`)
Basic connectivity tests for all API controllers:
- Default endpoint
- Users controller
- Funds controller
- Accounts controller
- Transactions controller
- Seed controller
- Stats controller
- Auth controller

### Authentication Tests (`test_authentication.py`)
- User registration
- Admin login
- Default user login
- Newly registered user login
- Logout

### User Tests (`test_users.py`)
**Admin operations:**
- Get all users
- Get user by ID
- Create user
- Update user
- Delete user
- Change password

**Default user operations (authorization tests):**
- Access own profile (allowed)
- Access other user profiles (forbidden)
- Admin operations (all forbidden)

### Account Tests (`test_accounts.py`)
**Admin operations:**
- Get all accounts
- Get account by ID
- Create account
- Update account
- Delete account
- User-Account relationship management

**Default user operations (authorization tests):**
- All operations should be forbidden

### Fund Tests (`test_funds.py`)
**Admin operations:**
- Get all funds
- Get fund by ID
- Create fund
- Update fund
- Delete fund
- User-Fund relationship management

### Transaction Tests (`test_transactions.py`)
- Get all transactions
- Get transaction by ID
- Create transaction
- Update transaction
- Delete transaction

### Stats Tests (`test_stats.py`)
- Overview statistics
- User accounts count

## Fixtures

### `api_client`
Basic API client without authentication.

### `authenticated_client`
API client with admin authentication token.

### `default_authenticated_client`
API client with default user authentication token.

### `admin_auth`
Admin authentication token (session-scoped).

### `default_auth`
Default user authentication token (session-scoped).

## Configuration

### Base URL
Default: `http://localhost:5284`

To change the base URL, modify the `APIClient` initialization in `conftest.py`:
```python
def __init__(self, base_url: str = "http://your-api-url:port"):
```

### Admin Credentials
- Email: `admin@gmail.com`
- Password: `admin123`

### Default User Credentials
- Username: `Default`
- Password: `default123`

## Tips

1. **Run tests in order**: Some tests may depend on data created by previous tests. Consider using test markers or separate test sessions.

2. **Database state**: If tests fail due to database state, you may need to reseed the database using the seed endpoint.

3. **Parallel execution**: For faster test runs, install pytest-xdist:
```bash
pip install pytest-xdist
pytest -n auto  # Run tests in parallel
```

4. **Debugging**: Use `-s` flag to see print statements:
```bash
pytest -s tests/test_users.py
```

5. **Stop on first failure**:
```bash
pytest -x
```

## Common Issues

**Connection Refused**: Ensure your API is running on `localhost:5284`

**Authentication Failures**: Verify admin and default user credentials are correct

**Test Data Issues**: Some tests expect specific IDs (e.g., User ID 3, Account ID 16). Ensure database is seeded properly.

## Contributing

When adding new tests:
1. Follow the existing naming conventions
2. Use appropriate fixtures for authentication
3. Add descriptive docstrings
4. Group related tests in classes
5. Update this README with new test information