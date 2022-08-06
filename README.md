# myapp_version_upgrader
Upgrade runtime versions for my apps

## Setup
### 1. Create GitHub App
https://github.com/settings/apps/new

Repository permissions

* Contents: Read and Write
* Pull requests: Read and Write
* Metadata: Read-only
* Workflows: Read and Write

Download private key

### 2. Register Repository secrets
`${repository_url}/settings/secrets/actions`

* `GH_APP_ID` : GitHub App ID
* `GH_PRIVATE_KEY` : GitHub App Private key
* `SLACK_WEBHOOK`

### 3. Install App to repository
