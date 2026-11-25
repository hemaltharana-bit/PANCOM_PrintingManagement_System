# PANCOM printer administration

Start the backend with Start-Backend.cmd and the frontend with Start-Frontend.cmd.
Open http://localhost:5173/#admin or click Admin on the homepage.

For local demonstration, with DEMO_MODE=true, sign in using staff@pancom.local and ChangeMe123! (unless changed in backend/.env). Customer accounts cannot use the portal.

To create your own staff account, open a terminal in backend after running Start-Backend.cmd once:

```powershell
.\.venv\Scripts\python.exe create_staff.py
```

Enter a name, separate email, and password. This local script creates staff accounts; public registration continues to create customers only.

## Features

- Staff login and sign out.
- Register printer stations and receive a machine key shown once.
- Edit names, locations and availability: online, offline or maintenance.
- Search and filter stations.
- Total orders, pending paid jobs and completed jobs per station.
- Replace a machine key; the old key stops authenticating. Update the station agent to use the new key.
- Existing orders and customer portal remain available through Orders & operations.

Availability is manually administered. It is not hardware discovery, automatic heartbeat monitoring, ink reporting or Windows printer driver installation. The machine simulator still represents a station; this package does not add physical printer integration.

Offline and maintenance printers reject new orders and QR release requests; their agents receive an empty job list. Work already downloaded or submitted to a printer may continue. Resume by setting the station online.

## Updating an existing project

Stop both terminals. Back up your project and database. Copy the included frontend and backend source over the existing project, while preserving your backend/.env, pancom.db and private_uploads. Run the startup scripts again. Existing database tables are reused; no destructive migration is required.

## API

All admin endpoints require Authorization: Bearer <staff token>.

- GET /api/admin/machines — station list with job counts.
- POST /api/admin/machines — register station (name and location).
- PATCH /api/admin/machines/{id} — edit name, location, status.
- POST /api/admin/machines/{id}/rotate-key — issue replacement key.

Changing station metadata does not install or configure printer drivers. Register the station agent separately using its machine key.
