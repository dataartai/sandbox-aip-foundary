# aip-practice — Palantir AIP 실습 워크스페이스

[aip-community-registry](https://github.com/palantir/aip-community-registry)의 프로젝트를 하나씩 실습하는 상위 워크스페이스.
각 실습은 `NN-<프로젝트명>/` 하위 폴더 하나를 차지한다.

## 구조

```
aip-practice\
├── CLAUDE.md                  # 이 문서 — 모든 실습에 공통 적용되는 규칙
├── _shared\
│   ├── .env                   # 엔롤먼트 공통값 (FOUNDRY_HOSTNAME). git 추적 제외
│   └── .env.example
├── 01-osdk-hello-world\       # ✅ Phase 1 완료
└── (이후 실습이 여기 추가됨)
```

## 작업 규칙

1. **`claude`는 개별 실습 폴더에서 띄운다.** 상위 폴더에서 띄우면 다른 실습 파일까지 탐색 범위에 들어와 컨텍스트가 흐려진다. 이 상위 `CLAUDE.md`는 하위 폴더에서도 자동 상속되므로 손해가 없다.
2. **원본 레포를 수정하지 않는다.** `D:\OneDrive\Cursorhome\aip-community-registry`는 palantir 공식 저장소 클론(remote가 palantir)이며 읽기 전용 참고 자료다. 실습 파일은 여기로 복사해서 쓴다.
3. **자격증명은 코드에 넣지 않는다.** 토큰은 각 실습 폴더의 `.env`에만 둔다. 노트북·스크립트는 `os.environ` / `$env:` 로 읽는다. 모든 `.env`는 gitignore 대상.
4. **엔롤먼트 공통값은 `_shared\.env`에 둔다.** 호스트명처럼 실습 간 동일한 값은 여기 한 곳에서 관리하고, 실습별 `.env`가 이를 덮어쓸 수 있다.
5. **각 실습의 `NOTES.md`는 맨 위에 "학습목표" 한 줄을 시작할 때부터 적어둔다.** 형식: `> **학습목표**: 이 실습 = <배우는 것> 하나만 익히는 것.` 계획대로 안 풀려서 우회 경로로 완주하더라도(설치 실패·zip 폐기 등), 이 한 줄이 있으면 "그래서 결국 뭘 배운 거지?"가 안 헷갈린다. 01번은 완주 후에야 이걸 붙였다 — 다음 실습부턴 시작할 때 먼저 적을 것.

## 공통 환경

- **Miniconda**: `C:\Users\besti\miniconda3` (`AddToPath=0`, `conda init powershell` 적용)
  → `conda` 명령은 **새 터미널**에서만 인식된다.
- **conda env 명명 규칙**: `aip-<실습 슬러그>` (예: `aip-osdk-hello`)
  env는 폴더 구조와 무관하게 `C:\Users\besti\miniconda3\envs\`에 전역 저장된다.
- conda 채널 ToS 승인 완료: `pkgs/main`, `pkgs/r`, `pkgs/msys2`

## Foundry 관련 공통 제약

- **마켓플레이스 업로드·패키지 설치·Developer Console 앱 생성·SDK 생성은 에이전트가 수행할 수 없다.** 전부 Foundry 웹 콘솔에서 사용자가 직접 해야 한다.
- Developer Console이 생성한 OSDK는 **Foundry 내장 Jupyter에서 쓸 수 없다.** 로컬 노트북이 전제다.
- SDK 패키지명은 **추측하지 않는다.** Developer Console에서 앱을 만들 때 정해지며, 각 실습의 `NOTES.md`에 기록한다.

## 학습 로드맵

**[ROADMAP.md](./ROADMAP.md)** — 28개 프로젝트 중 무엇을 어떤 순서로 할지, 온톨로지·워크플로우 개념 매핑, AIP 프로젝트 기획 절차. **다음 실습을 고를 때 여기부터 본다.**

## 실습 목록

| # | 실습 | 상태 |
|---|---|---|
| 01 | [OSDK 'Hello World'](./01-osdk-hello-world/) | ✅ 완주 (2026-08-29) |
| 02 | [Expense Reporting](./02-expense-reporting/) | 계획 완료 · Phase 1(마켓플레이스 설치) 대기 |

**다음 추천 경로** (2026-08-30 갱신 — Palantir 지원 준비용 압축 트랙, 상세는 [ROADMAP.md](./ROADMAP.md) §0.5): OSDK 'Hello World' ✅ → **Expense Reporting**(개념 학습, ⭐핵심) → Ontology Manager에서 본인 업무 도메인으로 직접 객체 타입 설계 → 그 위에 Action+Workshop 얹기 → (선택) Feedback Loop with AIP Evals
