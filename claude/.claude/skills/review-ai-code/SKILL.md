---
name: review-ai-code
description: Always use this skill after you write or modify code to check for mistakes, bugs, and improvements. This skill is mandatory before reporting back to the user after completing a coding task or writing a logical chunk of code.
---

## Instructions
Assume the role of a code auditor. Your task is to review recently modified code to confirm that it follows project conventions, standards, and style guidelines.
You are like a "smart" linter or static analysis tool in that you are thorough, exhaustive, and ruthless in your checks. Nothing can get past you.
Only refine code that has been recently modified or touched in the current session

Things to check for:
- Dead code elimination - If the current changeset results in code that is no longer used or reachable, it should be removed. This includes exports that are no longer referenced, functions that are never called, and any code that has become obsolete due to the recent changes.
- Unnecessary changes - Sometimes, it can take several attempts to fix some issue, type/lint error, or test failure. It is important to ensure that any modifications that were a result of this trial and error process are cleaned up and removed if they are not necessary for the final implementation.
- Organization - Is the affected code organized and structured in a way that follows the project's existing structure and patterns? Consider factors such as where the code is located within the project, and boundaries between different modules, components, functions, and layers of abstraction.
- CLAUDE.md and rules - Does the code adhere to the guidelines and rules outlined in the project's CLAUDE.md file and/or rules files?
- Code duplication - Do the changes implement functionality that already exists elsewhere in the codebase? If so, consider extracting the common functionality into a shared utility function or module to avoid duplication and promote code reuse. However, consider the trade-offs of abstraction and code reuse. There is value in code that is self-contained and easy to understand without having to navigate through multiple layers of abstraction.
- Abstraction - Conversely to code duplication, consider whether this changeset introduces abstractions that are unnecessary or overly complex.
- Silent failures - Prefer explicit error handling and logging over silent failures. Fallback values and default behaviors should only be used when they are valid states. If some value is expected to be present but is missing, it is better to throw an error or log a warning rather than silently proceeding and hiding the issue.
- Accurate naming - Are variable, function, and component names descriptive and consistent with the project's naming conventions? Avoid single-letter variable names, even in the case of loop counters or temporary variables. Remember that abbreviations can unintentionally change the meaning of a term, so be cautious when using them.

Steps to follow:
1. Identify the recently modified code sections
2. Analyze this code against the checklist above, and create a list of identified issues. The priority of this step is exhaustiveness and thoroughness, not making decisions about which issues are worth addressing or not. Do not make judgments about the severity of the issues, the effort required to address them, or the rationale behind the original implementation. The goal is to build a comprehensive list of issues, then later review the list and make decisions about which ones to address.
3. Review the list of identified issues and improvements. If you are uncertain about any of them, or if the trade-offs are significant or could go either way, present the issue and the trade-offs to the user for a decision.
4. Once you have a final list of issues to address, proceed to make the necessary changes to the code. After making the changes, repeat this review process to ensure that the new changes are also thoroughly reviewed and that no new issues have been introduced.
