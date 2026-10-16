#!/usr/bin/env python3
"""Print a co-author trailer for the model running the active coding-agent session.

Supports Codex, Claude Code, GitHub Copilot CLI, and Google Antigravity CLI (agy).
Reads only the active session; config defaults and Git history are never used.
"""

import argparse
import json
import os
from pathlib import Path
import re
import sqlite3
import sys

ID_RE = r"[A-Za-z0-9_-]+"
EFFORT_RE = r"[A-Za-z0-9][A-Za-z0-9_-]*"
MODEL_RE = r"[A-Za-z0-9][A-Za-z0-9._:-]*"
COPILOT_EMAIL = "223556219+Copilot@users.noreply.github.com"
ANTIGRAVITY_EMAIL = "noreply@antigravity.google"


def detect_tool():
    active = []
    if os.environ.get("CODEX_THREAD_ID") or os.environ.get("CODEX_SESSION_ID"):
        active.append("codex")
    if os.environ.get("CLAUDE_CODE_SESSION_ID"):
        active.append("claude")
    if os.environ.get("COPILOT_AGENT_SESSION_ID"):
        active.append("copilot")
    if os.environ.get("ANTIGRAVITY_CONVERSATION_ID") or os.environ.get("ANTIGRAVITY_AGENT"):
        active.append("antigravity")
    if len(active) > 1:
        raise ValueError("multiple active coding-agent sessions detected; specify --tool")
    if not active:
        raise ValueError("no active Codex, Claude Code, Copilot CLI, or Antigravity session detected")
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


# ---------------------------------------------------------------- Antigravity CLI (agy)

def parse_antigravity_label(label):
    match = re.match(r"^(.*?)(?:\s*\(([^)]+)\))?$", label.strip())
    if not match:
        return label.strip(), None
    model_part, effort_part = match.groups()
    effort = effort_part.lower() if effort_part else None
    return model_part.strip(), effort


def antigravity_agent(app_data_dir, conv_id, explicit_agent=None):
    if explicit_agent and explicit_agent.strip():
        return explicit_agent.strip()
    env_agent = os.environ.get("ANTIGRAVITY_AGENT_NAME") or os.environ.get("AGY_AGENT")
    if env_agent and env_agent.strip():
        return env_agent.strip()
    db_path = app_data_dir / "conversation_summaries.db"
    if db_path.is_file():
        try:
            with sqlite3.connect(f"file:{db_path}?mode=ro", uri=True) as con:
                cur = con.cursor()
                cur.execute("SELECT agent_name FROM conversation_summaries WHERE conversation_id = ?", (conv_id,))
                row = cur.fetchone()
                if row and row[0] and row[0].strip():
                    return row[0].strip()
        except sqlite3.Error:
            pass  # unreadable or locked summary database: fall back to the default agent name
    return None


# Conversation IDs in CLI logs; other UUIDs on the same line (e.g. trajectory_id) are ignored
CONV_ID_RE = re.compile(r"(?:cascade_id:|convID=|conversation )([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})")
OVERRIDE_RE = re.compile(r'model_config_manager\.go:.*\] Propagating selected model override to backend: label="([^"]+)"')


def antigravity_log_label(log_dir, conv_id):
    """Return the latest model label propagated while the active conversation was current.

    A CLI log can mix several conversations and its override lines carry no
    conversation ID, so each override is attributed to the conversation ID
    (cascade_id, convID or "conversation <id>") that appeared most recently before it; overrides of other conversations are ignored.
    """
    logs = sorted(log_dir.glob("cli-*.log"), key=os.path.getmtime, reverse=True)
    for log_path in logs:
        try:
            with log_path.open(encoding="utf-8", errors="replace") as stream:
                current = None
                label = None
                for line in stream:
                    ids = CONV_ID_RE.findall(line)
                    if ids:
                        current = ids[-1]
                    match = OVERRIDE_RE.search(line)
                    if match and current == conv_id:
                        label = match.group(1).strip()
        except OSError:
            continue
        if label:
            return label
    return None


def antigravity_identity(app_data_dir, conv_id, explicit_agent=None, explicit_effort=None):
    """Return (trailer, effort_known) for the active Antigravity CLI session."""
    if not conv_id or not re.fullmatch(ID_RE, conv_id):
        raise ValueError("missing or invalid active Antigravity conversation ID")

    agent = antigravity_agent(app_data_dir, conv_id, explicit_agent)

    # 1. Inspect transcript.jsonl for user setting changes
    transcript_path = app_data_dir / "brain" / conv_id / ".system_generated" / "logs" / "transcript.jsonl"
    latest_label = None
    if transcript_path.is_file():
        with transcript_path.open(encoding="utf-8") as stream:
            for line in stream:
                if not line.strip():
                    continue
                try:
                    record = json.loads(line)
                except json.JSONDecodeError:
                    continue
                if record.get("source") == "USER_EXPLICIT" and record.get("type") == "USER_INPUT":
                    content = record.get("content", "")
                    match = re.search(r"The user changed setting `Model Selection` from .*? to (.+?)\.\s*(?:No need|If reporting|\n|$)", content)
                    if match:
                        latest_label = match.group(1).strip()

    # 2. Fall back to CLI logs, scoped to the active conversation
    if not latest_label:
        latest_label = antigravity_log_label(app_data_dir / "log", conv_id)

    if not latest_label:
        raise ValueError("active Antigravity session has no detectable model in transcript or logs")

    model, effort = parse_antigravity_label(latest_label)
    if effort is None:
        effort = explicit_effort

    if not isinstance(model, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9 ._:+/-]*", model):
        raise ValueError("active Antigravity session has an invalid model identifier")

    effort = valid_effort(effort)

    if agent and agent.lower() not in ("antigravity", "default"):
        prefix = f"Antigravity {agent.capitalize()}" if not agent.lower().startswith("antigravity") else agent
    else:
        prefix = "Antigravity"

    return format_trailer(prefix, model, effort, ANTIGRAVITY_EMAIL), bool(effort)


# ---------------------------------------------------------------- CLI

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--tool",
        choices=("codex", "claude", "copilot", "antigravity", "agy"),
        help="force the tool instead of detecting it",
    )
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
    parser.add_argument(
        "--antigravity-dir",
        type=Path,
        default=Path(os.environ.get("ANTIGRAVITY_APP_DATA_DIR") or Path.home() / ".gemini" / "antigravity-cli"),
        help="Antigravity app data directory (defaults to ANTIGRAVITY_APP_DATA_DIR or ~/.gemini/antigravity-cli)",
    )
    parser.add_argument(
        "--conversation-id",
        default=os.environ.get("ANTIGRAVITY_CONVERSATION_ID"),
        help="Antigravity conversation to inspect (defaults to the active conversation ID)",
    )
    parser.add_argument(
        "--agent",
        default=os.environ.get("ANTIGRAVITY_AGENT_NAME") or os.environ.get("AGY_AGENT"),
        help="Agent override (defaults to ANTIGRAVITY_AGENT_NAME or AGY_AGENT)",
    )
    parser.add_argument(
        "--effort",
        default=None,
        help="reasoning effort when the session does not record it (Claude Code defaults to CLAUDE_EFFORT; "
        "Antigravity to ANTIGRAVITY_EFFORT or AGY_EFFORT, used only if the model label has no effort)",
    )
    args = parser.parse_args()
    try:
        tool = args.tool or detect_tool()
        if tool == "agy":
            tool = "antigravity"
        if tool == "codex":
            trailer, effort_known = codex_trailer(codex_context(args.sessions_dir, args.thread_id))
        elif tool == "claude":
            trailer, effort_known = claude_trailer(claude_model(args.projects_dir, args.session_id), args.effort or os.environ.get("CLAUDE_EFFORT"))
        elif tool == "copilot":
            trailer, effort_known = copilot_identity(args.copilot_state_dir, args.copilot_session_id)
        else:
            trailer, effort_known = antigravity_identity(
                args.antigravity_dir,
                args.conversation_id,
                explicit_agent=args.agent,
                explicit_effort=args.effort or os.environ.get("ANTIGRAVITY_EFFORT") or os.environ.get("AGY_EFFORT"),
            )
    except (OSError, UnicodeError, ValueError) as error:
        print(f"commit_trailer: {error}", file=sys.stderr)
        return 1
    if not effort_known:
        print("commit_trailer: reasoning effort unavailable; using the model alone", file=sys.stderr)
    print(trailer)
    return 0


if __name__ == "__main__":
    sys.exit(main())
