#!/usr/bin/env bash

# Git Tools - Consolidated Git Scripts
# Location: ~/shell-scripts/git/git-tools.sh
# Usage: Source this file or call individual functions

# Only set strict mode when running as script, not when sourcing
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    set -euo pipefail
fi

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

get_main_branch() {
    if git show-ref --quiet refs/heads/main; then
        echo "main"
    else
        echo "master"
    fi
}

# ============================================================================
# BRANCH TOOLS
# ============================================================================

branch_list() {
    git for-each-ref --sort=-committerdate refs/heads --format='%(HEAD) %(refname:strip=2) | %(committerdate:relative) | %(authorname)' \
    | column -ts'|' \
    | sed 's/^ /./'
}

branch_select() {
    branch_list | fzf | awk '{print $2}'
}

branch_list_all() {
    for branch in $(git branch -r --merged | grep -v HEAD); do 
        echo "$(git show --format="%ci ; %cr ; %an ;" "$branch" | head -n 1) $branch"
    done | sort -r | column -ts';'
}

branch_clean_interactive() {
    local curr_hash branch hash reply
    curr_hash=$(git show -s | head -1 | cut -d ' ' -f2)
    
    for branch in $(find .git/refs -type f | fzf --ansi -m --preview="cat {} | xargs git l"); do
        hash=$(cat "$branch")
        if [[ "$hash" == "$curr_hash" ]]; then
            continue
        fi
        
        git ll | grep -E "$hash" -C 1
        echo -n "Delete $branch? [y|n] "
        read -r reply
        reply=${reply:-"n"}
        
        if [[ "$reply" == "y" ]]; then
            rm "$branch"
            printf '\033[32m%s \033[0mhas been\033[31m deleted\033[0m.\n' "$branch"
        fi
    done
}

branch_delete_squash_merged() {
    HUSKY=0 git branch --merged | grep -Ev '^(\*|\s+master$|\s+main$|\s+develop$)' | xargs -r git branch -d
}

branch_delete_squash_merged_by_target() {
    local target_branch
    target_branch=$(branch_select)
    
    if [[ -z "$target_branch" ]]; then
        echo "No branch selected"
        exit 1
    fi
    
    HUSKY=0 git checkout -q "$target_branch"
    
    git for-each-ref refs/heads/ '--format=%(refname:short)' | while IFS= read -r branch; do
        if [[ "$branch" == "$target_branch" ]]; then
            continue
        fi
        
        local mergeBase cherry_result
        mergeBase=$(git merge-base "$target_branch" "$branch")
        cherry_result=$(git cherry "$target_branch" "$(git commit-tree "$(git rev-parse "$branch^{tree}")" -p "$mergeBase" -m _)")
        
        if [[ "$cherry_result" == "-"* ]]; then
            echo "Deleting squash-merged branch: $branch"
            git branch -D "$branch"
        fi
    done
}

git_branch_tools() {
    local cmd="${1:-}"
    
    case "$cmd" in
        "help")
            echo 'git bb           : Select and checkout branch'
            echo 'git bb pb        : Pull selected branch (checkout + pull)'
            echo 'git bb c, clean  : Clean all merged branches'
            echo 'git bb d, D      : Delete selected local branches(D: force)'
            echo 'git bb rd, rD    : Delete selected local/remote branches(D: force)'
            echo 'git bb l, list   : List branches excluding the current branch'
            echo 'git bb la        : List all branches including remote'
            echo 'git bb m, merged : List merged branches excluding the current and master branches'
            echo 'git bb s, select : Select a branch'
            echo 'git bb rsh, reset: Reset --hard to selected branch'
            echo 'git bb rsm       : Reset --mixed to selected branch'
            echo 'git bb rss       : Reset --soft to selected branch'
            ;;
        "")
            # Default: select and checkout branch (same as *)
            local selected_branch
            selected_branch=$(branch_select)
            if [[ -n "$selected_branch" ]]; then
                git checkout "$selected_branch"
            fi
            ;;
        "select"|"s")
            branch_select
            ;;
        "list"|"l")
            branch_list
            ;;
        "list-all"|"la")
            branch_list_all
            ;;
        "pb")
            local selected_branch
            selected_branch=$(branch_select)
            if [[ -n "$selected_branch" ]]; then
                git checkout "$selected_branch" && git pull origin "$selected_branch"
            fi
            ;;
        "d"|"D")
            local selected_branches
            selected_branches=$(branch_list | fzf -m | awk '{print $2}')
            if [[ -n "$selected_branches" ]]; then
                echo "$selected_branches" | xargs git branch -"$cmd"
            fi
            ;;
        "rd"|"rD")
            local selected_branches
            selected_branches=$(branch_list | fzf -m | awk '{print $2}')
            if [[ -n "$selected_branches" ]]; then
                while IFS= read -r branch; do
                    git push origin --delete "$branch"
                done <<< "$selected_branches"
            fi
            ;;
        "clean"|"c")
            branch_clean_interactive
            ;;
        "merged"|"m")
            git branch --merged | grep -Ev '^(\*|\s+master$|\s+main$|\s+develop$)'
            ;;
        "rsh"|"reset")
            local selected_branch
            selected_branch=$(branch_select)
            if [[ -n "$selected_branch" ]]; then
                git reset "$selected_branch" --hard
            fi
            ;;
        "rsm")
            local selected_branch
            selected_branch=$(branch_select)
            if [[ -n "$selected_branch" ]]; then
                git reset "$selected_branch" --mixed
            fi
            ;;
        "rss")
            local selected_branch
            selected_branch=$(branch_select)
            if [[ -n "$selected_branch" ]]; then
                git reset "$selected_branch" --soft
            fi
            ;;
        *)
            local selected_branch
            selected_branch=$(branch_select)
            if [[ -n "$selected_branch" ]]; then
                git checkout "$selected_branch"
            fi
            ;;
    esac
}

# ============================================================================
# COMMIT TOOLS
# ============================================================================

commit_select() {
    git l \
    | fzf -m --ansi --layout=reverse \
    | sed 's/^[*| ]*//g' | cut -d' ' -f1
}

# ============================================================================
# DIFF AND STAGING TOOLS
# ============================================================================

diff_info() {
    local fileA fileB
    fileA="/tmp/git-s-$(uuidgen)"
    fileB="/tmp/git-diff-$(uuidgen)"
    
    git s | awk '{print $2,$1}' > "$fileA"
    git diff --numstat | awk '{print $3,$1,$2}' > "$fileB"
    
    join -t' ' -a 1 "$fileA" "$fileB" | awk '{print $2, "(+"$3 ",-"$4")", $1}' | sed 's/(+,-)/./; s/^\\([^?]\\) *\\./\\1 STAGED/' | column -t -s' '
    
    rm -f "$fileA" "$fileB"
}

diff_select() {
    diff_info \
    | grep -Ev '[^?] *STAGED ' \
    | fzf -m --header "$(git diff --shortstat)" --preview \
        "if [[ {1} == '??' ]]; then bat {3} 2>/dev/null || cat {3}; else git diff --color=always {3}; fi" \
    | awk '{print $3}'
}

diff_unselect() {
    diff_info \
    | grep -E '[^?] *STAGED ' \
    | fzf -m --header "$(git diff --shortstat)" --preview \
        "if [[ {1} == '??' ]]; then bat {3} 2>/dev/null || cat {3}; else git diff --color=always --cached {3}; fi" \
    | awk '{print $3}'
}

git_diff_tools() {
    local cmd="${1:-info}"
    
    case "$cmd" in
        "info")
            diff_info
            ;;
        "select")
            diff_select
            ;;
        "unselect")
            diff_unselect
            ;;
        *)
            echo "Usage: git_diff_tools [info|select|unselect]"
            exit 1
            ;;
    esac
}

# ============================================================================
# STASH TOOLS
# ============================================================================

stash_list() {
    git stash list --pretty=format:"%C(red)%gd%C(reset) %C(green)(%cr) %C(reset)%s"
}

stash_select() {
    local multi_flag="${1:-}"
    stash_list \
    | fzf --ansi $multi_flag --preview "git stash show -p {1} --color=always" \
    | cut -d' ' -f1
}

git_stash_tools() {
    local cmd="${1:-list}"
    
    case "$cmd" in
        "list"|"l")
            stash_list
            ;;
        "select"|"s")
            stash_select "${2:-}"
            ;;
        "apply"|"a")
            local selected
            selected=$(stash_select)
            if [[ -n "$selected" ]]; then
                git stash apply "$selected"
            fi
            ;;
        "pop"|"p")
            local selected
            selected=$(stash_select)
            if [[ -n "$selected" ]]; then
                git stash pop "$selected"
            fi
            ;;
        "drop"|"d")
            local selected_items
            selected_items=$(stash_select "-m")
            if [[ -n "$selected_items" ]]; then
                while IFS= read -r sid; do
                    git stash drop "$sid"
                done <<< "$selected_items"
            fi
            ;;
        "save")
            diff_info
            echo -n "save message: "
            read -r msg
            git stash save "$msg"
            ;;
        *)
            echo "Usage: git_stash_tools [list|select|apply|pop|drop|save]"
            exit 1
            ;;
    esac
}

# ============================================================================
# SYNC AND UPDATE TOOLS
# ============================================================================

select_remote() {
    {
        git remote -v | grep -E '^(origin|upstream)\s'
        git remote -v | grep -vE '^(origin|upstream)\s' | sort
    } \
    | awk '{print $1, $2}' | uniq \
    | column -t \
    | fzf | awk '{print $1}'
}

git_sync() {
    local remote
    remote=$(select_remote)
    
    if [[ -n "$remote" ]]; then
        local current_branch
        current_branch=$(git branch --show-current)
        git fetch "$remote" && git reset --hard "$remote/$current_branch"
    fi
}

git_update() {
    local remote
    remote=$(select_remote)
    
    if [[ -n "$remote" ]]; then
        local current_branch
        current_branch=$(git branch --show-current)
        git stash
        git pull --rebase "$remote" "$current_branch"
        git stash pop
    fi
}

# ============================================================================
# FORCE PUSH TOOLS
# ============================================================================

git_force_push_selected() {
    local current_branch selected_branches confirm
    local failed_branches='' success_count=0 total_count=0
    
    current_branch=$(git branch --show-current)
    echo "Current branch: $current_branch"
    echo ""
    echo "Select branches to force push (multiple selection with TAB):"
    
    selected_branches=$(git branch | grep -v "main" | sed 's/^[ *]*//; /^$/d' | \
        fzf --multi --prompt="Select branches to force push: " --height=15)
    
    if [[ -z "$selected_branches" ]]; then
        echo "No branches selected. Exiting."
        exit 1
    fi
    
    echo "Selected branches:"
    printf '%s\n' "$selected_branches"
    echo ""
    
    echo -n "Force push these branches? (y/N): "
    read -r confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Cancelled."
        exit 1
    fi
    
    while IFS= read -r branch; do
        branch=$(printf '%s' "$branch" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        
        if [[ -n "$branch" ]]; then
            ((total_count++))
            printf 'Force pushing branch: %s\n' "$branch"
            
            if git push --force-with-lease --no-verify origin "$branch"; then
                printf '✅ Successfully pushed: %s\n' "$branch"
                ((success_count++))
            else
                printf '❌ Failed to push: %s\n' "$branch"
                if [[ -z "$failed_branches" ]]; then
                    failed_branches="$branch"
                else
                    failed_branches="$failed_branches"$'\n'"$branch"
                fi
            fi
        fi
    done <<< "$selected_branches"
    
    echo ""
    printf 'Summary: %d/%d branches pushed successfully\n' "$success_count" "$total_count"
    
    if [[ -n "$failed_branches" ]]; then
        echo "Failed branches:"
        printf '%s\n' "$failed_branches"
        exit 1
    fi
}

# ============================================================================
# REPLAY TOOLS
# ============================================================================

git_replay_onto() {
    echo "Select target branch:"
    local target_branch
    target_branch=$(branch_select)
    
    if [[ -z "$target_branch" ]]; then
        echo "No target branch selected"
        exit 1
    fi
    
    echo "Select start commit (will be included):"
    local start_commit
    start_commit=$(commit_select)
    
    if [[ -z "$start_commit" ]]; then
        echo "No start commit selected"
        exit 1
    fi
    
    local end_commit
    end_commit=$(git rev-parse HEAD)
    
    echo "Target: $target_branch, Range: $start_commit^..$end_commit (current HEAD)"
    echo "Applying changes..."
    
    git replay --contained --onto "$target_branch" "$start_commit^..$end_commit" | git update-ref --stdin
}

git_replay_onto_main() {
    echo "Select start commit (will be included):"
    local start_commit
    start_commit=$(commit_select)
    
    if [[ -z "$start_commit" ]]; then
        echo "No start commit selected"
        exit 1
    fi
    
    local end_commit main_branch
    end_commit=$(git rev-parse HEAD)
    main_branch=$(get_main_branch)
    
    echo "Target: $main_branch, Range: $start_commit^..$end_commit (current HEAD)"
    echo "Applying changes..."
    
    git replay --contained --onto "$main_branch" "$start_commit^..$end_commit" | git update-ref --stdin
}

# ============================================================================
# TAG TOOLS
# ============================================================================

git_tag_refresh() {
    local height tag_name
    height=$(stty size | awk '{print $1}')
    
    tag_name=$(git tag | fzf --preview "git l {1} | head -n $height")
    
    if [[ -n "$tag_name" ]]; then
        echo "$tag_name"
        git tag -d "$tag_name"
        git tag "$tag_name"
    fi
}

# ============================================================================
# DEPENDENCY CHECKER
# ============================================================================

check_tool() {
    local tool="$1"
    local name="$2"
    local url="$3"
    local install_cmd="$4"
    
    if ! command -v "$tool" &> /dev/null; then
        echo "Not found : $name($tool)"
        echo "    see     : $url"
        echo "    install : $install_cmd"
        echo ""
        return 1
    else
        echo "✅ $name($tool) is installed"
        return 0
    fi
}

git_alias_doctor() {
    echo "Checking Git alias dependencies..."
    echo ""
    
    local all_good=true
    
    if ! check_tool "fzf" "fzf" "https://github.com/junegunn/fzf#installation" "brew install fzf"; then
        all_good=false
    fi
    
    if ! check_tool "bat" "bat" "https://github.com/sharkdp/bat" "brew install bat"; then
        all_good=false
    fi
    
    if ! command -v "pygmentize" &> /dev/null; then
        echo "⚠️  Optional: Pygments(pygmentize) not found"
        echo "    see     : http://pygments.org/"
        echo "    install : pip3 install Pygments"
        echo ""
    else
        echo "✅ Pygments(pygmentize) is installed"
    fi
    
    if $all_good; then
        echo "🎉 All required dependencies are installed!"
    else
        echo "❌ Some required dependencies are missing. Please install them."
        exit 1
    fi
}

# ============================================================================
# ALIAS SELECTION FUNCTION
# ============================================================================

git_alias_select() {
    local selected_line selected_alias selected_command
    
    # Get all git aliases with descriptions and format them for fzf
    selected_line=$(git config --list | egrep '^alias\.' | \
        sed 's/^alias\.//' | \
        awk -F'=' '{
            alias_name = $1
            command = substr($0, index($0, "=") + 1)
            
            # Extract description from comment if exists
            if (match(command, /!#[^;]*;/)) {
                desc = substr(command, RSTART + 2, RLENGTH - 3)
                gsub(/^ */, "", desc)  # Remove leading spaces
                gsub(/ *$/, "", desc)  # Remove trailing spaces
            } else {
                desc = "No description"
            }
            
            printf "%-20s: %s\n", alias_name, desc
        }' | \
        sort | \
        fzf --prompt="Select git alias: " \
            --preview="git config --get alias.{1}" \
            --preview-window=right:40%:wrap \
            --height=25 \
            --border \
            --delimiter=':')
    
    if [[ -n "$selected_line" ]]; then
        selected_alias=$(echo "$selected_line" | awk -F':' '{print $1}' | sed 's/[[:space:]]*$//')
        selected_command=$(git config --get "alias.$selected_alias")
        echo "Running: git $selected_alias"
        echo "Command: $selected_command"
        echo ""
        eval "git $selected_alias"
    else
        echo "No alias selected"
    fi
}

# ============================================================================
# HELP FUNCTION
# ============================================================================

git_tools_help() {
    echo "🛠️  Git Tools - Available Functions:"
    echo ""
    echo "📂 Branch Tools:"
    echo "   git_branch_tools [cmd]     - Branch management (bb command)"
    echo "   branch_select              - Select a branch interactively"
    echo "   branch_list                - List branches"
    echo "   branch_delete_squash_merged - Delete squash merged branches"
    echo ""
    echo "💾 Commit Tools:"
    echo "   commit_select              - Select commits interactively"
    echo ""
    echo "📝 Diff & Staging Tools:"
    echo "   git_diff_tools [cmd]       - File diff and staging tools"
    echo "   diff_select                - Select files to stage"
    echo "   diff_unselect              - Select files to unstage"
    echo ""
    echo "📚 Stash Tools:"
    echo "   git_stash_tools [cmd]      - Stash management"
    echo ""
    echo "🔄 Sync Tools:"
    echo "   git_sync                   - Sync with remote branch"
    echo "   git_update                 - Update with rebase"
    echo ""
    echo "🚀 Advanced Tools:"
    echo "   git_force_push_selected    - Interactive multi-branch force push"
    echo "   git_replay_onto            - Replay commits onto branch"
    echo "   git_replay_onto_main       - Replay commits onto main"
    echo "   git_tag_refresh            - Refresh tags interactively"
    echo ""
    echo "🎯 Alias Tools:"
    echo "   git_alias_select           - Interactive git alias selection"
    echo ""
    echo "🩺 Diagnostics:"
    echo "   git_alias_doctor           - Check dependencies"
    echo ""
    echo "💡 Usage: Source this file in your .zshrc and use functions directly"
}

# ============================================================================
# MAIN ENTRY POINT (if script is executed directly)
# ============================================================================

# Check if script is being executed directly (not sourced)
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]] 2>/dev/null; then
    cmd="${1:-help}"
    case "$cmd" in
        # Branch Tools
        "branch-tools"|"bb") git_branch_tools "${@:2}" ;;
        "branch-select"|"bs") branch_select "${@:2}" ;;
        "branch-list"|"bl") branch_list "${@:2}" ;;
        "branch-clean"|"bc") 
            case "${2:-dsm}" in
                "dsm") branch_delete_squash_merged "${@:3}" ;;
                "dsmb") branch_delete_squash_merged_by_target "${@:3}" ;;
                *) echo "Usage: git-tools branch-clean [dsm|dsmb]"; exit 1 ;;
            esac ;;
        
        # Commit Tools
        "commit-select"|"c-s"|"cs") commit_select "${@:2}" ;;
        
        # Diff & Staging Tools
        "diff-tools"|"dt") git_diff_tools "${@:2}" ;;
        "diff-select"|"ds") diff_select "${@:2}" ;;
        "diff-unselect"|"du") diff_unselect "${@:2}" ;;
        
        # Stash Tools
        "stash-tools"|"st") git_stash_tools "${@:2}" ;;
        
        # Sync Tools
        "sync") git_sync "${@:2}" ;;
        "update") git_update "${@:2}" ;;
        "sync-update"|"su") 
            case "${2:-sync}" in
                "sync") git_sync "${@:3}" ;;
                "update") git_update "${@:3}" ;;
                *) echo "Usage: git-tools sync-update [sync|update]"; exit 1 ;;
            esac ;;
        
        # Advanced Tools
        "force-push-selected"|"pfs") git_force_push_selected "${@:2}" ;;
        "replay-onto"|"ro") git_replay_onto "${@:2}" ;;
        "replay-onto-main"|"rom") git_replay_onto_main "${@:2}" ;;
        "tag-refresh"|"tr") git_tag_refresh "${@:2}" ;;
        
        # Alias Tools
        "alias-select"|"al") git_alias_select "${@:2}" ;;
        
        # Diagnostics
        "alias-doctor"|"doctor") git_alias_doctor "${@:2}" ;;
        
        # Help
        "help"|"--help"|"-h"|*) git_tools_help ;;
    esac
fi
