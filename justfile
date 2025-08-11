#!/usr/bin/env just

set shell := ["bash", "-c"]

default:
  @just --list

dev-venv:
  uv venv
  uv sync --all-groups --compile-bytecode

dev-dependencies:
  uv sync --all-groups --compile-bytecode

dev:
  uv run uvicorn main:app --host 0.0.0.0 --port $PORT --reload

format:
  uv run isort ./
  uv run black ./

up:
  ./bin/up.sh

down:
  ./bin/down.sh
