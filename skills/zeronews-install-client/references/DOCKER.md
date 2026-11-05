# Docker Install

Docker is supported on Linux hosts with Docker available. Use it when the user wants containerized deployment or already operates services through Docker.

## AuthToken rule

Before generating any Docker command:

1. ask the user for AuthToken
2. confirm install method is Docker
3. only then substitute `{TOKEN}` into the command

Auth is injected through the `TOKEN` environment variable. Do not run a separate `zeronews authtoken` step for first-time Docker setup.

## Official images

| Registry | Image | Typical network |
| --- | --- | --- |
| ZeroNews China mirror | `docker.zeronews.cc/zeronews/zeronews` | domestic / default in docs |
| Docker Hub | `zeronews/zeronews` | overseas |

Default data directory on host:

```text
/opt/zeronews
```

Container config mount:

```text
/opt/zeronews:/etc/zeronews
```

Network mode must be `host`.

## Docker Run — China mirror

Create data directory:

```bash
mkdir -p /opt/zeronews
```

Run container:

```bash
docker run -d --name zeronews --net host \
  -v /opt/zeronews:/etc/zeronews \
  -e TOKEN={TOKEN} \
  docker.zeronews.cc/zeronews/zeronews
```

Use `sudo docker ...` when the current user is not root and not in the `docker` group. If `id -u` is `0`, run `docker ...` directly. See `../../configure-client/references/PRIVILEGE-EXECUTION.md`.

## Docker Run — Docker Hub

```bash
mkdir -p /opt/zeronews

docker run -d --name zeronews --net host \
  -v /opt/zeronews:/etc/zeronews \
  -e TOKEN={TOKEN} \
  zeronews/zeronews
```

## Docker Compose — China mirror

```bash
mkdir -p /opt/zeronews && cd /opt/zeronews
```

Write `docker-compose.yml`:

```yaml
services:
  zeronews:
    restart: always
    image: docker.zeronews.cc/zeronews/zeronews
    container_name: zeronews
    hostname: zeronews
    network_mode: host
    volumes:
      - ./zeronews:/etc/zeronews
    environment:
      - TZ=Asia/Shanghai
      - TOKEN={TOKEN}
```

Start:

```bash
docker compose up -d
```

## Docker Compose — Docker Hub

Same as above, but set:

```yaml
image: zeronews/zeronews
```

## Verify

Check container state:

```bash
docker ps
```

Inspect recent logs:

```bash
docker logs zeronews --tail 50
```

Healthy signs:

- container status is `Up`
- logs do not show auth failure or fatal startup errors
- device appears online in the ZeroNews console

## Operational notes

- `{TOKEN}` must be collected from the user during the install conversation
- avoid committing compose files containing real tokens
- if a container already exists with the same name, ask before removing or recreating it
- config persists under the mounted host directory; recreating the container with the same volume preserves state
- for tunnel creation after Docker install, use the normal CLI/API flows against the running containerized client only if the docs or runtime setup expose that path; otherwise guide the user through the console
