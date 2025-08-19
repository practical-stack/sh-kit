# sh-kit Git Tools

체계적으로 정리된 Git 워크플로우 향상 도구 모음입니다.

## 📁 디렉토리 구조

```
~/sh-kit/
├── bin/
│   └── gt -> ../git/git-tools.sh    # 심볼릭 링크로 연결된 실행 명령어
└── git/
    ├── README.md               # 이 파일 (Git 도구 문서)
    └── git-tools.sh            # 통합된 Git 도구 스크립트
```

## 🛠️ Git Tools

### 주요 파일

- **`git/git-tools.sh`**: 모든 Git 도구들이 통합된 단일 스크립트
- **`bin/gt`**: git-tools.sh로의 심볼릭 링크 (PATH에서 직접 실행)

### 사용 가능한 도구들

#### 📂 Branch Tools
- `gt branch-tools` (또는 `gt bb`) - 브랜치 관리
- `gt branch-select` - 브랜치 인터랙티브 선택
- `gt branch-list` - 브랜치 목록
- `gt branch-clean` - 스쿼시 머지된 브랜치 삭제

#### 💾 Commit Tools
- `gt commit-select` (또는 `gt c-s`) - 커밋 인터랙티브 선택

#### 📝 Diff & Staging Tools
- `gt diff-tools` - 파일 diff 및 staging 도구
- `gt diff-select` - 스테이징할 파일 선택
- `gt diff-unselect` - 언스테이징할 파일 선택

#### 📚 Stash Tools
- `gt stash-tools` - stash 관리

#### 🔄 Sync Tools
- `gt sync` - 원격 브랜치와 동기화
- `gt update` - rebase로 업데이트

#### 🚀 Advanced Tools
- `gt force-push-selected` (또는 `gt pfs`) - 인터랙티브 다중 브랜치 force push
- `gt replay-onto` - 브랜치로 커밋 replay
- `gt replay-onto-main` - 메인으로 커밋 replay
- `gt tag-refresh` - 인터랙티브 태그 갱신

#### 🩺 Diagnostics
- `gt doctor` - 의존성 체크

## 🚀 사용법

### 1. 설치

```bash
# 1. 레포지토리 클론 (원하는 위치에)
git clone <repository-url> <your-preferred-path>
cd <your-preferred-path>

# 2. 심볼릭 링크 생성 (아직 없다면)
ln -s ../git/git-tools.sh bin/gt

# 3. .zshrc에 PATH 추가
# 현재 디렉토리 경로를 자동으로 사용하려면:
echo "export SHELL_SCRIPTS_HOME=\"$(pwd)\"" >> ~/.zshrc
echo "export PATH=\"\$SHELL_SCRIPTS_HOME/bin:\$PATH\"" >> ~/.zshrc

# 또는 수동으로 .zshrc 편집:
# export SHELL_SCRIPTS_HOME="/path/to/your/cloned/directory"
# export PATH="$SHELL_SCRIPTS_HOME/bin:$PATH"

# 4. 쉘 재시작 또는 설정 재로드
source ~/.zshrc

# 5. 설치 확인
gt doctor
```

### 클론 위치 예시
```bash
# 홈 디렉토리에 클론
git clone <repository-url> ~/sh-kit

# 개발 도구 디렉토리에 클론  
git clone <repository-url> ~/dev/sh-kit

# 프로젝트 디렉토리에 클론
git clone <repository-url> ~/projects/sh-kit
```

### 2. 직접 실행

```bash
# 도구 목록 확인
gt help

# 명령어 실행
gt bb              # 브랜치 도구
gt c-s             # 커밋 선택
gt doctor          # 의존성 체크
```

### 3. Git Alias 설정

```bash
# .gitconfig에 추가
[alias]
    bb = "!gt branch-tools"
    pfs = "!gt force-push-selected"
    c-s = "!gt commit-select"
    doctor = "!gt alias-doctor"
```

## 📋 의존성

### 필수
- **fzf**: 인터랙티브 선택을 위한 fuzzy finder
- **bat**: 파일 미리보기 (cat 대체 가능)

### 선택사항
- **pygmentize**: 코드 하이라이팅

설치 확인: `gt doctor`

## 🔧 설정

### 환경 변수
- `SHELL_SCRIPTS_HOME`: 스크립트 홈 디렉토리 (클론한 경로에 맞게 설정)

### Git 설정

`.gitconfig`의 alias들:

```ini
[alias]
    bb = "!gt branch-tools"
    pfs = "!gt force-push-selected"
    c-s = "!gt commit-select"
    doctor = "!gt alias-doctor"
```

## 🎯 장점

1. **단일 파일 관리**: 모든 Git 도구가 하나의 파일에 통합
2. **다양한 사용 방식**: 직접 실행, Git alias 모두 지원
3. **간단한 구조**: 복잡한 래퍼 없이 깔끔한 구조
4. **표준 방식**: Unix/Linux 표준 bin 디렉토리 패턴
5. **확장성**: 새로운 도구 추가가 용이한 구조

## 🔗 심볼릭 링크 구조

`bin/gt`는 `git/git-tools.sh`로의 심볼릭 링크입니다:
- 실제 파일: `git/git-tools.sh` (모든 기능 구현)
- 심볼릭 링크: `bin/gt` (PATH에서 접근 가능)
- 장점: 단일 파일 관리, PATH 기반 실행, 확장성

### ⚡ 자동 반영 시스템

심볼릭 링크의 특성상 **`git-tools.sh` 파일을 수정하면 즉시 자동으로 반영됩니다**:

```bash
# git-tools.sh 수정 후
gt help           # 즉시 반영됨 (재시작 불필요)
git bb           # Git alias도 즉시 반영됨

# 확인 방법
gt doctor        # 의존성 및 설정 확인
```

**주의사항:**
- 새로운 함수 추가 시: 스크립트 수정만 하면 됨
- 새로운 명령어 추가 시: 명령어 분기(case 문) 업데이트 필요
- 파일 이동/삭제 시: 심볼릭 링크가 깨질 수 있으므로 주의