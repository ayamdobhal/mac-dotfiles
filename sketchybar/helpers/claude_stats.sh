#!/usr/bin/python3
"""Summarize local Claude Code and Codex usage for the SketchyBar widget."""

from __future__ import annotations

import glob
import json
import os
import time
from collections import Counter
from datetime import datetime, timedelta, timezone


NOW = datetime.now(timezone.utc)
CUTOFF = NOW - timedelta(days=30)

# Prices are USD per million tokens.
CLAUDE_PRICING = {
    "claude-opus-4-8": {"input": 5, "output": 25, "cache_write": 6.25, "cache_read": 0.50},
    "claude-opus-4-7": {"input": 5, "output": 25, "cache_write": 6.25, "cache_read": 0.50},
    "claude-opus-4-6": {"input": 5, "output": 25, "cache_write": 6.25, "cache_read": 0.50},
    "claude-opus-4-5": {"input": 5, "output": 25, "cache_write": 6.25, "cache_read": 0.50},
    "claude-opus-4-1": {"input": 15, "output": 75, "cache_write": 18.75, "cache_read": 1.50},
    "claude-opus-4": {"input": 15, "output": 75, "cache_write": 18.75, "cache_read": 1.50},
    "claude-sonnet-4-6": {"input": 3, "output": 15, "cache_write": 3.75, "cache_read": 0.30},
    "claude-sonnet-4-5": {"input": 3, "output": 15, "cache_write": 3.75, "cache_read": 0.30},
    "claude-sonnet-4": {"input": 3, "output": 15, "cache_write": 3.75, "cache_read": 0.30},
    "claude-haiku-4-5": {"input": 1, "output": 5, "cache_write": 1.25, "cache_read": 0.10},
    "claude-haiku-3-5": {"input": 0.80, "output": 4, "cache_write": 1, "cache_read": 0.08},
}
DEFAULT_CLAUDE_PRICING = CLAUDE_PRICING["claude-sonnet-4-5"]

CODEX_PRICING = {
    "gpt-5.5": {
        "input": 5.00,
        "cached_input": 0.50,
        "output": 30.00,
        "long_context_threshold": 272_000,
        "long_context_input_multiplier": 2.0,
        "long_context_output_multiplier": 1.5,
    },
    "gpt-5.5-pro": {"input": 30.00, "cached_input": 30.00, "output": 180.00},
    "gpt-5.4-mini": {"input": 0.75, "cached_input": 0.075, "output": 4.50},
    "gpt-5.4-pro": {
        "input": 30.00,
        "cached_input": 30.00,
        "output": 180.00,
        "long_context_threshold": 272_000,
        "long_context_input_multiplier": 2.0,
        "long_context_output_multiplier": 1.5,
    },
    "gpt-5.4": {
        "input": 2.50,
        "cached_input": 0.25,
        "output": 15.00,
        "long_context_threshold": 272_000,
        "long_context_input_multiplier": 2.0,
        "long_context_output_multiplier": 1.5,
    },
    "gpt-5.2-codex": {"input": 1.75, "cached_input": 0.175, "output": 14.00},
    "gpt-5.2": {"input": 1.75, "cached_input": 0.175, "output": 14.00},
    "gpt-5.1-codex": {"input": 1.25, "cached_input": 0.125, "output": 10.00},
    "gpt-5-codex": {"input": 1.25, "cached_input": 0.125, "output": 10.00},
    "gpt-5": {"input": 1.25, "cached_input": 0.125, "output": 10.00},
}
DEFAULT_CODEX_PRICING = CODEX_PRICING["gpt-5.5"]


def parse_timestamp(value: str | None) -> datetime | None:
    if not value:
        return None
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return None


def model_price(prices: dict[str, dict[str, float]], model: str, default: dict[str, float]) -> dict[str, float]:
    normalized = (model or "").lower()
    if normalized in prices:
        return prices[normalized]
    for prefix in sorted(prices, key=len, reverse=True):
        if normalized.startswith(prefix):
            return prices[prefix]
    return default


def claude_cost(usage: dict, model: str) -> float:
    price = model_price(CLAUDE_PRICING, model, DEFAULT_CLAUDE_PRICING)
    input_tokens = usage.get("input_tokens") or 0
    output_tokens = usage.get("output_tokens") or 0
    cache_write_tokens = usage.get("cache_creation_input_tokens") or 0
    cache_read_tokens = usage.get("cache_read_input_tokens") or 0

    # Claude Code logs do not split 5m vs 1h cache writes; use the standard 5m
    # cache write API rate for cache_creation_input_tokens.
    return (
        input_tokens * price["input"]
        + output_tokens * price["output"]
        + cache_write_tokens * price["cache_write"]
        + cache_read_tokens * price["cache_read"]
    ) / 1_000_000


def codex_cost(usage: dict, model: str) -> float:
    price = model_price(CODEX_PRICING, model, DEFAULT_CODEX_PRICING)
    input_tokens = usage.get("input_tokens") or 0
    cached_input_tokens = usage.get("cached_input_tokens") or 0
    billable_input_tokens = max(0, input_tokens - cached_input_tokens)
    input_multiplier = 1.0
    output_multiplier = 1.0
    if codex_uses_long_context(usage, price):
        input_multiplier = price.get("long_context_input_multiplier", 1.0)
        output_multiplier = price.get("long_context_output_multiplier", 1.0)
    return (
        billable_input_tokens * price["input"] * input_multiplier
        + cached_input_tokens * price["cached_input"] * input_multiplier
        + (usage.get("output_tokens") or 0) * price["output"] * output_multiplier
    ) / 1_000_000


def codex_uses_long_context(usage: dict, price: dict[str, float]) -> bool:
    threshold = price.get("long_context_threshold")
    return threshold is not None and (usage.get("input_tokens") or 0) > threshold


def reset_label(epoch: int | float | None) -> str:
    if not epoch:
        return ""
    diff = int(epoch - time.time())
    if diff <= 0:
        return "now"
    if diff < 3600:
        return f"{diff // 60}m"
    if diff < 86400:
        return f"{diff // 3600}h {(diff % 3600) // 60}m"
    return datetime.fromtimestamp(epoch).strftime("%b %d %H:%M")


def summarize_claude() -> dict[str, object]:
    base = os.path.expanduser("~/.claude/projects")
    sessions: set[str] = set()
    models: Counter[str] = Counter()
    totals: Counter[str] = Counter()
    messages = 0
    tool_calls = 0
    cost = 0.0
    latest_model = None
    latest_model_at = None

    for path in glob.glob(os.path.join(base, "*", "*.jsonl")):
        try:
            if datetime.fromtimestamp(os.path.getmtime(path), timezone.utc) < CUTOFF:
                continue
        except OSError:
            continue

        counted_session = False
        try:
            handle = open(path)
        except OSError:
            continue

        with handle:
            for line in handle:
                try:
                    item = json.loads(line)
                except json.JSONDecodeError:
                    continue

                ts = parse_timestamp(item.get("timestamp"))
                if ts is None or ts < CUTOFF:
                    continue

                if not counted_session:
                    sessions.add(path)
                    counted_session = True

                item_type = item.get("type")
                if item_type in ("user", "assistant"):
                    messages += 1

                if item_type != "assistant":
                    continue

                message = item.get("message") or {}
                usage = message.get("usage") or {}
                model = message.get("model") or "unknown"
                models[model] += 1
                if latest_model_at is None or ts > latest_model_at:
                    latest_model = model
                    latest_model_at = ts
                cost += claude_cost(usage, model)

                totals["input_tokens"] += usage.get("input_tokens") or 0
                totals["output_tokens"] += usage.get("output_tokens") or 0
                totals["cache_creation_input_tokens"] += usage.get("cache_creation_input_tokens") or 0
                totals["cache_read_input_tokens"] += usage.get("cache_read_input_tokens") or 0

                content = message.get("content") or []
                if isinstance(content, list):
                    tool_calls += sum(
                        1
                        for block in content
                        if isinstance(block, dict) and block.get("type") == "tool_use"
                    )

    total_tokens = (
        totals["input_tokens"]
        + totals["output_tokens"]
        + totals["cache_creation_input_tokens"]
        + totals["cache_read_input_tokens"]
    )
    cached_input_tokens = (
        totals["cache_creation_input_tokens"]
        + totals["cache_read_input_tokens"]
    )
    top_model = models.most_common(1)[0][0] if models else "n/a"

    return {
        "claude_sessions": len(sessions),
        "claude_messages": messages,
        "claude_tool_calls": tool_calls,
        "claude_input_tokens": totals["input_tokens"],
        "claude_cached_input_tokens": cached_input_tokens,
        "claude_uncached_input_tokens": totals["input_tokens"],
        "claude_output_tokens": totals["output_tokens"],
        "claude_cache_write_tokens": totals["cache_creation_input_tokens"],
        "claude_cache_read_tokens": totals["cache_read_input_tokens"],
        "claude_total_tokens": total_tokens,
        "claude_cost_usd": f"{cost:.2f}",
        "claude_model": latest_model or top_model,
        "claude_top_model": top_model,
    }


def summarize_codex() -> dict[str, object]:
    base = os.path.expanduser("~/.codex/sessions")
    sessions: set[str] = set()
    models: Counter[str] = Counter()
    totals: Counter[str] = Counter()
    cost = 0.0
    latest_rate_limits: tuple[datetime, dict] | None = None

    for path in glob.glob(os.path.join(base, "**", "*.jsonl"), recursive=True):
        try:
            if datetime.fromtimestamp(os.path.getmtime(path), timezone.utc) < CUTOFF:
                continue
        except OSError:
            continue

        current_model = None
        session_id = path
        try:
            handle = open(path)
        except OSError:
            continue

        with handle:
            for line in handle:
                try:
                    item = json.loads(line)
                except json.JSONDecodeError:
                    continue

                payload = item.get("payload") or {}
                item_type = item.get("type")
                if item_type == "session_meta":
                    session_id = payload.get("id") or session_id
                elif item_type == "turn_context":
                    current_model = payload.get("model") or current_model

                ts = parse_timestamp(item.get("timestamp"))
                if ts is None or ts < CUTOFF:
                    continue

                rate_limits = payload.get("rate_limits")
                has_limit_state = isinstance(rate_limits, dict) and any(
                    rate_limits.get(key) for key in ("primary", "secondary", "credits")
                )
                if has_limit_state and (latest_rate_limits is None or ts > latest_rate_limits[0]):
                    latest_rate_limits = (ts, rate_limits)

                if payload.get("type") != "token_count":
                    continue

                usage = ((payload.get("info") or {}).get("last_token_usage") or {})
                model = current_model or "unknown"
                models[model] += 1
                sessions.add(session_id)
                cost += codex_cost(usage, model)
                price = model_price(CODEX_PRICING, model, DEFAULT_CODEX_PRICING)
                if codex_uses_long_context(usage, price):
                    totals["long_context_requests"] += 1
                    totals["long_context_input_tokens"] += usage.get("input_tokens") or 0
                    totals["long_context_output_tokens"] += usage.get("output_tokens") or 0

                totals["input_tokens"] += usage.get("input_tokens") or 0
                totals["cached_input_tokens"] += usage.get("cached_input_tokens") or 0
                totals["output_tokens"] += usage.get("output_tokens") or 0
                totals["reasoning_output_tokens"] += usage.get("reasoning_output_tokens") or 0
                totals["total_tokens"] += usage.get("total_tokens") or 0

    top_model = models.most_common(1)[0][0] if models else "n/a"
    rate_limits = latest_rate_limits[1] if latest_rate_limits else {}
    primary = rate_limits.get("primary") or {}
    secondary = rate_limits.get("secondary") or {}
    credit_state = rate_limits.get("credits") or {}

    if credit_state.get("unlimited"):
        credit_status = "unlimited"
    elif credit_state.get("has_credits") is False:
        credit_status = "none"
    elif credit_state.get("has_credits"):
        credit_status = "available"
    else:
        credit_status = "n/a"

    return {
        "codex_sessions": len(sessions),
        "codex_input_tokens": totals["input_tokens"],
        "codex_cached_input_tokens": totals["cached_input_tokens"],
        "codex_uncached_input_tokens": max(
            0, totals["input_tokens"] - totals["cached_input_tokens"]
        ),
        "codex_output_tokens": totals["output_tokens"],
        "codex_reasoning_output_tokens": totals["reasoning_output_tokens"],
        "codex_total_tokens": totals["total_tokens"],
        "codex_long_context_requests": totals["long_context_requests"],
        "codex_long_context_input_tokens": totals["long_context_input_tokens"],
        "codex_long_context_output_tokens": totals["long_context_output_tokens"],
        "codex_cost_usd": f"{cost:.2f}",
        "codex_model": top_model,
        "codex_plan": rate_limits.get("plan_type") or "n/a",
        "codex_credit_status": credit_status,
        "codex_credit_balance": credit_state.get("balance") or "",
        "codex_primary_pct": primary.get("used_percent", ""),
        "codex_primary_window": primary.get("window_minutes", ""),
        "codex_primary_reset": reset_label(primary.get("resets_at")),
        "codex_secondary_pct": secondary.get("used_percent", ""),
        "codex_secondary_window": secondary.get("window_minutes", ""),
        "codex_secondary_reset": reset_label(secondary.get("resets_at")),
    }


def main() -> None:
    data = {
        "period_days": 30,
        "generated_at": NOW.isoformat(),
    }
    data.update(summarize_claude())
    data.update(summarize_codex())

    for key in sorted(data):
        print(f"{key}={data[key]}")


if __name__ == "__main__":
    main()
