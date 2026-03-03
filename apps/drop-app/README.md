# drop-app on GoW

Docker image for running [Drop](https://github.com/Drop-OSS/drop-app) on [Games on Whales](https://github.com/games-on-whales/gow) (`base-app:edge`).

## Usage

```bash
docker pull ghcr.io/Baz00k/drop-app:edge
```

## Configuration

| Variable | Description |
|----------|-------------|
| `DROP_SERVER_URL` | Your Drop server URL |
| `PUID` / `PGID` | User/group IDs (default: 1000) |
| `RUN_GAMESCOPE` | Use gamescope compositor |
| `GAMESCOPE_WIDTH` | Display width (default: 1920) |
| `GAMESCOPE_HEIGHT` | Display height (default: 1080) |

## Wolf

Example `apps.toml` entry:

```toml
[apps.drop]
title = "Drop"
icon_png_path = "https://raw.githubusercontent.com/Drop-OSS/drop-app/develop/src-tauri/icons/icon.png"
start_virtual_compositor = true

[apps.drop.runner]
type = "docker"
name = "drop-app"
image = "ghcr.io/Baz00k/drop-app:edge"
env = ["DROP_SERVER_URL=https://your-server.example.com"]
```

## Tags

- `edge` — latest main branch build
- `vX.Y.Z` — release versions
- `sha-abc1234` — commit-pinned

## Updates

Upstream dependency updates (base image, drop-app releases) are detected weekly and proposed as PRs automatically.

## Rollback

```bash
docker pull ghcr.io/Baz00k/drop-app@sha256:<digest>
```
