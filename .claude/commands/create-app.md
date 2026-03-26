Create a new application on Coolify.

Usage: /create-app

This is an interactive command. Walk the user through creating an application:

1. Ask for the application type:
   - Public Git repository (`/applications/public`)
   - Private GitHub App (`/applications/private-github-app`)
   - Private Deploy Key (`/applications/private-deploy-key`)
   - Dockerfile (`/applications/dockerfile`)
   - Docker Image (`/applications/dockerimage`)

2. Gather required parameters based on type:
   - For git-based: repository URL, branch, build pack
   - For Docker image: image name, ports
   - Common: server_uuid, project_uuid, environment_name

3. Help the user find UUIDs by running `./scripts/coolify servers` and `./scripts/coolify projects` if needed

4. Ask about optional settings:
   - `instant_deploy`: Deploy immediately? (default: true)
   - `autogenerate_domain`: Auto-generate domain? (default: true)
   - Custom FQDN

5. Build the JSON body and run: `./scripts/coolify raw POST /applications/<type> '<json>'`

6. Show the result and the new application UUID
