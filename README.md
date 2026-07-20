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