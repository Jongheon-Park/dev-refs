---
name: chat-over-session
description: Send a message to another Claude Code session via shared file.
argument-hint: "[your-name] [chat-topic or 'join']"
---

# /chat-over-session — $ARGUMENTS

Two Claude Code sessions can talk through a shared file.

## Setup
- Chat file: `docs/ai-docs/chat/[topic].md` (created on first use)
- Each session picks a name (e.g., "Planner", "Developer").

## Sending
1. Append your message to the chat file:
   ```markdown
   **[YourName]** (HH:MM)
   [message content]

   ---
   ```
2. Never overwrite — **append only**.

## Receiving
1. Read the chat file.
2. Track what you've already seen (line count).
3. Only process new messages since last read.

## Rules
- Identify yourself in every message.
- One message at a time.
- English only in the chat file.
- Report outcomes to the user after exchange.

## Example flow
```
[Session A] /chat-over-session Planner design-login
        → writes question about login architecture

[Session B] /chat-over-session Developer join design-login
        → reads question, writes response

[Session A] → reads response, continues discussion
```
