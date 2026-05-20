# StartTech Full-Stack Application Layer

Welcome to the central runtime engine repo for the StartTech enterprise dashboard system. This repository houses our React static client code base and our high-performance asynchronous REST API built in Go.

## Application Components Summary

* **Frontend Framework:** React SPA utilizing Vite as its bundling and compilation engine. Served from AWS S3 over CloudFront CDN.
* **Backend Framework:** High-performance Go REST engine using Gin Gonic for routing and architecture controls. Runs via Docker on AWS EC2 behind an ALB.
* **Persistence & State:** Integrated with managed cluster fabrics on MongoDB Atlas for records and Amazon ElastiCache Redis for distributed session caching.

---

## Workspace Directory Schema

```text
starttech-application/
├── backend/                  # Core Go API microservice code
│   ├── cmd/api/main.go      # Primary execution engine and router maps
│   ├── internal/            # Auth, database abstraction, middleware engine
│   ├── Dockerfile           # Optimized multi-stage build setup
│   └── go.mod               # Dependency tracking map
├── frontend/                 # Client interface application workspace
│   ├── src/                 # Application dashboard visual views
│   ├── package.json         # Node runtime manifest definitions
│   └── vite.config.js       # Compilation rules
├── deploy-frontend.sh       # S3 Delivery build engine automation script
├── health-check.sh          # Synthetic API endpoint verification engine
└── rollback.sh              # Fallback orchestration script