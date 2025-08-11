dev-venv:
  uv venv
  uv sync --all-groups --compile-bytecode

dev-dependencies:
  uv sync --all-groups --compile-bytecode

run:
  uv run uvicorn main:app --host 0.0.0.0 --port 8000 --reload

format:
  uv run isort ./
  uv run black ./

up:
  echo "Use one of: just up-ngrok or just up-cloudflare"

up-ngrok:
  ./bin/up-ngrok.sh

up-cloudflare:
  ./bin/up-cloudflare.sh

down:
  ./bin/down.sh
