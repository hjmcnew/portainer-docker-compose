# Portainer Docker Compose

Docker Compose configurations for deploying [Portainer EE](https://www.portainer.io/) with automated Let's Encrypt SSL certificates via DNS-01 challenge (Route53).

## Repository Structure

```
portainer/             # Portainer EE server with SSL and cert automation
  docker-compose.yaml
portainer-agent/       # Standalone Portainer Agent for remote endpoints
  docker-compose.yaml
```

## Components

### Portainer Server (`portainer/`)

The main compose file deploys three services:

- **Portainer EE** — management UI served over TLS on port `9443`
- **Certbot** — obtains and stores Let's Encrypt certificates using the `dns-route53` plugin
- **Ofelia** — cron scheduler that renews certificates weekly and restarts Portainer when certs are updated

The Portainer Agent is included via compose `include` from `portainer-agent/docker-compose.yaml`.

### Portainer Agent (`portainer-agent/`)

A standalone Portainer Agent deployment on port `9001`, suitable for adding remote Docker endpoints to your Portainer instance.

## Prerequisites

- Docker Engine with Compose V2 (`docker compose`)
- An AWS Route53-hosted domain (for DNS-01 certificate validation)
- AWS credentials with Route53 permissions

## Getting Started

1. Clone the repository:

    ```sh
    git clone https://github.com/hjmcnew/portainer-docker-compose.git
    cd portainer-docker-compose
    ```

2. Create a `.env` file in the `portainer/` directory with your configuration:

    ```env
    DOMAIN=portainer.example.com
    EMAIL=you@example.com
    AWS_ACCESS_KEY_ID=your-key-id
    AWS_SECRET_ACCESS_KEY=your-secret-key
    ```

3. Start the stack:

    ```sh
    cd portainer
    docker compose up -d
    ```

    Certbot will obtain a certificate on first run. The healthcheck waits for the cert to be issued before Portainer starts.

4. Access Portainer at `https://your-domain:9443`.

### Deploying Only the Agent

To deploy just the Portainer Agent on a remote host:

```sh
cd portainer-agent
docker compose up -d
```

## Certificate Renewal

Ofelia handles automated renewal on a weekly schedule:

1. Certbot attempts renewal and sets a flag file if the certificate was updated
2. A follow-up job checks for the flag, restarts Portainer to load the new cert, and clears the flag

No manual intervention is required.

## CI

- **Docker Compose Lint** — validates compose files on push and PRs using [dclint](https://github.com/zavoloklom/docker-compose-linter)
- **Dependabot** — monitors for Docker image and GitHub Actions updates weekly (major version bumps are ignored for Docker images)

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature/your-feature-name`).
3. Make your changes.
4. Commit your changes (`git commit -m 'Add some feature'`).
5. Push to the branch (`git push origin feature/your-feature-name`).
6. Open a Pull Request.

## License

This project is licensed under the BSD 3-Clause License — see the [LICENSE](LICENSE) file for details.
