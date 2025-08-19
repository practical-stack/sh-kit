## Step 1: Current State Analysis

### Branch Status Check

**Required Checks**:

1. **Check Current Branch Name**

   ```bash
   git branch --show-current
   ```

2. **Analyze Branch Commit History**

   ```bash
   git log --oneline origin/main..HEAD
   ```

3. **Check Modified Files List**

   ```bash
   git diff --name-only origin/main..HEAD
   ```

4. **Check Staged/Unstaged Changes**
   ```bash
   git status --porcelain
   ```

### Commit Message Analysis

**Analysis Purpose**:

- Extract keywords for automatic PR type determination
- Understand changes for Summary section writing
- Understand work intention and background

**Analysis Target**:

```bash
# Collect recent commit messages
git log --pretty=format:"%s" origin/main..HEAD
```

**Keyword Mapping**:

- `feat`, `feature`, `add`, `implement` → **feat** type
- `fix`, `bug`, `hotfix`, `patch` → **fix** type
- `refactor`, `clean`, `improve` → **refactor** type
- `config`, `setup`, `update dependency` → **config** type
- `docs`, `documentation`, `readme` → **docs** type
- `test`, `spec`, `e2e` → **test** type
- `perf`, `optimize`, `performance` → **perf** type

### Change Analysis

**File Change Pattern Analysis**:

```bash
# Statistics of changed files
git diff --stat origin/main..HEAD
```

**Analysis Criteria**:

1. **New Feature (feat)**:

   - New component/page files added
   - New API endpoint addition
   - New feature-related tests added

2. **Bug Fix (fix)**:

   - Small changes in existing files
   - Error handling fixes
   - Hotfix-related changes

3. **Refactoring (refactor)**:

   - Code structure changes
   - File moves/renames
   - Duplicate code removal

4. **Configuration Change (config)**:
   - Configuration files like `package.json`, `tsconfig.json`
   - `.github/workflows/` related files
   - Environment configuration files

### Pre-validation

**Check PR Creation Feasibility**:

1. **Check Commit Existence**:

   ```bash
   git rev-list --count origin/main..HEAD
   ```

   - If 0: "No commits found. Please commit changes and try again."

2. **Remote Branch Synchronization**:

   ```bash
   git fetch origin
   ```

3. **Check Existing PR**:
   ```bash
   gh pr list --head $(git branch --show-current)
   ```
   - If existing PR found: Switch to PR update mode

### Information Collection Complete

**Collected Information Summary**:

- ✅ Current Branch: `feature/user-dashboard-improvements`
- ✅ Commit Count: 5
- ✅ Main Changes: New user dashboard improvements
- ✅ Expected Type: `feat` (new feature)

**Proceed to Next Step**:

- Move to Step 2 (title generation and type determination) based on collected information

---

## Step 2: Title Generation and Type Determination

### Title Format

**Recommended Format**: `{type}: {clear description of what was done}`

**Writing Rules**:

- **Keep it concise**: 50-72 characters maximum
- **Use imperative mood**: "Add user authentication" not "Added user authentication"
- **Be specific**: Describe what the change does, not how it does it
- **Start with type**: feat, fix, docs, refactor, test, config, perf
- **No ending punctuation**: Don't end with period or exclamation mark

**Good Examples**:
- `feat: add user profile dashboard`
- `fix: resolve login redirect loop`
- `docs: update API documentation for v2`
- `refactor: simplify user authentication logic`
- `test: add integration tests for payment flow`
- `config: update ESLint rules for TypeScript`

**Avoid**:
- `[branch-name] feat: stuff` (redundant branch name)
- `feat: added some new features` (vague, past tense)
- `fix: fixed the bug in the thing` (unclear what was fixed)
- `feat: implement user profile dashboard using React hooks and context API` (too detailed)

### Automatic Type Determination Logic

**Based on Commit Messages and Change Analysis**:

1. **feat**: New features, feature improvements, Feature Flag removal

   - Changes that affect users
   - New feature implementation and improvements

2. **fix**: Bug fixes, hotfixes

   - Error resolution and bug fixes

3. **config**: Configuration file changes (replaces `chore`)

   - Changes to package.json, workflows, eslint, etc.
   - Dependency updates, environment configuration

4. **refactor**: Code refactoring, formatting (integrates `style`)

   - Code quality improvements without functional changes
   - **Note**: Use `feat` for policy changes or when regression is not guaranteed

5. **docs**: Documentation changes

   - README, guides, API documentation writing/editing

6. **test**: Test code addition/modification

   - Unit/integration tests, mocking code writing

7. **perf**: Performance improvements
   - Loading speed, memory, bundle size optimization

### User Confirmation Process

- Propose automatically determined type to user
- User can select different type if modification needed
- Request user selection when unclear

---

## Step 3: Template-based Body Writing

### Template File Processing

**Template Selection Priority**:

1. Default template: `.github/pull_request_template.md` (default)
2. Custom template: `.github/PULL_REQUEST_TEMPLATE/[selected-file].md` (when user specifically requests)

**Required Tasks**:

- Must read selected template file to understand structure
- Automatically write each section according to template structure

### Summary Section Writing

**Format**: Problem/Purpose and Solution/Method structure

**Problem/Purpose**:

- Why is this work needed?
- What problem does it solve?
- What value does it provide to users?

**Solution/Method**:

- What specifically was done?
- How was it resolved?
- What are the main changes?

### Optional Sections (Only when requested by user)

**⚠️ Important**: The following sections are not included by default and are only written when the user explicitly requests them in the prompt

**Common Writing Approach**:

- User and LLM determine section content through **prompt-based interaction**
- LLM presents **specific questions** to the user to gather necessary information
- Section content is written **based on user responses**
- Additional questions asked for **further details** when more information is needed

#### Review Points Section

**Writing Condition**: When user requests "add review points" etc.

**Example Questions**:

- "Which parts would you like reviewers to pay special attention to?"
- "Were there any parts you struggled with while writing the code?"
- "Are there any technical choices or implementation approaches that need review?"

**Content to Write**:

- Separately point out parts that require major review
- Explain to reviewers the parts you were concerned about while writing this code

#### Backlog Section

**Writing Condition**: When user requests "include backlog section" etc.

**Example Questions**:

- "Are there any parts you left as TODO in this work?"
- "Are there any HACK parts you implemented without fully understanding?"
- "Are there any parts that need future improvement or refactoring?"

**Content to Write**:

- TODO: Parts left as TODO for context separation
- HACK: Parts created to meet requirements without full understanding

#### LLM Context Section

**Writing Condition**: When user requests "write LLM Context too" etc.

**⚠️ No Auto-generation**: Prohibited because confusion between PR creation LLM and actual work LLM contexts leads to inaccurate results

**Example Questions**:

- "Did you use LLM for any part of this work?"
- "In what situations did you get help from LLM?"
- "What prompts did you use to request from LLM?"
- "What context did you provide to LLM or what Cursor rules did you use?"

**Content to Write**:

- In what situations LLM help was received
- What problems were requested to be solved
- What prompts were used for instructions
- What context was provided
- Specify Cursor rules if used

### Test Section Writing

**Simple Description Format**:

```markdown
## Test

Describe what testing was performed:
```

**LLM Role**:

- Ask user to describe what testing was performed
- Do not provide specific checkboxes or formats
- Allow flexible description of testing approach

**Cases Where Testing Can Be Skipped**:

- When testing is not applicable (documentation changes, configuration changes)
- User should specify reason: "No testing required - documentation only" or "Verified by successful build"

### References Section Writing

**Simplified Format**:

```markdown
## References

- Related Links:
```

**Processing Method**:

- Provide simple "Related Links:" field
- User can add any relevant links (GitHub issues, Slack threads, specs, etc.)
- No predefined categories or multiple fields

### Draft PR Creation

**Command**:

```bash
# Pre-push if branch hasn't been pushed
if ! git ls-remote --exit-code --heads origin $(git branch --show-current) > /dev/null 2>&1; then
    git push -u origin $(git branch --show-current)
fi

gh pr create --draft --title "{type}: {content}" --body-file [template-file]
```

**Reason for Using Draft**:

- Created as draft to prevent automatic review requests
- Author can change status after additional work

**Pre-push Logic**:

- Automatically push only when branch doesn't exist remotely
- Push directly to origin of current repository without selection dialog
- Skip push process for already pushed branches and create PR directly

### Existing PR Update

**When Existing PR Detected**:

```bash
# Extract existing PR number
PR_NUMBER=$(gh pr list --head $(git branch --show-current) --json number --jq '.[0].number')

# Update PR
gh pr edit $PR_NUMBER --body-file [template-file]
```

**Update Targets**:

- PR body (entire content including Summary, Test, References)
- Title kept as existing (only changed when user specifically requests)

**Update Reasons**:

- Synchronize PR content when new commits are added
- Apply to existing PR when template structure changes
- When user explicitly requests "PR update"

### Open PR in Browser

**Auto-execute After PR Creation Complete**:

```bash
gh pr view --web
```

**Execution Conditions**:

- When PR creation is successfully completed
- Automatically open PR page in default browser

**User Notification**:

- Display "✅ PR opened in browser!" message
- Also display PR link for user confirmation

---

## Exception Handling

### Response to Insufficient Information

- **Unclear branch name**: Request confirmation from user
- **No commit history**: Request user to explain changes
- **No related links**: Leave References section minimal
- **No template file**: Use default template

### LLM Work Limitations

- **No speculation**: Prohibited to write content without basis
- **No image processing**: Do not add actual images
- **Optional sections are interaction-based**: Review Points, Backlog, LLM Context are written through prompt interaction only when user requests

---

## Checklist

- [ ] Check branch name and analyze content
- [ ] **Base branch handling**: Extract and validate base branch from user request
- [ ] Read template file and understand structure
- [ ] Auto-determine type and confirm with user
- [ ] Write section-by-section body according to template structure
- [ ] Optional sections (Review Points, Backlog, LLM Context) written through interaction when user requests
- [ ] Create draft PR or update existing PR
  - New: Auto-push with pre-push logic then create PR (include --base option if base branch specified)
  - Existing: Extract PR number and update body with `gh pr edit`
- [ ] Automatically open PR in browser
- [ ] **🧹 Clean up temporary files (required)**: Delete generated temporary files like pr_body.md
