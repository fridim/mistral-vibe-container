# Mistral Vibe Container

Run [Mistral Vibe](https://github.com/mistralai/mistral-vibe) in a container for vibe coding with Mistral AI.

## Prerequisites

- Podman (or Docker with minor script modifications)
- Buildah (for building the container)
- A Mistral API key from [console.mistral.ai](https://console.mistral.ai)

## Quick Start

1. **Set your Mistral API key (first time only):**

   ```bash
   export MISTRAL_API_KEY="your-api-key-here"
   ```

2. **Run from any project directory:**

   ```bash
   /path/to/mistral-vibe-container/vibe
   ```

   The first run will automatically:
   - Build the container image
   - Create a podman secret for your API key
   - Remember the key for future runs (no need to set env var again)

3. **Subsequent runs (no env var needed):**

   ```bash
   /path/to/mistral-vibe-container/vibe
   ```

## Files

| File | Description |
|------|-------------|
| `Containerfile` | Container definition (Fedora + Python 3.12 + uv) |
| `build.sh` | Build script for the container image |
| `vibe` | Launch script to run mistral-vibe in a container |
| `environment` | Shell environment setup |
| `packages.txt` | Additional Fedora packages to install |
| `sudoers` | Sudo permissions for the container user |

## Configuration

### API Key

The `MISTRAL_API_KEY` environment variable is automatically managed as a podman secret:

- **First run with API key**: Sets up the podman secret automatically
- **Subsequent runs**: Uses the existing secret (no need to set env var again)
- **To update**: Remove the existing secret and provide the new key

```bash
# First time setup (or to update)
export MISTRAL_API_KEY="your-api-key-here"
./vibe

# After first setup, just run without env var
./vibe
```

To manually update the API key:
```bash
podman secret rm mistral-api-key
export MISTRAL_API_KEY="new-key"
./vibe
```

### GitHub Token

GitHub tokens are also managed as podman secrets:

```bash
# Set GitHub token
export GH_TOKEN="ghp_your_token"
./vibe

# Or create manually
podman secret rm mistral-github-token
echo "ghp_your_token" | podman secret create mistral-github-token -
```

### Vibe Configuration

Configuration is stored in `~/.vibe/` on your host and mounted into the container. See the [Mistral Vibe documentation](https://github.com/mistralai/mistral-vibe#configuration) for configuration options.

## Rebuilding

To rebuild the container (e.g., after mistral-vibe updates):

```bash
./build.sh --rebuild
```

## What Gets Mounted

- Your current project directory → `/projects/<project-name>`
- `~/.vibe` → `/home/vibe/.vibe` (configuration)
- `~/.gitconfig` → `/home/vibe/.gitconfig` (git config, read-only)
- `~/.config/git` → `/home/vibe/.config/git` (additional git config, read-only)
