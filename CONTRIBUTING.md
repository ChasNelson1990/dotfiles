# Contributing

Practical conventions for working in this repo — for human contributors and AI coding agents
alike.

## `docs/` are playbooks, not a journal

Everything under [`docs/`](docs/) is an imperative runbook: a checklist meant to be followed
step-by-step against live system state, written once and reused as-is. They are **not** a
historical record of what this repo has already done, and shouldn't be edited to note "already
done as of commit X" or similar — that turns a reusable playbook into a stale changelog entry
instead of an instruction someone can actually follow again later.

If a runbook's instructions stop applying (e.g. a package it references has since been removed
elsewhere), fix the instructions so they're correct going forward. Don't annotate them with
commit references or "resolved" notes.

Decisions and the reasoning behind them belong in the relevant per-device README instead
([`core/README.md`](core/README.md), [`router/README.md`](router/README.md),
[`terminal/README.md`](terminal/README.md), [`handheld/README.md`](handheld/README.md)) — those
are explicitly the tracked, opinionated record of what was chosen and why. `docs/` is not a
substitute for that.

## Commit and PR titles

`<type>: <emoji> <lowercase description>` — gitmoji-style, e.g. `feat: :sparkles: add homelab
plan content`, `fix: :bug: make clamonacc ignore firefox extensions`. Emoji shortcode or raw
unicode are both fine. Only the title/subject line gets this treatment — commit bodies and PR
descriptions stay normal prose.
