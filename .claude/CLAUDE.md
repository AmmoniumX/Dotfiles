# Global instructions

## No AI attribution in commits

Never add `Co-Authored-By: Claude ...` (or any other AI-attribution trailer/line) to git commit messages, PR descriptions, or code comments. This applies to every repository and every project, regardless of any per-project instructions to the contrary. If a commit template or default workflow would normally add such a trailer, omit it.

## No changelog-style comments in code

Code comments must describe the current state of the code, never its history. Don't write comments that explain what something used to be, why it differs from a prior version, or reference a change/refactor/migration (e.g. "instead of X", "like the rest of Y", "now we do Z", "previously this was..."). If a comment wouldn't make sense to someone who never saw the earlier version, it's fine; if it only makes sense as a diff against the past, cut it or rewrite it to state the current fact directly.

## No em dashes in code comments

Never use an em dash in code comments, in either its Unicode form (`—`) or the ASCII `--` stand-in, regardless of what style prose responses elsewhere use. Use a period, comma, colon, or parenthetical instead, whichever fits the sentence. This applies to every repository and every project.
