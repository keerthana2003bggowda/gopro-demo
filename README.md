### 4. Go App


**Language:** Go (Golang)

gopro-demo

A small Go (net/http, standard library only) web application, serving static pages and a couple of API endpoints, containerized with a multi-stage Docker build and deployed via a Jenkins CI/CD pipeline to Docker Hub and an EC2 host.

What this application does

gopro-demo is a minimal Go HTTP server built with the standard library (no framework/router) 

Routes
Method	Path	    Behavior
GET	    /	        Serves static files from ./static (index.html, form.html, etc.)
POST	/form	    Parses submitted form data and echoes back name and address fields
GET	     /hello	    Returns hello!; returns 404 for any other path/method

Once deployed, the app is reachable at:

http://<host>:8081/
http://<host>:8081/hello

(Container listens internally on 3001; the host maps external port 8081 to it.)

Tech stack
Language: Go 1.22 (standard library net/http only — no external router/framework)
Containerization: Docker (multi-stage build — Go build stage → Alpine runtime stage)
CI/CD: Jenkins (declarative pipeline)
Registry: Docker Hub
Code quality: SonarQube (sonar-project.properties present for scan config)
Deployment target: AWS EC2 (container run directly on host via Docker)

Project structure
gopro-demo/
├── static/
│   ├── form.html               # Form page — POSTs to /form
│   └── index.html              # Landing page, served at "/"
├── main.go                     # Entire application — HTTP server, routes, handlers
├── go.mod                      # Go module definition
├── Dockerfile                  # Multi-stage image build definition
├── Jenkinsfile                 # Docker-based CI/CD pipeline (build → push → deploy)
├── JenkinsfileD                # Secondary pipeline definition (see note below)
├── sonar-project.properties    # SonarQube scanner configuration
└── README.md


## CI/CD Pipeline — VM Deployment (gopro-demo)

**Agent:** `go`

### Environment Variables
| Variable | Value |
|----------|-------|
| `PATH` | Prepends `/usr/local/go/bin` to existing `PATH` |
| `JFROG_CREDS` | Bound from `artifactory-creds` (exposes `_USR` / `_PSW`) |
| `JFROG_URL` | `http://13.233.212.44:8082/artifactory/go-artifacts` |

### Pipeline Stages

| Stage | Description |
|-------|-------------|
| **Checkout** | Pulls `main` branch from GitHub using `github-pat` credentials |
| **Build** | Compiles Go binary: `go build -o gopro main.go` |
| **SonarQube Analysis** | Runs code quality scan via `sonar-scanner` under `sonarqube` server config |
| **Publish to JFrog** | Uploads `gopro` binary to Artifactory via `curl`, versioned by `BUILD_NUMBER` |
| **Deploy** | Runs compiled binary in background: `nohup ./gopro &` |


### Prerequisites
- Jenkins credentials configured: `github-pat`, `artifactory-creds`
- Go toolchain installed at `/usr/local/go` on `go` agent
- `sonar-scanner` tool configured in Jenkins Global Tool Config
- `sonarqube` server configured under Manage Jenkins → System

### Notes
- Deployment type: **VM-based**
- Artifact: raw Go binary named `gopro-<BUILD_NUMBER>` (no extension/archive)
- Uses `credentials()` helper (top-level env binding) instead of `withCredentials{}` block — credentials are available for the whole pipeline duration, not scoped to a single stage


## CI/CD Pipeline — Docker Deployment (gopro-demo)

**Agent:** `go`

### Environment Variables
| Variable | Value |
|----------|-------|
| `IMAGE` | `docker.io/keerthana2003bggowd/gopro-demo` |
| `TAG` | `${BUILD_NUMBER}` |
| `CONTAINER` | `gopro-demo` |

### Pipeline Stages

| Stage | Description |
|-------|-------------|
| **Checkout** | Pulls `main` branch from GitHub using `github-pat` credentials |
| **Build** | Builds Docker image, tagged with both `BUILD_NUMBER` and `latest` |
| **Push** | Logs into Docker Hub using `dockerhub-creds`, pushes both tags |
| **Deploy** | Pulls freshly built image, removes existing container, runs new container mapping host `8081` → container `3001` |
| **Cleanup** | Cleans Jenkins workspace after pipeline run |

### Prerequisites
- Jenkins credentials configured: `github-pat`, `dockerhub-creds`
- Docker installed on `go` agent, Jenkins user has Docker permissions
- Dockerfile present at repo root (app listens on port `3001` internally)

### Notes
- Deployment type: **Docker-based**
- Port mapping **8081:3001** — differs from VM variant, which doesn't document a port at all; worth confirming Go app's actual listen port matches `3001` here
- Container force-removed before redeploy — clean state, no port conflicts

## CI/CD Pipeline — Kubernetes Deployment (gopro-demo)

**Agent:** `go`

### Environment Variables
| Variable | Value |
|----------|-------|
| `IMAGE` | `docker.io/keerthana2003bggowd/gopro-demo` |
| `TAG` | `${BUILD_NUMBER}` |
| `CONTAINER` | `gopro-demo` |
| `ARTIFACTORY_DOCKER_REGISTRY` | `15.206.165.22:8081/artifactory/api/docker/docker-local` |
| `ARTIFACTORY_IMAGE` | `${ARTIFACTORY_DOCKER_REGISTRY}/gopro-demo` |

### Pipeline Stages

| Stage | Description |
|-------|-------------|
| **Checkout** | Pulls `main` branch from GitHub using `github-pat` credentials |
| **Build** | Builds Docker image, tagged with both `BUILD_NUMBER` and `latest` |
| **SonarQube Analysis** | Runs code quality scan via `sonar-scanner` under `sonarqube` server config |
| **Push** | Logs into Docker Hub using `dockerhub-creds`, pushes both tags |
| **Deploy** | Applies `k8s-deploy.yaml` manifest to Kubernetes cluster via `kubectl apply` |



### Prerequisites
- Jenkins credentials configured: `github-pat`, `dockerhub-creds` (and `artifactory-creds` if JFrog stage is re-enabled)
- Docker installed on `go` agent, Jenkins user has Docker permissions
- `sonar-scanner` tool configured in Jenkins Global Tool Config
- `sonarqube` server configured under Manage Jenkins → System
- `kubectl` installed and configured on agent with cluster access (kubeconfig)
- `k8s-deploy.yaml` manifest present in repo, references `$IMAGE:$TAG` or `latest`

### Notes
- Deployment type: **Kubernetes-based**

