# DevContainer C++ Test

Image Docker partagée pour le développement C++.

## Image

```
ghcr.io/nikolaspaci/devcontainercpptest:latest
```

## Contenu

- **OS**: Ubuntu 24.04
- **LLVM 18**: clang, clang++, clangd, lld, lldb, clang-format, clang-tidy
- **Build**: cmake, ninja
- **Cache**: sccache
- **Python**: 3.12
- **User**: dev (UID/GID 1000)

## Utilisation dans un repo

Créer `.devcontainer/devcontainer.json` :

```json
{
  "name": "Mon Projet",
  "image": "ghcr.io/nikolaspaci/devcontainercpptest:latest",

  "workspaceFolder": "/workspace",
  "workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind,consistency=cached",

  "mounts": [
    "source=${localWorkspaceFolder}/.sccache,target=/home/dev/.sccache,type=bind"
  ],

  "containerEnv": {
    "SCCACHE_DIR": "/home/dev/.sccache"
  },

  "runArgs": [
    "--cap-add=SYS_PTRACE",
    "--security-opt", "seccomp=unconfined"
  ],

  "remoteUser": "dev",

  "postCreateCommand": "cmake -B build -G Ninja -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
}
```

## Build local

```bash
docker build -t neuroine-dev .
```

## CI/CD

Le workflow GitHub Actions build et push automatiquement l'image sur GHCR lors des modifications du Dockerfile.

Architectures supportées: `linux/amd64`, `linux/arm64`
