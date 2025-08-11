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
  ./bin/up.sh

down:
  ./bin/down.sh
