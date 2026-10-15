#!/usr/bin/env python3
"""Print a co-author trailer for the model running the active coding-agent session.

Supports Codex, Claude Code, and GitHub Copilot CLI. Reads only the active
session; config defaults and Git history are never used.
"""

import argparse
import json
import os
from pathlib import Path
import re
import sys

ID_RE = r"[A-Za-z0-9_-]+"
EFFORT_RE = r"[A-Za-z0-9][A-Za-z0-9_-]*"
MODEL_RE = r"[A-Za-z0-9][A-Za-z0-9._:-]*"
COPILOT_EMAIL = "223556219+Copilot@users.noreply.github.com"


def detect_tool():
    active = []
    if os.environ.get("CODEX_THREAD_ID") or os.environ.get("CODEX_SESSION_ID"):
        active.append("codex")
    if os.environ.get("CLAUDE_CODE_SESSION_ID"):
        active.append("claude")
    if os.environ.get("COPILOT_AGENT_SESSION_ID"):
        active.append("copilot")
    if len(active) > 1:
        raise ValueError("multiple active coding-agent sessions detected; specify --tool")
    if not active:
        raise ValueError("no active Codex, Claude Code, or Copilot CLI session detected")
    return active[0]


def valid_effort(effort):
    if effort is not None and (not isinstance(effort, str) or not re.fullmatch(EFFORT_RE, effort)):
        raise ValueError("active session has an invalid reasoning effort")
    return effort or None


def format_trailer(prefix, model, effort, email):
    """Build the shared trailer format: '[Tool ]Model (effort) <email>'; effort is optional."""
    name = f"{prefix} {model}" if prefix else model
    if effort:
        name += f" ({effort})"
    return f"Co-Authored-By: {name} <{email}>"


def gpt_display_name(model):
    """Turn 'gpt-6.1-sol' into 'GPT-6.1 Sol', matching Copilot's 'GPT-6 Luna' style."""
    if not model.startswith("gpt-"):
        return model
    version, *rest = model[4:].split("-")
    return " ".join([f"GPT-{version}", *(part.capitalize() for part in rest)])


# ---------------------------------------------------------------- Codex

def codex_context(sessions_dir, thread_id):
    """Return the latest turn context after verifying the session identity."""
    if not thread_id or not re.fullmatch(ID_RE, thread_id):
        raise ValueError("missing or invalid active Codex thread ID")
    matches = list(sessions_dir.rglob(f"*-{thread_id}.jsonl"))
    if len(matches) != 1:
        raise ValueError("expected exactly one session file for the active Codex thread")

    session_id = None
    context = None
    with matches[0].open(encoding="utf-8") as stream:
        for line in stream:
            if not line.strip():
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                raise ValueError("active Codex session contains an incomplete or invalid record") from None
            if not isinstance(record, dict):
                continue
            payload = record.get("payload")
            if record.get("type") == "session_meta" and isinstance(payload, dict):
                session_id = payload.get("id")
            elif record.get("type") == "turn_context":
                context = payload
    if session_id != thread_id:
        raise ValueError("session metadata does not match the active Codex thread")
    if not isinstance(context, dict):
        raise ValueError("active Codex session has no readable turn context")
    return context


def codex_trailer(context):
    """Return (trailer, effort_known) without inferring missing model details."""
    mode = context.get("collaboration_mode")
    settings = mode.get("settings") if isinstance(mode, dict) else None
    if not isinstance(settings, dict):
        settings = {}
    model = context.get("model") or settings.get("model")
    if not isinstance(model, str) or not re.fullmatch(MODEL_RE, model):
        raise ValueError("latest Codex turn has no valid model identifier")
    effort = valid_effort(
        context.get("effort")
        or context.get("reasoning_effort")
        or context.get("model_reasoning_effort")
        or settings.get("reasoning_effort")
    )
    return format_trailer("Codex", gpt_display_name(model), effort, "noreply@openai.com"), bool(effort)


# ---------------------------------------------------------------- Claude Code

def claude_model(projects_dir, session_id):
    """Return the model of the latest main-thread assistant turn in the active session."""
    if not session_id or not re.fullmatch(ID_RE, session_id):
        raise ValueError("missing or invalid active Claude Code session ID")
    matches = list(projects_dir.glob(f"*/{session_id}.jsonl"))
    if len(matches) != 1:
        raise ValueError("expected exactly one transcript for the active Claude Code session")

    verified = False
    latest = None
    with matches[0].open(encoding="utf-8") as stream:
        for line in stream:
            if not line.strip():
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError:
                continue  # the active transcript may end with a partially written line
            if not isinstance(record, dict) or record.get("sessionId") != session_id:
                continue
            verified = True
            if record.get("type") != "assistant" or record.get("isSidechain"):
                continue
            message = record.get("message")
            candidate = message.get("model") if isinstance(message, dict) else None
            if candidate == "<synthetic>":
                continue  # placeholder written for interruptions and errors, not a model turn
            latest = candidate
    if not verified:
        raise ValueError("transcript records do not match the active Claude Code session")
    if not isinstance(latest, str) or not re.fullmatch(r"claude-[a-z0-9-]+", latest):
        raise ValueError("latest Claude Code assistant turn has no valid model")
    return latest


def claude_display_name(model):
    """Turn 'claude-opus-5-5' into 'Claude Opus 5.5' (dated snapshot suffixes are dropped)."""
    parts = model.split("-")[1:]
    if parts and re.fullmatch(r"\d{8}", parts[-1]):
        parts = parts[:-1]
    words = [p.capitalize() for p in parts if not p.isdigit()]
    version = ".".join(p for p in parts if p.isdigit())
    if not words:
        raise ValueError(f"cannot derive a display name from model '{model}'")
    return " ".join(["Claude", *words, *([version] if version else [])])


def claude_trailer(model, effort):
    effort = valid_effort(effort)
    return format_trailer(None, claude_display_name(model), effort, "noreply@anthropic.com"), bool(effort)


# ---------------------------------------------------------------- Copilot CLI

def copilot_identity(state_dir, session_id):
    """Return the latest root-agent model and effort from the active CLI session."""
    if not session_id or not re.fullmatch(ID_RE, session_id):
        raise ValueError("missing or invalid active Copilot CLI session ID")

    events_file = state_dir / "session-state" / session_id / "events.jsonl"
    if not events_file.is_file():
        raise ValueError("active Copilot CLI session event log is unavailable")

    session_verified = False
    identity = None
    with events_file.open(encoding="utf-8") as stream:
        for line in stream:
            if not line.strip():
                continue
            try:
                event = json.loads(line)
            except json.JSONDecodeError:
                raise ValueError("active Copilot session contains an incomplete or invalid event") from None
            if not isinstance(event, dict):
                continue

            data = event.get("data")
            if not isinstance(data, dict):
                continue

            if event.get("type") == "session.start":
                if data.get("sessionId") != session_id:
                    raise ValueError("session metadata does not match the active Copilot CLI session")
                producer = data.get("producer")
                if not isinstance(producer, str) or "copilot" not in producer.lower():
                    raise ValueError("active session is not identified as a Copilot CLI session")
                session_verified = True
                continue

            if event.get("type") not in ("assistant.usage", "session.usage_record"):
                continue
            if not session_verified or event.get("agentId"):
                continue

            usage = data.get("usage", data)
            if not isinstance(usage, dict):
                identity = None
                continue
            interaction_type = usage.get("interactionType")
            if interaction_type and interaction_type != "conversation-agent":
                continue

            identity = None
            model = usage.get("model")
            if isinstance(model, str) and re.fullmatch(MODEL_RE, model):
                identity = (model, usage.get("modelDisplayName"), usage.get("reasoningEffort"))

    if not session_verified:
        raise ValueError("active Copilot session has no matching session-start event")
    if identity is None:
        raise ValueError("active Copilot session has no root-agent model usage record")

    model, display_name, effort = identity
    if not isinstance(display_name, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9 ._:+/-]*", display_name):
        display_name = gpt_display_name(model)
    effort = valid_effort(effort)
    return format_trailer("Copilot", display_name, effort, COPILOT_EMAIL), bool(effort)


# ---------------------------------------------------------------- CLI

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tool", choices=("codex", "claude", "copilot"), help="force the tool instead of detecting it")
    parser.add_argument(
        "--sessions-dir",
        type=Path,
        default=Path(os.environ.get("CODEX_HOME") or Path.home() / ".codex") / "sessions",
        help="Codex session storage (defaults to CODEX_HOME/sessions or ~/.codex/sessions)",
    )
    parser.add_argument(
        "--thread-id",
        default=os.environ.get("CODEX_THREAD_ID") or os.environ.get("CODEX_SESSION_ID"),
        help="Codex thread to inspect (defaults to the active Codex thread)",
    )
    parser.add_argument(
        "--projects-dir",
        type=Path,
        default=Path(os.environ.get("CLAUDE_CONFIG_DIR") or Path.home() / ".claude") / "projects",
        help="Claude Code transcript storage (defaults to ~/.claude/projects)",
    )
    parser.add_argument(
        "--session-id",
        default=os.environ.get("CLAUDE_CODE_SESSION_ID"),
        help="Claude Code session to inspect (defaults to the active session)",
    )
    parser.add_argument(
        "--effort",
        default=os.environ.get("CLAUDE_EFFORT"),
        help="Claude Code effort (defaults to CLAUDE_EFFORT)",
    )
    parser.add_argument(
        "--copilot-state-dir",
        type=Path,
        default=Path(os.environ.get("COPILOT_HOME") or Path.home() / ".copilot"),
        help="Copilot CLI state directory (defaults to COPILOT_HOME or ~/.copilot)",
    )
    parser.add_argument(
        "--copilot-session-id",
        default=os.environ.get("COPILOT_AGENT_SESSION_ID"),
        help="Copilot CLI session to inspect (defaults to the active session)",
    )
    args = parser.parse_args()
    try:
        tool = args.tool or detect_tool()
        if tool == "codex":
            trailer, effort_known = codex_trailer(codex_context(args.sessions_dir, args.thread_id))
        elif tool == "claude":
            trailer, effort_known = claude_trailer(claude_model(args.projects_dir, args.session_id), args.effort)
        else:
            trailer, effort_known = copilot_identity(args.copilot_state_dir, args.copilot_session_id)
    except (OSError, UnicodeError, ValueError) as error:
        print(f"commit_trailer: {error}", file=sys.stderr)
        return 1
    if not effort_known:
        print("commit_trailer: reasoning effort unavailable; using the model alone", file=sys.stderr)
    print(trailer)
    return 0


if __name__ == "__main__":
    sys.exit(main())
