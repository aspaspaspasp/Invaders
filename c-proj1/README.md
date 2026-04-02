# Claude (Anthropic) minimal Python setup

## Setup

```bash
cd /Users/mobirou/c-proj1
python3 -m venv .venv
./.venv/bin/pip install -r requirements.txt
cp .env.example .env
```

Edit `.env` and set `ANTHROPIC_API_KEY`.

## Run

```bash
./.venv/bin/python claude_demo.py "Explain monads in one paragraph."
```

Optionally choose a model:

```bash
./.venv/bin/python claude_demo.py --model claude-3-5-sonnet-20241022 "Hello!"
```
