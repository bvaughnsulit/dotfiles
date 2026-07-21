## Priorities

Your priorities are NOT:
- To "just get it working."
- To require minimal human interaction and input.

Your priorities ARE:
- To code that fits within the existing organizational structure and conventions of the codebase. Take extra care to check that your code is located in the right place, that you are using existing functions, classes, modules, and types where appropriate.
- Getting the implementation right the first time, even if it means more planning and questions up front. Utilize the interview feature to ask questions and clarify requirements.

## Communication
- When the user is asking a question or thinking out loud — "is it overkill?", "why not X?", "what if Y?", "what's the proper way?" — answer it. Do NOT touch code until they explicitly ask you to implement/apply/change something. A design question is not a request to refactor; treat "we were just talking" as the default until told otherwise.
- When including filenames in messages, ALWAYS include the full path relative to the project root, e.g. `src/cli/commands.py`, not just `commands.py`.

## Planning & implementation

- Always include tests as part of implementation plans.
- Before writing custom code to workaround a library limitation, read the library's source code or docs for the relevant class/function to check if a built-in solution already exists. Always exhaust built-in options before implementing custom workarounds.

## Testing

- Don't run tests for small incremental changes mid-task — it hurts cycle time. Make the change, report it complete for verification, and let the tests run in aggregate after a batch of changes. For example: "I've made the requested change. Please verify and let me know if you'd like me to run the tests now or wait until we've completed a batch of changes."
- Don't run tests for comment-only or docstring-only changes; there is nothing to verify.
- Keep test setup inline in each test rather than extracting single-use private helpers (`_seed_*`, `_reload_*`, etc.). Prefer a little repetition across test methods over indirection — a reader should see what a test does without jumping to a helper.

## Code & comments

- When abbreviating or shortening a name, make sure that shortening the name does not change its meaning.
- Don't introduce unnecessary abbreviations or short aliases. Optimize for readability, and prefer the full, descriptive name at every use site.
- Don't reach for React `useCallback`/`useMemo` by default. Wrapping in `useCallback` only pays off when a function's identity must stay stable: it's a dependency of another hook (`useEffect`/`useMemo`/another `useCallback`), it's passed to a `React.memo` child, or it's a callback ref. It is NOT justified by "creating the function is expensive" — closure creation is negligible. Otherwise declare plain functions.
- Comments should only be used to explain "why" something is done, not "what" is being done. Be judicious with comments; if you find yourself writing a comment to explain "what" the code is doing, consider whether the code is too complex, or if a comment is really necessary.
- Documentation comments, such as docstrings or JSDoc comments should not contain implementation details, or contain references to external sources that may change.

## Specs

- Write design specs to `.claude/specs/` in the project root, not `docs/superpowers/specs/`.

## Memory & preferences

- Persist durable preferences and conventions in CLAUDE.md — this global file for cross-project agent behavior, the project's `.claude/CLAUDE.md` for stack/repo specifics — not in the auto-memory store. Reserve memory for things that genuinely can't be committed.
- Never write anything to the auto-memory system without asking first. If something seems worth persisting, propose it and wait for approval — and prefer CLAUDE.md over memory.
- After completing a set of requested changes or corrections, proactively ask whether the underlying preference/convention should be added to CLAUDE.md (global for cross-project agent behavior, the project file for stack/repo specifics). Offer it; write only on confirmation.
