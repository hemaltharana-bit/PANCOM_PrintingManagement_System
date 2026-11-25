# PANCOM login API setup

The existing FastAPI API supports the marketing website and both dashboards.

1. Install Python 3.11+ and Node.js.
2. Run Start-Backend.cmd from the extracted folder. It creates a virtual environment, installs dependencies and creates .env with a random application secret if .env is missing. Keep its terminal open.
3. Open http://localhost:8000/api/health and confirm ok is true.
4. Run Start-Frontend.cmd and open the URL shown by Vite (normally http://localhost:5173).
5. Click Register and create a customer account with a password of at least 10 characters. Registration signs you in. Use Login next time.

If your existing .env is present, keep it. Confirm CORS_ORIGINS contains the exact Vite origin. Default supported origins are http://localhost:5173 and http://127.0.0.1:5173. If Vite selects another port, stop the conflicting server or add that origin to backend/.env and restart the backend.

frontend/.env must contain VITE_API_URL=http://localhost:8000. Restart Vite after changing it. These defaults are for the browser on this computer.

## API endpoints

- POST /api/auth/register — JSON: {"name":"Test Customer","email":"customer@example.com","password":"ExamplePass123!"}. Returns access_token and role. Duplicate email returns 409; short password returns 422.
- POST /api/auth/login — JSON: {"email":"customer@example.com","password":"ExamplePass123!"}. Returns access_token and role. Invalid credentials return 401.
- GET /api/me — Authorization: Bearer <access_token>. Returns the signed-in profile.
- GET /api/health — checks server availability.

Accounts persist in SQLite pancom.db. Preserve an existing database and APP_SECRET when updating. Passwords use salted PBKDF2 hashes. Customer registration cannot create staff accounts. Demo staff is available only with DEMO_MODE=true; this configuration is intended for local testing.

Failed to fetch means no readable HTTP response reached the browser; check server startup output, URL, and CORS. It does not mean your password is incorrect.
