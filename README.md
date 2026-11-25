# Marketing homepage update

The website opens with a responsive PANCOM marketing homepage. Navigation includes How it works, Benefits, FAQs, Login and Register. Login and Register use the existing backend authentication and dashboards; the portal retains its existing PANCOM branding. The homepage uses the existing logo at frontend/public/pancom-logo.png.

To update an existing copy, replace its frontend folder with the frontend folder from this package. Stop Vite first, then run npm install and npm run dev inside frontend. Backend files are included unchanged. The homepage can be viewed without the API; authentication requires the FastAPI backend on port 8000.

# PANCOM Printing Solutions — Self-Service Printing Vending System

**Runnable full-stack MVP** with two web portals, FastAPI backend, SQLite database, private PDF uploads, per-machine QR release, PayHere Sri Lankan payment checkout integration, an authenticated machine-simulator client, and loyalty rewards. Branding uses the supplied PANCOM red P logo and red/navy-blue theme; all prices are **Sri Lankan Rupees (LKR)**.

> **Development status:** This is a tested backend prototype and frontend source, not a production-ready kiosk. A real printer driver / CUPS integration, physical QR scanner, payment merchant credentials, live webhooks, HTTPS and operational security must be added before accepting real customers. The updated frontend passes npm run build.

## Folder structure

```text
PANCOM-Vending-Fullstack/
├── frontend/
│   ├── public/pancom-logo.png    # original supplied PANCOM logo
│   ├── src/App.jsx               # customer and staff dashboards
│   ├── src/styles.css            # responsive red-blue styling
│   ├── src/main.jsx
│   ├── package.json
│   ├── vite.config.js
│   └── .env.example
├── backend/
│   ├── main.py                   # API, data persistence, payment verification, QR, rewards
│   ├── requirements.txt
│   ├── .env.example
│   └── test_flow.py              # integration test
├── agent/
│   └── simulate_machine.py       # machine interface simulation
└── docs/
    └── architecture.md          # system diagram + production checklist
```

## Prerequisites

- Python 3.11+; Node.js 20.19+ or compatible Node.js 22+; VS Code recommended.
- **Windows:** Use PowerShell with two terminal windows.

## 1 — Start the backend

```powershell
cd PANCOM-Vending-Fullstack\backend
py -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
Copy-Item .env.example .env
# Edit .env and set APP_SECRET to a random 32+ character value
uvicorn main:app --reload --port 8000
```

On macOS/Linux, activate with `source .venv/bin/activate` and use `cp .env.example .env` instead. Visit http://localhost:8000/docs for interactive API documentation. The backend creates its SQLite database on startup. The example config is for **local development only**.

## 2 — Start the React website

Open a second terminal:

```powershell
cd PANCOM-Vending-Fullstack\frontend
Copy-Item .env.example .env
npm install
npm run dev
```

Open http://localhost:5173.

Log in as demo staff `staff@pancom.local` / `ChangeMe123!` (only in `DEMO_MODE=true`), or create a customer account through **Create an account**. Never expose demo credentials or `DEMO_MODE=true` on the public internet.

## 3 — Try the complete vending flow

1. Sign up as a customer, select **New Print Order**, upload a small PDF, choose the demo vending machine, number of pages and copies, and B&W or color. Sample rates are **LKR 15/page B&W** and **LKR 35/page color**. The entered page count is not automatically verified in the MVP.
2. Create the order. The application displays a private QR image. Use **Copy token** or **Save QR image**; the secret is retained only in the creating browser's localStorage for demo convenience.
3. Select **Demo payment**. It records a mock paid status without charging real money and is available ONLY in demo mode. The vending machine will not accept unpaid QR codes.
4. Open a third terminal, activate the Python backend venv and run from the project root:

   ```powershell
   python agent/simulate_machine.py --scan "PASTE_QR_TOKEN_HERE" --simulate-success
   ```

   The simulator presents its machine secret (`demo-machine-key-change-me`) and redeems the QR token exactly once, downloads the PDF for validation, and simulates printing and job completion. **It does not print anything physically.**
5. Refresh the customer's dashboard. The job becomes `completed`, and points are credited once: **1 point per LKR 100 actually paid**. Redemption is **1 point = LKR 1**, usable on the next order. Amounts are calculated on the server using integer cents.
6. Sign in as staff to see orders, vending machine status and create a new machine key. New keys are displayed only once and should be kept on secure hardware.

## 4 — PayHere sandbox / real checkout

Official PayHere Sri Lanka checkout documentation: https://support.payhere.lk/api-&-mobile-sdk/checkout-api.I

To enable gateway checkout, first obtain a merchant ID and merchant secret for your approved website/domain. In `backend/.env` set:

```ini
PAYHERE_MERCHANT_ID=YOUR_MERCHANT_ID
PAYHERE_MERCHANT_SECRET=YOUR_DOMAIN_SPECIFIC_SECRET
PAYHERE_SANDBOX=true
PUBLIC_API_URL=https://YOUR-PUBLIC-HTTPS-API-DOMAIN
FRONTEND_URL=https://YOUR-WEB-FRONTEND-DOMAIN
CORS_ORIGINS=https://YOUR-WEB-FRONTEND-DOMAIN
```

The customer selects **Pay** and is prompted for billing phone/address/city. FastAPI produces the official signed hosted-checkout POST parameters; the browser submits them to the PayHere sandbox. PayHere sends a **server-to-server signed POST** to `/api/payments/payhere/notify`. The backend verifies signature, merchant ID, exact LKR amount, currency and status before marking an order paid. Returning from checkout alone **never** marks an order paid. PayHere cannot call back to `localhost`, so you need a public HTTPS URL for real sandbox tests. Keep secrets exclusively on the backend.

Gateway processing and physical terminal payments require the provider's approval; this project integrates hosted checkout for mobile/web payment, not a built-in card reader or cash acceptor. WEBXPAY is an alternative provider but is **not implemented** in this codebase.

## 5 — Machine hardware integration

The machine API is a stable starting interface for hardware:

| Method | Endpoint | Purpose |
|---|---|---|
| `POST` | `/api/machine/scan` | Machine presents one-use scanned QR token; backend checks payment, machine match, and atomically queues job |
| `GET` | `/api/machine/jobs` | Machine polls queued or currently printing jobs |
| `GET` | `/api/machine/jobs/{id}/document` | Authorized paid-machine job obtains a private PDF |
| `POST` | `/api/machine/jobs/{id}/status` | Agent transitions `queued → printing → completed/failed` |

Machine endpoints require the private `X-Machine-Key` header. A production agent should scan from a camera/USB scanner, validate printer capabilities, send the PDF to CUPS/IPP or the actual machine SDK, verify **physical completion** instead of assuming it, and report errors. A paper jam or empty-paper condition must never falsely issue a completion or loyalty credit. Implement job ownership/leases, hardware telemetry and retry/refund workflows before operating unattended machines.

## 6 — Security / production readiness

This starter intentionally omits enterprise hardening. Before production:

- Disable demo mode and demo staff login; provision staff securely, introduce MFA, account recovery, email validation and rate limiting.
- Move SQLite to PostgreSQL with migrations, backups and transaction tests; migrate localStorage QR secrets to an account-bound reissue flow. For actual cross-device phone use, give customers a secure way to retrieve/reissue their QR after authentication.
- Replace the current PDF header/size check with authoritative PDF page-count validation, safe conversion/sandboxing, anti-malware scanning and printer-safe file handling. Constrain copies, paper formats and large jobs.
- Use TLS/HTTPS, secure cookie/session handling, audit trails, machine authentication (ideally mTLS), short-lived/rotatable machine keys, private encrypted storage and retention/deletion policies.
- Handle payment refund/chargeback and loyalty reversals; enforce webhooks idempotently, reconcile against the gateway and reject inconsistent payment transitions. Current chargeback handling is a starting state flag only.
- Add a real printer spooler/driver integration, physical QR scanner UI, device heartbeat, machine offline/jam/toner alerts, remote maintenance and secure kiosk lockdown.
- Obtain merchant contract and test PayHere integration with real sandbox credentials and a public notify URL; implement privacy consent and sender integrations for automatic WhatsApp/email QR delivery. Current customer UI only opens WhatsApp/email draft messages containing order IDs, not QR images.
- Have a qualified security engineer audit the system before taking money or storing customer documents in production.

## Run backend integration test

```powershell
cd backend
python test_flow.py
```

The test covers registration, PDF order upload, authenticated QR image, rejection of unpaid printing, demo payment, one-time QR scan, printer job status transitions and non-duplicated rewards.
