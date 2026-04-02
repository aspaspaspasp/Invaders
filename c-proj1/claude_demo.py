import argparse
import os
import sys

from anthropic import Anthropic
from dotenv import load_dotenv


def main() -> int:
    load_dotenv()

    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        print("Missing ANTHROPIC_API_KEY. Copy .env.example to .env and set it.", file=sys.stderr)
        return 2

    parser = argparse.ArgumentParser(description="Minimal Anthropic Claude demo.")
    parser.add_argument(
        "prompt",
        nargs="?",
        default="Write a haiku about local-first developer tools.",
        help="User prompt to send to Claude.",
    )
    parser.add_argument(
        "--model",
        default=os.getenv("ANTHROPIC_MODEL", "claude-3-5-sonnet-20241022"),
        help="Model name (or set ANTHROPIC_MODEL).",
    )
    parser.add_argument("--max-tokens", type=int, default=256, help="Max output tokens.")
    args = parser.parse_args()

    client = Anthropic(api_key=api_key)
    msg = client.messages.create(
        model=args.model,
        max_tokens=args.max_tokens,
        messages=[{"role": "user", "content": args.prompt}],
    )

    text = "".join(getattr(block, "text", "") for block in msg.content)
    print(text.strip())
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
