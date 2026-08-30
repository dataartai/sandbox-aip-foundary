# Expense Reporting 실습 계획서

> **문서 위치**: 이 파일은 실습 프로젝트(`D:\OneDrive\Cursorhome\aip-practice\02-expense-reporting`)의 정본 계획서입니다.
> 원본 레포(`aip-community-registry`)는 읽기 전용 참고 자료이며 수정하지 않습니다.
> 공통 규칙(원본 레포 취급, 토큰 취급, conda 명명, Foundry 제약, 학습목표 표기 의무)은 상위 `aip-practice/CLAUDE.md`에 있고 자동 상속됩니다.

## 학습목표

> 온톨로지 위에서 **Action(쓰기)·Function(AIP Logic)·Workshop(화면)이 하나의 업무 흐름으로 엮이는 실제 사례**를 뜯어보고, Ontology Manager에서 Action Type을 직접 편집해보는 것.

01번(OSDK Hello World)이 "온톨로지를 읽는 파이프라인"만 다뤘다면, 이번은 **온톨로지 위에 워크플로우가 어떻게 얹히는지**를 배우는 실습입니다. `ROADMAP.md` §0.5(Palantir 지원 준비용 압축 트랙)의 2단계.

---

## 현재 상태 (2026-08-30)

| Phase | 상태 |
|---|---|
| **사전 점검** | ✅ 완료 — zip 로컬 스캔, 설치 차단 위험 없음 확인 |
| **Phase 1 — 마켓플레이스 업로드·설치** | ✅ 완료 (2026-08-30) |
| **Phase 2 — Action Type 편집(README 필수 단계)** | ✅ 완료 (2026-08-30) |
| **Phase 3 — 개념 탐구(Ontology·Action·Function·Workshop 연결 확인)** | ✅ 완료 (2026-08-30) — 상세는 `NOTES.md`·`../GLOSSARY.md` |
| **Phase 4 — 확장 연습(선택)** | ⬜ 대기 (다음 세션에서 이어갈 것) |

**사전 점검 결과** (`ROADMAP.md`에 기록된 전체 스캔의 일부, 근거등급: 실측):

| 항목 | 값 |
|---|---|
| `THIRD_PARTY_APPLICATION` 리소스 (01을 막았던 원인) | ❌ 없음 — 이번엔 그 이유로는 안 막힘 |
| 리소스 구성 | `ONTOLOGY` 39 · `STATIC_DATASET` 4 · `COMPASS` 3 · `WORKSHOP` 2 · `FUNCTIONS` 2 · `MEDIA_SET` 2 · `VALUE_TYPE` 1 · `BLOBSTER` 1 · `AUTHORING_REPOSITORY` 1 |
| 번들 크기 | 39개 온톨로지 리소스 — 01(16개)보다 조금 크지만 Personal Finance(247개)보다 훨씬 작아 혼자 훑어보기 적당한 규모 |

> 이 실습은 **로컬 Python 환경이 필수가 아닙니다.** README를 실측한 결과 전부 Foundry 웹 콘솔 안에서 끝나는 작업이라, 01처럼 conda env·Jupyter·SDK 설치가 기본 경로엔 없습니다. (Phase 4에서 선택적으로 OSDK 확장을 해볼 수는 있습니다 — 그때 conda env `aip-expense-reporting`을 상위 규칙대로 새로 만듭니다.)

---

## Context

`aip-community-registry`의 **Expense Reporting** 프로젝트(원본: `D:\OneDrive\Cursorhome\aip-community-registry\Expense Reporting\`)를 실습합니다.

README를 직접 읽어 확인한 내용(근거등급: 실측):

- **업무 흐름**: 영수증 제출(모바일) → LLM이 파싱·분류·임베딩 → **회사 정책에 맞으면 AIP Logic이 자동 승인**, 안 맞으면 승인 앱(Workshop)으로 라우팅되어 매니저가 승인/반려.
- **핵심 객체 2개**: `Expense`(비용 항목), `Project`(PK+Title뿐인 "notional object" — README가 명시적으로 "사용자가 직접 확장해서 쓰라"고 함). 이 `Project`가 §0.5 3단계(직접 설계 연습)의 좋은 출발점이 될 수 있음.
- **설치 후 필수 수동 단계 1개**: Ontology Manager → Action Types → `Create Expense` 액션을 열어 `Receipt Attachment (PDF)`·`Receipt Image` 속성을 Rules에 추가하고 저장. **이게 이번 실습에서 유일하게 "손으로 설계"를 만지는 지점**입니다.
- README가 스스로 밝히는 한계·확장 여지(그대로 §0.5 3~4단계 연습 소재로 쓸 수 있음):
  - `Billable`이 기본 `true`로 하드코딩돼 있음 — 실제로는 프로젝트/코스트 코드에 따라 달라져야 함
  - `Expense Approver`가 기본으로 "생성한 사용자" — 실제로는 프로젝트 기반 또는 조직 계층 기반이어야 함
  - 자동 승인 로직이 프롬프트 안에 정책을 하드코딩 — README는 "정책을 별도 온톨로지 객체로 분리하면 더 낫다"고 직접 제안함
  - "한 번에 영수증 1개"만 지원 — "여러 영수증 한 번에" 액션이 확장 후보로 제시됨

이 확장 여지들은 **AIP가 "완성형 앱을 설치하는 도구"가 아니라 "직접 모델링·확장하는 플랫폼"이라는 걸 보여주는 좋은 예시**라서, Phase 4에서 하나를 골라 실제로 건드려보는 걸 권장합니다.

---

## 실습 폴더

```
D:\OneDrive\Cursorhome\aip-practice\
└── 02-expense-reporting\                ← 이 실습
    ├── PLAN.md                          # 이 문서 — 정본 계획서
    ├── NOTES.md                         # 진행 체크리스트 + 채워넣을 정보표 + 함정
    ├── README-original.md               # 원본 README 사본 (수정 금지, 참조용)
    ├── expense_reporting.zip            # Foundry 마켓플레이스 업로드용 패키지
    └── .gitignore
```

원본 레포는 건드리지 않습니다(읽기 전용 참고). 엔롤먼트 공통값은 상위 `_shared\.env` 상속.

---

## Phase 1 — 마켓플레이스 업로드·설치

01번은 zip이 막혀 이 흐름을 실제로 완주하지 못했습니다 — **Marketplace Getting Started Tutorial(2026-08-30 완주, `../ROADMAP.md` §3.5)이 훨씬 정확한 선례**이니 헷갈리면 그 경험을 기준으로 삼습니다.

1. **DevOps** → 기존 스토어 `aip-practice-store` 재사용(Change store) → `New product` 옆 드롭다운 → **Upload to store** → `expense_reporting.zip` 업로드
2. **Marketplace** → 우측 상단 **Search products...** 입력창에서 방금 올린 제품 검색(검색 전엔 버튼이 안 보임) → 결과 카드 화면 우측 상단 **Create new installations** 클릭 → 체크박스로 제품 선택 → 하단 **Create installation job draft**
3. "Create installation job" 대화창에서:
   - **Project**: `Generate new project` 클릭 → 이름은 폴더명과 맞춰 `02-expense-reporting`(01과 같은 이유로 실습마다 설치 산출물 분리)
   - **"Project locking recommended" 경고는 무시**하고 넘어가도 됨(개인 학습용, 프로덕션 아님)
   - **Create**
4. 좌측 메뉴 **General**(의존성 그래프 — 이번엔 단일 제품이라 안 뜰 가능성 높음) → **Inputs**(README상 필수 입력 없을 것으로 예상, optional 항목은 기본값 유지) → **Outputs**(설치되면 생길 객체 타입·Action Type·Workshop 앱을 미리 확인) → 우측 상단 **Install**
   - 사전 점검(`THIRD_PARTY_APPLICATION` 없음)은 통과했지만, 다른 이유로 막힐 가능성은 남아있습니다. 막히면 즉시 `NOTES.md`에 기록하고 사용자에게 보고 — 01처럼 우회로를 찾습니다.
5. 설치 완료 화면에서 "Installation completed successfully" 확인 → **View installation**으로 Outputs overview까지 확인

---

## Phase 2 — Action Type 편집 (README 필수 단계)

1. **Ontology Manager** 열기 → 좌측 **Action Types** → `Create Expense` 검색·클릭
   (또는 `Expense` 객체 타입 페이지에서 연결된 Action으로 진입 가능 — README 명시)
2. **Rules** 섹션에서 속성 2개 추가: `Receipt Attachment (PDF)`, `Receipt Image`
3. **Save**

이 단계가 끝나야 영수증 첨부가 액션에 반영됩니다. 여기서 Action Type 편집 UI 자체를 눈에 익혀둡니다 — Phase 4에서 새 Action을 직접 만들 때 재사용할 화면입니다.

---

## Phase 3 — 개념 탐구 (이번 실습의 본론)

설치·필수 편집이 끝나면, 화면을 옮겨다니며 아래를 확인합니다. 각 항목은 "온톨로지 위에서 워크플로우가 어떻게 조립되는가"의 한 조각입니다.

1. **Ontology Manager에서 `Expense`/`Project` 객체 타입 구조 확인** — 속성 목록, `Project`가 왜 PK+Title뿐인 "notional object"인지 확인
2. **`Expense` 객체에 연결된 Action Types 전체 확인** — `Create Expense` 외에 승인/반려 관련 액션이 있는지, 각 액션이 "누가 어떤 속성을 바꿀 수 있는지"를 어떻게 타입으로 정의하는지
3. **Workshop에서 "Review Expenses" 앱(또는 유사 이름) 열어보기** — 매니저가 승인/반려하는 화면이 Action Type과 어떻게 1:1로 연결되는지 확인. 화면의 버튼 하나하나가 Ontology Action 호출이라는 걸 직접 확인
4. **AIP Logic/Function 쪽에서 "자동 승인 에이전트" 찾아보기** — README가 언급한, 정책을 설명하는 프롬프트가 어디 있는지, `Query`/`Action` 권한을 이 로직에 어떻게 부여했는지
5. **Automate(있다면)에서 이 흐름이 어떻게 트리거되는지 확인** — 영수증 제출이 자동 승인 로직을 어떻게 발동시키는지

이 5개를 다 보고 나면 "온톨로지 → Action → Function → Workshop → (Automate)"가 실제 화면에서 어떻게 이어지는지 손으로 만져본 게 됩니다.

**개념 기록**: 이 Phase는 `../GLOSSARY.md`의 "Action Type" 항목에 적어둔 "다음에 확인할 것"(정책에 맞으면 AIP Logic이 자동으로, 안 맞으면 사람이 Workshop에서 수동으로 같은 종류의 승인 액션을 호출하는 대칭 구조)을 실측으로 닫는 자리입니다. 확인되면 그 항목을 갱신하세요. 새로 발견한 개념이 있으면 "내 질문/가설 → 확인된 이해" 형식으로 항목을 추가합니다.

---

## Phase 4 — 확장 연습 (선택, 권장)

README가 스스로 지적한 한계 중 **하나만** 골라 직접 고쳐봅니다. 난이도 낮은 순:

1. **(쉬움) `Billable` 기본값 로직 손보기** — Action Type의 기본값/조건 로직을 직접 편집
2. **(중간) `Project` 객체를 실제로 확장하기** — PK+Title뿐인 `Project`에 속성 몇 개(예산·부서 등) 추가, `Expense`와의 Link 확인 → 이게 §0.5 3단계(직접 설계)의 워밍업이 됨
3. **(어려움) "Create Multiple Expenses" 액션 신설** — README가 제안한 대로, 여러 영수증을 한 번에 처리하는 새 Action Type을 처음부터 만들어보기

어느 걸 고르든 **Ontology Manager에서 뭔가를 새로 만들거나 고치는 것**이라, 이 실습 전체에서 유일하게 "수동적 관찰"을 벗어나는 지점입니다.

---

## 검증 (end-to-end)

1. Marketplace 설치 완료 — Ontology Manager에 `Expense`·`Project` 객체 타입과 샘플 데이터 존재
2. `Create Expense` Action에 `Receipt Attachment`·`Receipt Image` 속성 반영됨 (Phase 2)
3. Workshop의 승인 앱에서 실제로 영수증 데이터를 눈으로 확인 가능
4. Phase 4 확장 항목 중 최소 1개를 실제로 저장·반영 완료

**최종 성공 기준**: Ontology(구조) → Action(쓰기 규칙) → Function(로직) → Workshop(화면)이 어떻게 한 흐름으로 엮이는지, 화면과 코드 양쪽에서 최소 한 번씩 짚어낼 수 있는 상태.

---

## 참고 자료

- 원본 README: `D:\OneDrive\Cursorhome\aip-community-registry\Expense Reporting\README.md` (사본: `README-original.md`)
- 상위 로드맵: `../ROADMAP.md` §0.5(압축 트랙), §1 Stage 1 ①
- 마켓플레이스 설치 흐름의 실제 선례: `../ROADMAP.md` §3.5 — Marketplace Getting Started Tutorial (2026-08-30 완주, 01보다 정확)
- 개념 노트(누적): `../GLOSSARY.md` — 실습 중 새로 확인되는 개념은 이 문서에 "가설 → 이해" 형식으로 추가
- 01번 실습 진행 로그(SDK/OSDK 관련 함정 재사용): `../01-osdk-hello-world/NOTES.md`
