# sh-kit

개발 워크플로우를 향상시키는 인터랙티브 shell script toolkit입니다.

[English README](README.md)

## 📁 프로젝트 구조

```
~/sh-kit/
├── README.md                    # 영어 문서 (프로젝트 개요)
├── README.kr.md                 # 이 파일 (한국어 문서)
├── CLAUDE.md                    # 프로젝트 전체 Claude Code 가이드
├── .gitignore                   # Git 무시 파일 설정
├── .zshrc.tmpl                  # ZSH 설정 템플릿
├── .gitconfig.tmpl              # Git 설정 템플릿
├── bin/                         # 실행 가능한 명령어들 (PATH에 추가)
│   └── gt -> ../git/git-tools.sh    # Git 도구 심볼릭 링크
└── git/                         # Git 워크플로우 도구
    ├── README.md               # Git 도구 상세 문서
    ├── CLAUDE.md               # Git 도구 Claude Code 가이드
    └── git-tools.sh            # Git 도구 구현 스크립트
```

## 🚀 빠른 시작

```bash
# 1. 레포지토리 클론
git clone <repository-url> sh-kit
cd sh-kit

# 2. 설정 파일 확인
cat .zshrc.tmpl      # ZSH 설정 템플릿 확인
cat .gitconfig.tmpl  # Git 설정 템플릿 확인

# 3. ZSH 설정 (.zshrc.tmpl 참조)
export SH_KIT_HOME="$(pwd)"
export PATH="$SH_KIT_HOME/bin:$PATH"

# 또는 ~/.zshrc에 추가:
echo "export SH_KIT_HOME=\"$(pwd)\"" >> ~/.zshrc
echo "export PATH=\"\$SH_KIT_HOME/bin:\$PATH\"" >> ~/.zshrc
source ~/.zshrc

# 4. Git alias 설정 (.gitconfig.tmpl 참조)
git config --global alias.bb "!gt branch-tools"
git config --global alias.c-s "!gt commit-select"
git config --global alias.pfc "!gt force-push-chain"
git config --global alias.al "!gt alias-select"

# 5. 실행 권한 확인 (필요시)
chmod +x git/git-tools.sh

# 6. 설치 확인
gt doctor

# 7. 사용 시작
gt help              # 도구 목록
gt bb                # 브랜치 도구
git bb               # Git alias로 사용
git al               # alias 선택기
```

## 📦 도구 카테고리

### 🛠️ Git Tools (`gt` 명령어)
- **브랜치 관리**: 인터랙티브 브랜치 선택/삭제/정리
- **커밋 도구**: 커밋 선택 및 조작
- **스테이징**: 파일 diff 및 스테이징 도구
- **Stash 관리**: stash 목록 및 조작
- **동기화**: 원격 저장소와 동기화
- **고급 기능**: Force push, replay, tag 관리

📖 **상세 문서**: [`git/README.md`](git/README.md)

### 🔮 미래 확장 계획
- **Docker Tools** (`dt`): 컨테이너 관리
- **Kubernetes Tools** (`kt`): K8s 리소스 관리  
- **AWS Tools** (`at`): 클라우드 리소스 관리
- **Database Tools** (`dbt`): 데이터베이스 작업

## 🏗️ 아키텍처

### 확장 가능한 구조
각 도구 카테고리는 독립적인 디렉토리와 심볼릭 링크로 구성:
- **카테고리 디렉토리**: 각 도구의 구현과 문서
- **bin/ 디렉토리**: PATH에서 접근 가능한 실행 명령어들
- **심볼릭 링크**: 단일 파일 관리와 PATH 접근의 장점 결합

### 새 카테고리 추가 방법
```bash
# 1. 새 카테고리 디렉토리 생성 (예: docker)
mkdir docker
# 2. 메인 스크립트 작성 (docker/docker-tools.sh)
# 3. 심볼릭 링크 생성
ln -s ../docker/docker-tools.sh bin/dt
```

## 📋 공통 의존성

- **필수**: `fzf` (인터랙티브 선택), 표준 Unix 도구들
- **선택**: `bat` (파일 미리보기), `pygmentize` (구문 강조)

## 📚 문서

- **영어 문서**: [README.md](README.md)
- **한국어 문서**: [README.kr.md](README.kr.md) (이 파일)
- **전체 개발 가이드**: [CLAUDE.md](CLAUDE.md) (프로젝트 아키텍처 및 확장 가이드)
- **카테고리별 사용자 가이드**: 각 카테고리의 README.md
- **카테고리별 개발 가이드**: 각 카테고리의 CLAUDE.md
- **의존성 확인**: 각 도구의 `doctor` 명령어

## 🤝 기여하기

1. 새로운 도구 카테고리 추가
2. 기존 도구 개선
3. 문서 업데이트
4. 버그 리포트

---

⭐ **Tip**: 각 도구는 `help` 명령어로 사용법을 확인할 수 있습니다 (`gt help`, `dt help` 등)