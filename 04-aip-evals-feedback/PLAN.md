# Feedback Loop with AIP Evals 실습 계획서

> **문서 위치**: 이 파일은 실습 프로젝트(`D:\OneDrive\Cursorhome\aip-practice\04-aip-evals-feedback`)의 정본 계획서입니다.
> 원본 레포(`aip-community-registry`)는 읽기 전용 참고 자료이며 수정하지 않습니다.
> 공통 규칙(원본 레포 취급, 토큰 취급, conda 명명, Foundry 제약, 학습목표 표기 의무)은 상위 `aip-practice/CLAUDE.md`에 있고 자동 상속됩니다.

## 학습목표

> 사용자 피드백이 온톨로지에 쌓이고 **AIP Evals 평가 스위트에 동적으로 반영**되는 검증·피드백 루프를 구축해, LLM 출력 품질을 **"눈으로 판단"에서 "계측 가능한 루프"**로 바꾸는 것.

01~03번이 "온톨로지 읽기 → 워크플로우 관찰/제작 → 직접 설계"였다면, 이번은 **그 LLM 출력이 실제로 얼마나 정확한지 숫자로 재는 법**을 배우는 실습입니다. `ROADMAP.md` §0.5(압축 트랙)의 5번(선택), Stage 3 ⑦.

`03-lead-management`에서 만든 `lead-classifier`(Use LLM + Struct 출력)가 실측으로 확인했듯 LLM 판단은 확률적이라 매번 다를 수 있다는 걸 겪었습니다(`../GLOSSARY.md` "확률적 결과 ≠ 기준 없음" 항목) — 이번 실습은 "그래서 그 변동성을 어떻게 계측하고 관리하는가"에 대한 정답지입니다.

---

## 현재 상태 (2026-08-30)

| Phase | 상태 |
|---|---|
| **사전 점검** | ✅ 완료 — `ROADMAP.md` 전체 스캔에서 `THIRD_PARTY_APPLICATION` 없음 확인 (설치 차단 위험 낮음) |
| **Phase 1 — 마켓플레이스 업로드·설치** | ⬜ 대기 |
| **Phase 2 — Claims Parsing 프로세스 실행** | ⬜ 대기 |
| **Phase 3 — 추출값에 피드백 제공** | ⬜ 대기 |
| **Phase 4 — Object Explorer에서 테스트케이스 필터·저장** | ⬜ 대기 |
| **Phase 5 — AIP Evals 평가 스위트 설정** | ⬜ 대기 |
| **Phase 6 — Evaluator 구성** | ⬜ 대기 |
| **Phase 7 — 평가 스위트 실행·결과 확인** | ⬜ 대기 |
| **Phase 8 — 피드백 루프 실제로 돌려보기 (선택)** | ⬜ 대기 |

**사전 점검 결과** (`ROADMAP.md` §4 전체 스캔의 일부, 근거등급: 실측 — 2026-08-30 로컬 zip manifest 파싱):

| 항목 | 값 |
|---|---|
| `THIRD_PARTY_APPLICATION` 리소스 (01을 막았던 원인) | ❌ 없음 — 이번엔 그 이유로는 안 막힘 |
| 상세 리소스 구성(ONTOLOGY/WORKSHOP/FUNCTIONS 개수 등) | 미확인 — 02번과 달리 이번엔 개수까지는 안 셈. 설치 시 Outputs 탭에서 실제 확인 예정 |

> **Install 버튼까지 가서 최종 확인은 여전히 필요합니다** — 로컬 스캔은 "알려진 실패 원인 하나"만 걸러낼 뿐, 조직 권한·엔롤먼트 티어 제한(특히 AIP Evals 자체가 티어에 따라 안 보일 수 있다고 `ROADMAP.md` §3에 이미 경고돼 있음)까지 보장하진 않습니다.

---

## Context

`aip-community-registry`의 **Feedback Loop with AIP Evals** 프로젝트(원본: `D:\OneDrive\Cursorhome\aip-community-registry\Feedback Loop with AIP Evals\`)를 실습합니다.

README를 직접 읽어 확인한 내용(근거등급: 실측):

- **업무 흐름**: 보험 청구 문서(insurance claims documents) 업로드 → LLM 에이전트가 문서에서 핵심 항목을 추출(entity extraction) → Workshop 화면에서 사용자가 **추출된 각 필드를 클릭해 👍/👎 피드백** → 👎면 "실제/기대값(reference value)"을 입력 → 이 피드백이 온톨로지 객체(`Field Extraction Job`)에 쌓임 → `Is Test Case = true`로 표시된 것만 필터링해 **테스트케이스 세트**로 저장 → AIP Logic 함수의 **AIP Evals 평가 스위트**가 그 Object set을 동적으로 흡수 → **Evaluator**(정확도 채점 방식)를 골라 평가 실행 → 결과 대시보드에서 pass/fail·정확도 확인
- **핵심 객체**: `Field Extraction Job` (LLM이 추출한 값 + 사람이 준 피드백 + `Is Test Case` 플래그를 담는 객체로 추정 — 설치 후 Ontology Manager에서 실제 속성 확인 필요)
- **Evaluator 선택이 이번 실습의 설계 포인트**: README가 명시적으로 조언 — "Exact string match"는 빠르지만 LLM이 표현만 바꿔 말해도(paraphrase) 오탐(false failure) 남. "Keyword checker"가 대안이거나, 커스텀 fuzzy-matching 함수(LLM 기반도 가능)를 직접 만들 수도 있음. **이 트레이드오프를 실제로 겪어보는 게 이번 실습의 핵심**.
- **피드백 루프가 "동적"이라는 의미**: 👎 버튼으로 새 피드백이 쌓일 때마다 reference value가 자동 갱신되므로, Evals 스위트를 다시 돌릴 때마다 **최신 사용자 기대치 기준으로 재검증**됨 — 수동으로 테스트 데이터를 유지보수할 필요가 없다는 게 README의 핵심 주장. 이걸 실제로 체감하려면 Phase 8(선택)에서 피드백을 하나 더 추가하고 재평가해봐야 함.

---

## 실습 폴더

```
D:\OneDrive\Cursorhome\aip-practice\
└── 04-aip-evals-feedback\               ← 이 실습
    ├── PLAN.md                          # 이 문서 — 정본 계획서
    ├── NOTES.md                         # 진행 체크리스트 + 채워넣을 정보표 + 함정
    ├── README-original.md               # 원본 README 사본 (수정 금지, 참조용)
    ├── feedback_loop_evals.zip          # Foundry 마켓플레이스 업로드용 패키지
    └── .gitignore
```

원본 레포는 건드리지 않습니다(읽기 전용 참고). 엔롤먼트 공통값은 상위 `_shared\.env` 상속. Foundry 프로젝트는 이 폴더와 이름을 맞춰 `04-aip-evals-feedback`으로 새로 생성.

---

## Phase 1 — 마켓플레이스 업로드·설치

02번(Expense Reporting)과 동일한 흐름입니다 — 헷갈리면 `02-expense-reporting/NOTES.md`를 그대로 선례로 참고합니다.

1. **DevOps** → 기존 스토어 `aip-practice-store` 재사용(Change store) → `New product` 옆 드롭다운 → **Upload to store** → `feedback_loop_evals.zip` 업로드
2. **Marketplace** → Search products...에서 방금 올린 제품 검색 → **Create new installations** → 체크박스 선택 → **Create installation job draft**
3. "Create installation job" 대화창: **Project → Generate new project** → 이름 `04-aip-evals-feedback` → Project locking 경고 무시 → **Create**
4. **General/Inputs/Outputs** 탭 확인(README상 필수 입력이 있는지 이번엔 직접 확인 필요 — 02번은 없었지만 이번 패키지는 미확인 상태) → **Install**
5. "Installation completed successfully" 확인 → **View installation**으로 Outputs overview 확인 — 어떤 Object type·Action type·Workshop 앱이 설치됐는지 여기서 처음 정확히 파악됨

---

## Phase 2 — Claims Parsing 프로세스 실행

1. 설치된 Workshop 앱을 열고, 문서 하나를 선택
2. 우측 상단 **"Start Process"** 클릭
3. 미리 만들어진 **"Claims Parsing"** 프로세스 선택
4. AI 에이전트가 문서를 처리할 때까지 대기 (README 원문에 소요시간 명시 없음 — 실측해서 NOTES.md에 기록)

---

## Phase 3 — 추출값에 피드백 제공

1. 추출이 끝나면, LLM이 뽑아낸 필드 중 하나를 클릭
2. 👍(맞음) 또는 👎(틀림) 선택
3. 👎를 고르면 **"실제/기대값(reference value)"** 입력창이 뜸 — 정답을 직접 입력
4. 여러 필드에 반복해서 피드백을 남겨, 다음 Phase에서 쓸 테스트케이스를 몇 개 확보

---

## Phase 4 — Object Explorer에서 테스트케이스 필터·저장

1. **Object Explorer**에서 `Field Extraction Job` 객체 타입 열기
2. `Is Test Case = true`(또는 `Yes`)로 필터링 — Phase 3에서 피드백 남긴 것들이 여기 걸릴 것
3. 이 Object set을 **Exploration으로 저장**, 권한은 **Public**으로 설정(다음 Phase에서 Evals 스위트가 이걸 참조하려면 필요)

---

## Phase 5 — AIP Evals 평가 스위트 설정

1. 이 워크플로우를 지원하는 **AIP Logic 함수**를 연다(설치 위치: `logic` 폴더로 README에 명시됨)
2. 우측 사이드바에서 **AIP Evals 평가 스위트 생성**
3. 스위트를 채우는 방식으로 **Object set**을 선택 → Phase 4에서 저장한 Exploration을 선택
4. 피드백이 자동으로 테스트케이스로 흡수되는 것을 확인 — **이게 "동적 피드백 루프"의 핵심 증거**, 화면에서 직접 확인하고 NOTES.md에 스크린샷/설명으로 남길 것

---

## Phase 6 — Evaluator 구성

정확도를 어떻게 채점할지 정하는 단계. **여러 개 시도해보고 비교하는 걸 권장**:

1. 먼저 built-in **"Exact string match"**로 빠르게 베이스라인 확인 — 아마 과도하게 엄격해서 실패가 많이 뜰 것(README 경고대로)
2. **"Keyword checker"**로 바꿔서 같은 테스트케이스 재실행 — 결과가 어떻게 달라지는지 비교
3. (선택, 여유 있으면) **커스텀 fuzzy-matching evaluator**를 직접 만들어보기 — LLM 기반 채점도 가능

---

## Phase 7 — 평가 스위트 실행·결과 확인

1. 평가 스위트 **Run**
2. AIP Evals가 각 테스트를 orchestrate → pass/fail 기록 → 대시보드에 지표 집계
3. 결과가 기대에 못 미치면 → 프롬프트 수정 / 온톨로지로 컨텍스트 추가 / 모델 교체 중 하나를 시도할 수 있다는 것만 이번엔 개념으로 확인(실제 튜닝은 Phase 8)

---

## Phase 8 — 피드백 루프 실제로 돌려보기 (선택, 권장)

이 실습의 "결정적 증거"를 만드는 단계입니다:

1. 새 문서를 하나 더 처리하거나, 기존 결과에 👎 피드백을 하나 더 추가(reference value 입력)
2. 평가 스위트를 다시 **Run**
3. **새 피드백이 자동으로 테스트케이스에 반영돼 재평가되는지** 확인 — 사람이 테스트 데이터를 수동으로 갱신하지 않아도 되는 게 이 실습의 핵심 주장이므로, 직접 눈으로 봐야 완전히 이해했다고 할 수 있음

---

## 검증 (end-to-end)

1. Marketplace 설치 완료 — `Field Extraction Job` 등 온톨로지 객체와 Claims Parsing Workshop 앱 확인
2. 최소 문서 1건에 대해 Claims Parsing 실행 → 추출 결과 확인
3. 최소 필드 1개에 👎 피드백 + reference value 입력 완료
4. Object Explorer에서 테스트케이스 Exploration 저장 완료
5. AIP Evals 스위트가 그 Object set을 실제로 흡수한 것을 화면에서 확인
6. Evaluator 최소 1개(Exact match 또는 Keyword checker)로 평가 스위트 실행 → 결과 대시보드 확인
7. (선택) 피드백 추가 → 재평가 → 반영 확인까지 하면 Phase 8 완료

**최종 성공 기준**: "LLM 출력 품질 관리"가 사람이 눈으로 훑어보는 일회성 작업이 아니라, **피드백이 쌓일수록 자동으로 갱신되는 계측 루프**라는 것을 화면으로 직접 확인하는 것.

---

## 참고 자료

- 원본 README: `D:\OneDrive\Cursorhome\aip-community-registry\Feedback Loop with AIP Evals\README.md` (사본: `README-original.md`)
- 상위 로드맵: `../ROADMAP.md` §0.5(압축 트랙 5번), §1 Stage 3 ⑦, §2(AIP Evals = 6번 LLM의 검증축)
- 마켓플레이스 설치 흐름의 실제 선례: `../02-expense-reporting/NOTES.md` (같은 설치 절차를 이미 한 번 완주함)
- 개념 노트(누적): `../GLOSSARY.md` — 특히 "확률적 결과 ≠ 기준 없음"(왜 이 실습이 필요한지의 배경), "AIP 프로젝트 기획 프레임"(6번 LLM 검증축 = AIP Evals)
- 직전 실습(직접 설계) 진행 로그: `../03-lead-management/NOTES.md`
