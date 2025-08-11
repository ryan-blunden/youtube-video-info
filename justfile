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
  doppler run --command 'uv run uvicorn main:app --host 0.0.0.0 --port ${PORT:-8000} --reload'

format:
  uv run isort ./
  uv run black ./

up:
  ./bin/up

down:
  ./bin/down
