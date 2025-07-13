# TaskSync: Offline-First Task Manager

A robust **Flutter** task management app with full **offline-first** support, backed by a **Node.js/Express** and **PostgreSQL** server.  
Seamlessly manage your tasks, even without an internet connection—your data syncs automatically when you're back online.

---

## Features

### Mobile App (Flutter)
- **User Authentication**: Sign up, log in, and secure your data.
- **Task Management**: Add, view, and delete tasks.
- **Offline-First**:  
  - View and create tasks offline.
  - Local database (SQLite) for instant access and reliability.
  - Unsynced tasks are stored and automatically synced when online.
- **Color Picker**: Assign colors to tasks for better organization.
- **Modern UI**: Responsive, clean, and user-friendly interface.

### Backend (Node.js/Express + PostgreSQL)
- **RESTful API** for authentication and task management.
- **JWT Authentication** for secure endpoints.
- **PostgreSQL** for persistent, scalable data storage.
- **Dockerized** for easy deployment and local development.
- **Task Sync API** for reconciling offline changes.

---

## Project Structure

```
task_offline_first/
  ├── lib/                # Flutter app source
  │   ├── features/
  │   │   ├── auth/       # Authentication logic & UI
  │   │   └── home/       # Task management logic & UI
  │   └── core/           # Core utilities, constants, services
  ├── server/             # Node.js backend
  │   ├── src/            # Express routes, middleware, db schema
  │   ├── Dockerfile      # Docker config for backend
  │   └── docker-compose.yml # Multi-service orchestration
  ├── assets/             # Fonts and other assets
  ├── pubspec.yaml        # Flutter dependencies
  └── README.md           # Project documentation
```

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Node.js](https://nodejs.org/)
- [Docker](https://www.docker.com/) (for backend, optional)

---

### 1. Clone the Repository

```sh
git clone https://github.com/yourusername/task_offline_first.git
cd task_offline_first
```

---

### 2. Run the Flutter App

```sh
cd task_offline_first
flutter pub get
flutter run
```

---

### 3. Run the Backend Server

#### Using Docker (Recommended)

```sh
cd server
docker-compose up --build
```

#### Or Manually

```sh
cd server
npm install
npm run dev
```

The backend will be available at `http://localhost:8000`.

---

## API Endpoints

### Auth

- `POST /auth/signup` — Register a new user
- `POST /auth/login` — Log in and receive JWT
- `POST /auth/tokenIsValid` — Validate JWT
- `GET /auth` — Get user info (requires JWT)

### Tasks

- `GET /task` — Get all tasks for the user
- `POST /task` — Create a new task
- `DELETE /task` — Delete a task
- `POST /task/sync` — Sync unsynced tasks (for offline support)

---

## Offline-First Details

- **Local Storage**: Uses SQLite to store tasks and user info.
- **Sync Logic**: Tasks created offline are marked as unsynced and pushed to the server when a connection is available.
- **Instant Feedback**: All actions are reflected immediately in the UI, even when offline.

---

## Environment Variables

- **Flutter**: No special setup required for local/offline use.
- **Backend**: See `server/docker-compose.yml` for environment variables (e.g., `DATABASE_URL`).

---

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

---

## License

[MIT](LICENSE)
