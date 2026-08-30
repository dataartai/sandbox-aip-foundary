# Expense Reporting 실습 노트

> **학습목표**: 온톨로지 위에서 Action(쓰기)·Function(AIP Logic)·Workshop(화면)이 하나의 업무 흐름으로 엮이는 실제 사례를 뜯어보고, Ontology Manager에서 Action Type을 직접 편집해보는 것.

원본: [aip-community-registry / Expense Reporting](https://github.com/palantir/aip-community-registry/tree/develop/Expense%20Reporting)

DevOps·Ontology Manager 등 앱 사용법 자체는 01번에서 익혔지만, **마켓플레이스 설치 흐름(검색→Create new installations→Inputs/Outputs 검토→Install)은 01이 아니라 Marketplace Getting Started Tutorial(2026-08-30 완주)이 정확한 선례**입니다 — 01은 zip이 막혀 이 흐름을 실제로 완주하지 못했습니다. 헷갈리면 `../ROADMAP.md` §3.5와 `../GLOSSARY.md`(개념), SDK/OSDK 관련은 `../01-osdk-hello-world/NOTES.md`를 참고하세요. 이 문서는 02번 고유 정보만 담습니다.

**개념 기록 규칙**: 이번 실습에서 새로 확인한 개념(예: Action Type의 "사람 vs 자동 호출" 대칭 재확인)은 이 파일이 아니라 `../GLOSSARY.md`에 "내 질문/가설 → 확인된 이해" 형식으로 추가합니다. 이 파일(NOTES.md)은 진행 체크리스트·환경정보·이 실습 고유 함정만 담습니다.

---

## 내 환경 정보 (채워넣기)

| 항목 | 값 |
|---|---|
| Enrollment URL | `_shared/.env` 상속 (`https://dataartai.usw-23.palantirfoundry.com`) |
| 마켓플레이스 스토어 | `aip-practice-store` 재사용 (01번에서 만든 것 그대로) |
| 이번 실습 Foundry 프로젝트 (설치 산출물) | `02-expense-reporting` (space `dataartai-c040c8`) |
| 설치한 제품 버전 | Expense Management Application 0.3.0 |
| Action Type 편집 완료 여부 (Phase 2) | |
| Phase 4에서 고른 확장 항목 | |

---

## 진행 체크리스트

### 사전 점검 ✅ 완료
- [x] zip 로컬 스캔 — `THIRD_PARTY_APPLICATION` 없음 확인 (`ROADMAP.md` 전체 스캔 표 참고)

### Phase 1 — 마켓플레이스 업로드·설치 ✅ 완료
- [x] DevOps → `aip-practice-store` → Upload to store → `expense_reporting.zip` (제품명: Expense Management Application 0.3.0)
- [x] Marketplace → 검색 → Create new installations → 체크박스 선택 → Create installation job draft
- [x] `Generate new project` → 이름 `02-expense-reporting` (Project locking 경고는 무시)
- [x] General/Inputs/Outputs 탭 확인 → **Install** (Outputs 경고 2건은 Code Repositories 템플릿 버전 관련 비차단성 안내였음 — 설치 후 자동 업그레이드 PR 생성 예정, 나중에 머지)
- [x] 설치 확인: "Installation completed successfully" — Action Types 4개(`Create Expense`, `Create Project`, `Approve Multiple Expenses`, `Reject Multiple Expenses`), Datasets(`Expense`, `Project`, `Receipt Images` 등) 전부 Installed

### Phase 2 — Action Type 편집
- [ ] Ontology Manager → Action Types → `Create Expense`
- [ ] Rules에 `Receipt Attachment (PDF)`·`Receipt Image` 추가 → Save

### Phase 3 — 개념 탐구
- [x] `Expense`/`Project` 객체 타입 구조 확인 (Object Explorer에서 실제 레코드로 확인, Project는 PK+Title+Project Name뿐)
- [x] `Expense`에 연결된 Action Types 전체 확인 (Create Expense, Create Project, Approve/Reject Multiple Expenses)
- [x] Workshop 승인 앱("Expense Portal") 열어서 Action 연결 확인 — Approve 버튼 클릭 → Approval Status: Approved로 실제 반영 확인
- [x] Function에서 자동 승인 에이전트 확인 — **코드 원문 직접 열람 완료** (Ontology Manager → Approve Multiple
      Expenses → Rules → Code preview). `approveMultipleExpenses` 함수는 정책 판단 로직 없이 무조건
      `approvalStatus = "Approved"`로 고정하는 벌크 유틸. README의 "자동 승인"은 별도 무인 백엔드가 아니라
      Workshop의 "Ask AIP" 위젯(정책 프롬프트 내장)이 사람을 보조하고 사람이 최종 클릭하는 구조로 결론.
      (영수증 업로드 에러는 이 결론과 무관 — 더 안 파도 됨, 사용자 판단)
- [x] Automate 트리거 확인 — 패키지 안에 Automate 리소스 없음, Action Type의 Automation 의존성도 0건 (Automate는 이 앱에서 안 쓰임)

### Phase 4 — 확장 연습 (선택)
- [ ] 항목 1개 선택해서 실제로 편집·저장

---

## 함정 (미리 알아둘 것)

1. **로컬 Python 환경이 기본적으로 필요 없습니다.** 이 실습은 전부 웹 콘솔 작업입니다. Phase 4에서 OSDK로 확장하기로 하면 그때 `conda create -n aip-expense-reporting ...` 로 새 env를 만드세요(01의 `osdk-hello`는 상위 규칙 확정 전이라 예외였을 뿐, 새 실습은 `aip-<슬러그>` 규칙을 따릅니다).
2. **Action Type 편집(Phase 2)을 건너뛰지 마세요.** README가 명시한 필수 단계이며, 안 하면 영수증 첨부가 액션에 반영되지 않습니다.
3. **`Project` 객체가 비어 보이는 건 의도된 것입니다.** README가 "PK+Title뿐인 notional object, 직접 확장해서 쓰라"고 명시했습니다. 버그가 아닙니다.
4. **01번에서 겪은 함정 중 여전히 유효한 것**: 원본 레포에 커밋 금지, 토큰 하드코딩 금지(Phase 4에서 OSDK 쓸 경우), Foundry 프로젝트는 중첩 안 됨.

---

## 알려진 이슈 (미해결)

- **영수증 파일(Receipt Image/PDF) 첨부 후 `Create Expense` 제출 시 "Unknown Server Error [Default] Internal"**.
  파일 없이 제출하면 성공. 재현은 됐지만 근본 원인(미디어셋 설정? 파일 크기/포맷? Receipt Format 필드
  자동값 충돌?)은 미확인 — Ontology Manager의 Create Expense History 탭에서 상세 에러 로그를 아직 안 봤음.
  **의도적으로 보류함**(2026-08-30) — 아래에서 확인했듯 애초에 이 경로 끝에 있는 "정책 기반 자동승인"이
  실질적으로 존재하지 않는 것으로 결론 났기 때문에, 이 에러를 풀 실익이 낮음. 다음에 이 실습으로 돌아오면
  Phase 4 항목으로 다뤄도 되고 그냥 넘어가도 됨.

## 진행 로그

- 2026-08-30: `02-expense-reporting` 폴더 생성, PLAN.md·NOTES.md 작성. README 실측 완료(핵심 흐름·필수 편집 단계·확장 여지 3가지 파악). zip 사전 스캔에서 `THIRD_PARTY_APPLICATION` 없음 확인(ROADMAP.md 전체 스캔의 일부). Phase 1(마켓플레이스 업로드) 대기 중.
- 2026-08-30: Phase 1·2 완료(마켓플레이스 설치, Create Expense Action에 Receipt 속성 2개 추가). zip 파일을 로컬에서 완전히 해체해 블록 구조 분석(manifest.json → blockSetVersionId 파일 → blocks/*.zip 다단 구조), Ontology/Workshop("Expense Portal")/Functions(my-functions 리포)의 역할 구분 확인. Expense Portal에서 실제로 Expense 생성→Approve까지 end-to-end 실행 성공, 단 영수증 업로드는 서버 에러로 미해결. Phase 3 핵심 목표(Ontology→Action→Function→Workshop 연결) 달성, 자동판단 경로만 남음.
- 2026-08-30: 승인 로직 최종 확인 — `Approve Multiple Expenses` Action type의 Rules에서 `approveMultipleExpenses` 함수 코드 원문을 직접 열람, 정책 판단 로직이 전혀 없는 무조건 승인 함수임을 확인. Workshop의 "Ask AIP" 위젯을 실제로 열어보니 "legacy widget configuration removed" 경고로 아예 작동 안 함(패키지 제작 2025-01 이후 플랫폼이 지원 종료). 결론: README의 "정책 기반 자동 승인"은 이 배포판에서는 실체가 없고, 실제로는 human-in-the-loop 구조. **Phase 3 완전 종료, 세션 마무리** — PLAN.md·GLOSSARY.md·../ROADMAP.md·../다음작업.md에 반영. 다음 실습은 AIP Logic Getting Started(공식 가이드, 폴더 불필요).
- 2026-08-30: **AIP Logic Getting Started(공식 가이드, 별도 폴더 없음)를 이 Foundry 프로젝트(`02-expense-reporting`) 안에서 진행·완료.** 이 프로젝트의 `Expense` 객체를 재사용했고, 그 결과로 이 프로젝트에 새 리소스 3개가 영구적으로 남았다 — Logic 함수 `expense-classifier`(v1.0.0, publish 완료), Action Type `Edit Expense Category`(Expense Category 속성 단독 수정용, 이 실습에서 직접 설계·생성), Action Type `Classify Expense`(expense-classifier를 감싸 실행하는 Action). 실제 Expense 객체 하나의 `Expense Category`를 "No value" → `Office Supplies`로 실제 변경까지 확인(Preview run이 아니라 Action 실제 실행). 상세 절차·트러블슈팅(LLM이 Apply actions tool로 대상 객체 primaryKey를 못 채워 `"expense":"null"` 에러 → Ontology Action 블록으로 객체 참조를 결정적으로 고정하는 구조로 전환)은 이 파일이 아니라 `../ROADMAP.md`(§0.5, §1 누적 표)에 기록. 다음 실습은 "직접 설계"(본인 업무 도메인 객체 타입, `../다음작업.md` 참고).
