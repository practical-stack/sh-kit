# sh-kit Git 도구

인터랙티브 기능을 갖춘 포괄적인 Git 워크플로우 향상 도구입니다.

[English README](README.md)

## 📁 디렉토리 구조

```
~/sh-kit/
├── bin/
│   └── gt -> ../git/git-tools.sh    # 실행 가능한 명령어로의 심볼릭 링크
└── git/
    ├── README.md               # 영어 문서 (Git 도구 문서)
    ├── README.kr.md            # 이 파일 (한국어 Git 도구 문서)
    ├── CLAUDE.md               # Claude Code 개발 가이드
    └── git-tools.sh            # 통합된 Git 도구 스크립트
```

## 🛠️ Git 도구

### 주요 파일

- **`git/git-tools.sh`**: 모든 Git 도구가 통합된 단일 스크립트
- **`bin/gt`**: git-tools.sh로의 심볼릭 링크 (PATH에서 직접 실행 가능)

### 사용 가능한 도구들

#### 📂 브랜치 도구
- `gt branch-tools` (또는 `gt bb`) - 브랜치 관리
- `gt branch-select` - 인터랙티브 브랜치 선택
- `gt branch-list` - 브랜치 목록
- `gt branch-clean` - 스쿼시 머지된 브랜치 삭제

#### 💾 커밋 도구
- `gt commit-select` (또는 `gt c-s`) - 인터랙티브 커밋 선택

#### 📝 Diff & 스테이징 도구
- `gt diff-tools` - 파일 diff 및 스테이징 도구
- `gt diff-select` - 스테이징할 파일 선택
- `gt diff-unselect` - 언스테이징할 파일 선택

#### 📚 Stash 도구
- `gt stash-tools` - stash 관리

#### 🔄 동기화 도구
- `gt sync` - 원격 브랜치와 동기화
- `gt update` - rebase로 업데이트

#### 🚀 고급 도구
- `gt force-push-selected` (또는 `gt pfs`) - 인터랙티브 다중 브랜치 force push
- `gt replay-onto` - 브랜치로 커밋 replay
- `gt replay-onto-main` - 메인으로 커밋 replay
- `gt tag-refresh` - 인터랙티브 태그 갱신

#### 🩺 진단 도구
- `gt doctor` - 의존성 체크

## 🚀 사용법

### 1. 설치

```bash
# 1. 레포지토리 클론 (원하는 위치에)
git clone <repository-url> sh-kit
cd sh-kit

# 2. 심볼릭 링크 생성 (아직 없다면)
ln -s ../git/git-tools.sh bin/gt

# 3. .zshrc에 PATH 추가
# 현재 디렉토리 경로를 자동으로 사용하려면:
echo "export SH_KIT_HOME=\"$(pwd)\"" >> ~/.zshrc
echo "export PATH=\"\$SH_KIT_HOME/bin:\$PATH\"" >> ~/.zshrc

# 또는 수동으로 .zshrc 편집:
# export SH_KIT_HOME="/path/to/your/cloned/directory"
# export PATH="$SH_KIT_HOME/bin:$PATH"

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
# 사용 가능한 도구 확인
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
    al = "!gt alias-select"
```

## 📋 의존성

### 필수
- **fzf**: 인터랙티브 선택을 위한 fuzzy finder
- **bat**: 파일 미리보기 (사용 불가 시 cat으로 대체)

### 선택사항
- **pygmentize**: 코드 구문 강조

확인: `gt doctor`

## 🔧 설정

### 환경 변수
- `SH_KIT_HOME`: 스크립트 홈 디렉토리 (클론한 경로에 맞게 설정)

### Git 설정

`.gitconfig`의 alias들:

```ini
[alias]
    bb = "!gt branch-tools"
    pfs = "!gt force-push-selected"
    c-s = "!gt commit-select"
    al = "!gt alias-select"
```

## 🎯 장점

1. **단일 파일 관리**: 모든 Git 도구가 하나의 파일에 통합
2. **다양한 사용 패턴**: 직접 실행과 Git alias 모두 지원
3. **깔끔한 구조**: 복잡한 래퍼 없이 간단한 구조
4. **표준 접근법**: Unix/Linux 표준 bin 디렉토리 패턴
5. **확장성**: 새로운 도구 추가가 용이한 구조

## 🔗 심볼릭 링크 구조

`bin/gt`는 `git/git-tools.sh`로의 심볼릭 링크입니다:
- 실제 파일: `git/git-tools.sh` (모든 기능이 구현됨)
- 심볼릭 링크: `bin/gt` (PATH에서 접근 가능)
- 장점: 단일 파일 관리, PATH 기반 실행, 확장성

### ⚡ 자동 반영 시스템

심볼릭 링크의 특성상 **`git-tools.sh` 파일 수정 사항이 즉시 반영됩니다**:

```bash
# git-tools.sh 수정 후
gt help           # 즉시 반영됨 (재시작 불필요)
git bb           # Git alias도 즉시 반영됨

# 확인 방법
gt doctor        # 의존성 및 설정 확인
```

**주의사항:**
- 새로운 함수 추가 시: 스크립트만 수정하면 됨
- 새로운 명령어 추가 시: 명령어 분기(case 문) 업데이트 필요
- 파일 이동/삭제 시: 심볼릭 링크가 깨질 수 있으므로 주의