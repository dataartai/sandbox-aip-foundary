# AIP 개념 노트 — 공식 용어를 내 언어로 번역하는 기록

이 문서는 `ROADMAP.md`(진행 상태·순서)와 역할이 다르다. ROADMAP은 "뭘 언제 할지"를 담고,
이 문서는 **실습하며 부딪힌 개념을 내가 어떤 질문으로 뚫었고, 최종적으로 어떻게 이해했는지**를 담는다.
실습 폴더(`NN-*/`) 유무와 무관하게 여기 한 곳에 누적한다 — 폴더 없는 공식 튜토리얼(Marketplace 등)도 여기 적는다.

**작성 원칙**: 개념별로 묶는다(시간순 일기 아님). 같은 개념이 나중 실습에서 더 깊어지면 기존 항목에 이어 붙인다.
"공식 정의를 먼저 설명받고 외운 것"이 아니라 "내가 먼저 가설/질문을 던지고 검증받은 것"의 흐름을 살려 적는다 —
그게 이 문서의 존재 이유다.

---

## 기존 자동화(스크립트·n8n) ↔ Foundry 대응

- **출발점**: 로드맵을 처음 짤 때(2026-08-29), "내가 알던 자동화 세계의 각 부품이 Foundry에서 뭐에 대응하는가"부터
  정리해야 실습 순서를 잡을 수 있었음.
- **확인된 이해**:

  | 기존 자동화 세계 | Foundry 대응 |
  |---|---|
  | 스크립트가 CSV/DB를 읽어 가공 | Pipeline Builder / Transforms |
  | 각 스크립트가 자기만의 데이터 표현을 가짐 | **온톨로지 객체 · 링크** (표현이 하나로 통일됨) |
  | DB에 직접 UPDATE / API POST | **Ontology Action** (누가 무엇을 바꿀 수 있는지가 타입으로 정의됨) |
  | 함수 + 프롬프트 | Function / **AIP Logic** |
  | n8n 트리거 · 크론 · 웹훅 | **Automate** · Event listener |
  | 내 Docker 컨테이너 · API 서버 | **Compute Module** |
  | 대시보드 · 관리 화면 | **Workshop**(로우코드) → 부족하면 **OSDK 앱**(직접 개발) |
  | dev/prod 분리, 배포 | **Marketplace 릴리스 관리** |
  | LLM 출력 품질을 눈으로 확인 | **AIP Evals** |

  핵심은 표의 개별 대응이 아니라, Foundry에서 "워크플로우"는 별도 도구가 아니라 **온톨로지 위에서 Action·Function·
  Automate가 엮인 것**이라는 점. 그래서 학습 순서도 온톨로지 → 그 위의 워크플로우 → 내 코드 붙이기 순으로 잡았다.
- **근거 실습**: 로드맵 수립 시점 (2026-08-29), 이후 [[온톨로지(Ontology) = DB 스키마 + 앱 3계층의 통합]]으로 심화
- **관련**: [[온톨로지(Ontology) = DB 스키마 + 앱 3계층의 통합]], [[AIP 프로젝트 기획 프레임 — "의도·목적"에서 시작해 명사·동사·로직·트리거·프론트·배포까지]]

---

## 온톨로지(Ontology) = DB 스키마 + 앱 3계층의 통합

- **내 질문/가설**: "온톨로지라는 게 소프트웨어공학과 관계형 DB를 합쳐 놓은 개념인거지?"
- **확인된 이해**: 절반만 맞음. 정확히는 **관계형 DB 스키마(Object=테이블, Link=FK) + DB에는 없는 쓰기 권한 강제 계층(Action Type) + 그 위의 로직층(Function/AIP Logic)과 화면층(Workshop)**이 하나의 선언형 모델로 통합된 것.
  일반 앱 아키텍처에서도 로직층·화면층은 있지만 "누가 뭘 어떻게 쓸 수 있는가"가 코드 곳곳에 암묵적으로 흩어져 있는 반면, 온톨로지는 그걸 Action Type이라는 **별도 타입으로 명시**한다 — 이게 관계형 DB에도, 일반 3계층 아키텍처에도 없는 독자적인 층.
- **다이어그램**:
  ```
                일반 앱 아키텍처         관계형 DB          온톨로지(Foundry)
                ────────────────       ──────────         ─────────────────
  프레젠테이션층   ┌───────────────┐                        ┌───────────────┐
  (화면)          │   Frontend     │      (없음)            │   Workshop     │
                  │  (React 등)    │                        │  (노코드 앱)    │
                  └───────┬───────┘                        └───────┬───────┘
                          │ API 호출                                │ Action 호출
                          ▼                                        ▼
  비즈니스 로직층  ┌───────────────┐                        ┌───────────────┐
  (규칙/판단)      │   Service /    │      (없음, 앱단에서    │  Function /    │
                  │   Backend      │       if문으로 흩어짐)  │  AIP Logic     │
                  └───────┬───────┘                        └───────┬───────┘
                          │ 쓰기 요청                                │ 쓰기 요청
                          ▼                                        ▼
  쓰기 권한/검증층  ┌───────────────┐   UPDATE 권한/트리거    ┌───────────────┐
  (누가·뭘·어떻게)  │ (암묵적, 코드로  │  (약함, 선언 안 됨)     │  Action Type   │
                  │  구현자가 짬)   │                        │ (타입으로 강제) │
                  └───────┬───────┘                        └───────┬───────┘
                          │                                        │
                          ▼                                        ▼
  데이터 모델층    ┌───────────────┐   테이블(컬럼=속성,      ┌───────────────┐
  (스키마)         │  ORM 모델      │   PK/FK)               │ Object Type +  │
                  │                │                        │  Link Type     │
                  └───────────────┘                        └───────────────┘
  ```
- **근거 실습**: Marketplace Getting Started Tutorial (2026-08-30)
- **관련**: [[Action Type]], [[Workshop vs 대시보드]]

---

## Action Type — 호출 주체를 가리지 않는 쓰기 규칙

- **내 질문/가설**: "이 액션 수정은 사람이 하는거야? 아니면 워크플로우에서 자동으로 된다는거야?"
- **확인된 이해**: Action Type 자체는 호출 주체(사람 vs 자동 로직)를 구분하지 않는다. 정의하는 건 오직
  "누가 이 액션을 쓸 수 있고, 어떤 속성을 어떤 규칙으로 바꿀 수 있는가"라는 권한·검증 규칙뿐. 같은 Action Type을
  Workshop 화면에서 사람이 버튼 눌러 호출할 수도, Function/AIP Logic이나 Automate가 조건 판단 후 프로그램적으로
  호출할 수도 있다 — 규칙만 지키면 호출자는 상관없음.
- **실측 사례**: `Workshop Design Hub - Edit Car Issue Details` 액션을 Workshop에서 직접 폼 채우고 Submit
  눌러 수동 호출 → 테이블의 Priority 값이 실제로 바뀌는 것 확인.
- **02-expense-reporting에서 재확인 (2026-08-30, 근거등급: 실측 — zip 패키지 파일 직접 해체·검색)**: 설치용
  zip을 로컬에서 완전히 풀어보니(manifest.v1.json 다단 압축 해제), "AIP Logic이 자동 승인"이라는 README 표현은
  Foundry의 노코드 AIP Logic 빌더가 아니라 **코드 리포지토리(`my-functions`)의 Functions
  (`approveMultipleExpenses`/`rejectMultipleExpenses`, `type:"ontologyEdit"`로 명시)**로 구현돼 있었다.
  정책 프롬프트("expense policy... Food: 1인당 $50 초과 금지...")는 오히려 **Workshop 앱의 "Ask AIP" 위젯**
  설정에서 발견됨(사람 리뷰어용 코파일럿). 패키지 전체를 `automate`/`aiplogic`/`trigger` 키워드로 검색해도
  Automate 리소스가 아예 없었다.
- **라이브 실측으로 한 단계 더 정정 (2026-08-30, 근거등급: 실측 — Expense Portal에서 직접 제출·승인해봄)**:
  영수증 파일 없이 Expense를 생성하고(Cost·Category 등 전부 No value) Workshop의 "Approve Expense(s)" 버튼을
  눌렀더니 **정책 검토 없이 그냥 `Approval Status: Approved`로 즉시 바뀌었다**(Object Explorer에서 직접 확인).
  즉 이 버튼이 부르는 `approveMultipleExpenses` 함수는 **"사람이 최종 판단해서 강제 승인/반려하는 수동
  오버라이드" 경로**이고, README가 말한 "정책에 맞으면 자동 승인"은 **이것과 다른, 아직 실측 못 한 별도 경로**
  (아마 영수증 미디어 업로드 시 트리거되는 파싱→판단 함수)로 보인다. "Action Type은 호출 주체를 안 가린다"는
  원래 가설([[Action Type]])은 유효하지만, **오늘 실측한 건 "사람이 부르는 경로" 하나뿐** — 자동판단 경로는
  영수증 업로드 서버 에러(미해결) 때문에 실측이 막혀 있다.
- **함수 코드 원문으로 확정 (2026-08-30, 근거등급: 실측 — Ontology Manager → Approve Multiple Expenses → Rules →
  Code preview에서 직접 열람)**:
  ```typescript
  @Edits(Expense)
  @OntologyEditFunction()
  async approveMultipleExpenses(expenses: Expense[]): Promise<void> {
      for (const e of expenses) { e.approvalStatus = "Approved" }
  }
  ```
  정책 판단 로직(LLM 호출·조건문·금액 체크)이 **전혀 없다.** 그냥 무조건 `"Approved"`로 고정하는 벌크 유틸
  함수. 즉 README의 "정책에 맞으면 AIP Logic이 자동 승인"은 **별도의 무인 백엔드 자동화가 아니라, Workshop의
  "Ask AIP" 채팅 위젯(정책 프롬프트 내장)이 사람 리뷰어에게 판단을 보조하고, 사람이 이 트리비얼한 버튼을
  눌러 최종 확정하는 "AI 보조 + 사람 승인" 구조**로 보인다(추정 — 359개 미확인 Function 중 별도 자동판단
  함수가 있을 가능성은 완전히 배제 못 함, 다만 이 앱 설명 자체가 "foundation, not the end-all-be-all"이라고
  자인하는 것과 정합적).
- **최종 마무리 — "Ask AIP" 위젯 자체가 플랫폼에서 지원 종료됨 (2026-08-30, 근거등급: 실측 — 위젯 실행 시 뜬
  경고 문구)**: "Ask AIP"를 실제로 열어보니 "Support for this legacy widget configuration has been removed.
  Migrate to an AIP Chatbot."라는 경고와 함께 대화 자체가 작동하지 않았다. 이 패키지는 2025-01-06에 만들어졌고
  (zip manifest 타임스탬프), 그 이후 Foundry 플랫폼이 이 구버전 위젯 방식을 지원 종료한 것으로 보인다.
  결론: 이 앱에서 "정책 기반 자동/보조 판단"을 실제로 체험할 방법은 **현재 이 Foundry 인스턴스에서는 없다** —
  Function 코드엔 애초에 판단 로직이 없었고(위 항목), 그걸 보완했어야 할 AI 위젯도 버전 스큐로 죽어있다.
  "example이라 단순화했나" 가설보다는 "패키지가 플랫폼 진화를 못 따라가 방치됐다(version skew)"는 설명이 더
  정합적. 이걸로 02-expense-reporting의 승인 로직 조사는 마무리.
- **근거 실습**: Marketplace Getting Started Tutorial (2026-08-30), 02-expense-reporting Phase 3 (2026-08-30, zip 정적 분석 + 라이브 실측 + 함수 코드 원문 확인 + Ask AIP 위젯 지원종료 확인)
- **관련**: [[온톨로지(Ontology) = DB 스키마 + 앱 3계층의 통합]]

---

## Workshop ≠ 대시보드

- **내 질문/가설**: "워크샵 화면이라는 게 대시보드를 의미하는 거지?"
- **확인된 이해**: 아니다. 대시보드(읽기 전용 차트·표)는 Workshop으로 만들 수 있는 앱 형태 **중 하나**일 뿐이고,
  Workshop은 그보다 넓은 **노코드 앱 빌더**다. 실습에서 연 `Car Issues Inbox`처럼 "보기 + 필터 + Action 실행(폼
  제출)"까지 되는 **쓰기 가능한 업무 앱**(티켓 관리 앱에 가까움)도 같은 도구로 만든다.
- **근거 실습**: Marketplace Getting Started Tutorial (2026-08-30)
- **관련**: [[Action Type]]

---

## AIP 프로젝트 기획 프레임 — "의도·목적"에서 시작해 명사·동사·로직·트리거·프론트·배포까지

- **내 질문/가설**: 01-osdk-hello-world를 진행하며 "명사·동사·로직·트리거·프론트·백엔드·배포·LLM + 의도목적 + 권한"이라는
  내 나름의 프레임으로 AIP 전체 구조를 재정리해달라고 요청함 — 기존 자동화 기획(화면·스크립트부터 그리는 것)과 뭐가
  다른지 스스로 찾아낸 질문이었음.
- **확인된 이해**: AIP 기획은 화면이나 스크립트가 아니라 **"0. 의도·목적" → 온톨로지**부터 시작한다. Palantir FDE
  방법론의 출발점도 "어떤 테이블이 있나"가 아니라 "이걸로 어떤 의사결정/업무를 개선하려는가"이고, 이걸 안 하면 1번(명사=
  Object Type)부터 잘못 고른다.
  ```
  [0. 의도·목적]
         │
         ▼
  [1. 명사] ── [2. 저장(데이터 출처)] ── [3. 가공(파이프라인/Compute)]
         │
         ▼
  [4. 동사 (권한 걸림)] ── [5. 로직] ── [6. LLM] ── [6.5 모델(ML)]
         │
         ▼
  [7. 트리거]
         │
         ▼
  [8. 프론트 (권한 걸림)] ── [9. 배포 (권한 걸림)]
         │
         └── 피드백(사람의 수정·평가) ──▶ [2. 저장]으로 되돌아가 [1. 명사]를 다시 채움 (루프가 닫힘)
  ```
  이 다이어그램은 직선이 아니라 **루프**다 — 8번(프론트)에서 사람이 결과를 고치면 그 수정이 4번(Action)으로 기록되고,
  2번(저장)에 새 데이터로 쌓이고, 6번(AIP Evals)이 그 데이터로 로직/LLM 품질을 다시 측정한다.
  각 층에는 **권한·검증·관측**이라는 가로축 3개가 별도로 걸린다(0~9 순서대로 쌓이는 게 아니라 층마다 독립).
  실습 진행 중 실제로 확인한 대응 관계: 1번=Object Type/Link([[온톨로지(Ontology) = DB 스키마 + 앱 3계층의 통합]]),
  4번=Action Type([[Action Type]]), 8번=Workshop([[Workshop ≠ 대시보드]]).

  **권한·검증·관측 — 3축 상세** (0~9 순서대로 쌓이는 게 아니라 각 층마다 따로 걸림):
  - **검증**(쓰거나 배포하는 "그 순간"의 게이트): 저장/가공 → Data Health Checks · 동사(Action) → Rules/
    Submission criteria(Ontology Manager에서 직접 편집한 그 화면) · 배포 → Marketplace Validation 단계
    (01번에서 `Install` 버튼이 "blocking validation errors"로 막혔던 그 단계) · LLM/모델 → AIP Evals
  - **관측**(배포 이후 계속 지켜보는 것 — 검증과 다름): 온톨로지 객체 단위는 Ontology Manager의
    `Observability` 탭(사용량·변경 이력), 로직/모델 단위는 실행 빈도·에러율·지연시간. 관측으로 이상 신호를
    잡고, 검증으로 게이트를 걸고, 피드백루프로 다시 개선하는 구조로 맞물린다.
  - **권한**(실측): 프로젝트 단위(Sandbox=전원 Owner vs Production=owner/builder/user 그룹 분리) ·
    스토어 단위(편집 권한자만 제품 생성·수정, 보기 권한만 있어도 설치 가능) · 온톨로지 객체 단위
    (Ontology Manager의 `Security` 탭) · 클라이언트 앱 단위(Developer Console의 `OAuth & restrictions`/
    `Sharing & tokens`) — "편집자(쓰기)/보는 사람(공유)"이 매 층마다 따로 설정된다는 게 Palantir가 강조하는
    "맞는 사람에게만 맞는 데이터" 거버넌스의 실체.
- **근거 실습**: 01-osdk-hello-world (2026-08-29/30)
- **매핑 표 원본**: `ROADMAP.md` §2 — Stage 번호(④⑤⑥⑦⑧)와 대조하는 용도로 표만 유지하고, 표의 기원·해석·
  3축 상세는 이 항목으로 옮겨왔다(2026-08-30 문서 분리 정리).
- **관련**: [[온톨로지(Ontology) = DB 스키마 + 앱 3계층의 통합]], [[Action Type]], [[Workshop ≠ 대시보드]]

---

## 의존성 그래프의 두 종류 (설치 순서 vs 데이터 관계)

- **내 질문/가설**: "object action 의존성그래프는 소프트웨어공학 개념인건가?"
- **확인된 이해**: 그래프 이론이라는 도구는 같지만 목적이 다른 **두 종류**가 섞여 있었다.
  1. 설치 화면에서 본 `Datasource → Alert Inbox` 그래프는 **패키지/모듈 의존성 그래프** — npm
     `package.json`이나 빌드 시스템의 DAG(방향성 비순환 그래프)와 동일한 개념. "B를 만들려면 A가 먼저
     있어야 한다"는 설치 순서 제약.
  2. 온톨로지 내부의 `Object Type ↔ Action Type ↔ Link Type` 관계는 **데이터 모델(ERD) 그래프** —
     관계형 DB의 Entity-Relationship Diagram이나 그래프 DB의 노드-엣지 구조와 같은 개념. "누가 누구를
     가리키는가"라는 데이터 관계이지 빌드 순서가 아님.
- **근거 실습**: Marketplace Getting Started Tutorial (2026-08-30)
- **관련**: [[온톨로지(Ontology) = DB 스키마 + 앱 3계층의 통합]]

---

## AIP Logic 블록의 입력/출력 — Task prompt는 "보내는 그릇", LLM Output은 "받는 그릇"

- **내 질문/가설**: `{{expenseDescription}}` 변수를 만들면서 "이 변수명에 프롬프트의 회신 값이 저장되는거야?"라고 물음
  — 입력 변수와 LLM의 응답이 같은 그릇인 줄 알았음.
- **확인된 이해**: 아니다, 완전히 분리된 두 그릇이다.
  - **Task prompt**(입력) = 내가 채워서 LLM에 "보내는" 값. Preview run 패널의 `Function inputs`에 채운 값이
    여기로 흘러들어온다.
  - **LLM Output**(출력) = LLM이 그 입력을 보고 "돌려주는" 값. 완전히 별개의 필드다.
  - 블록이 하나뿐이면 Foundry가 자동으로 "이 블록의 출력 = 함수의 최종 Output"으로 연결해준다(블록 카드
    우측 상단에 파란 `Output` 배지로 표시). 블록이 여러 개면 그때부터 어떤 블록의 출력을 최종 Output으로
    쓸지 명시적으로 골라야 한다.
  - 변수를 프롬프트에 `/`로 삽입할 때, **String 같은 단순 타입은 통째로 삽입**되지만 **Object 타입은
    "어떤 속성을 노출할지" 고르는 서브메뉴**가 뜬다(예: `expense` 객체를 넣을 때 `Raw Expense Description`,
    `Expense Title`만 체크하고 나머지는 제외). 즉 객체를 프롬프트에 넣는다고 객체 전체가 LLM에 보이는 게
    아니라, 내가 고른 속성만 텍스트로 변환돼 보인다.
- **다이어그램**:
  ```
  Preview run 패널          Task prompt              LLM Output         Function output
  ┌──────────────┐         ┌──────────────┐        ┌──────────────┐   ┌──────────────┐
  │ expenseDesc.  │────────▶│ "...분류해줘:  │───────▶│  "Travel"     │──▶│  "Travel"     │
  │ = "출장비"     │  흘러듦  │  {expenseDesc}"│  LLM 처리│ (별도 그릇!)   │자동│ (블록 1개뿐이면│
  └──────────────┘         └──────────────┘        └──────────────┘  연결│  자동 연결)   │
                                                                          └──────────────┘
     ▲ 여기 채운 값이            ▲ "보내는" 그릇                ▲ "받는" 그릇 — 입력과
       Task prompt로 흘러듦                                        절대 같은 변수가 아님
  ```
- **근거 실습**: AIP Logic Getting Started (2026-08-30, `02-expense-reporting` 프로젝트에서 진행)
- **관련**: [[AIP Logic에서 온톨로지 쓰기 — LLM에게 "무엇을 바꿀지"까지 맡기지 말 것]]

---

## AIP Logic에서 온톨로지 쓰기 — LLM에게 "무엇을 바꿀지"까지 맡기지 말 것

- **내 질문/가설**: (탐색적으로 부딪힘) `Use LLM` 블록에 `Apply actions tool`을 추가하고 실제 `Expense` 객체를
  넣어 실행했더니 `{"expense":"null","expenseCategory":"Travel"}`로 호출되며 실패함 —
  `Invalid Expense primaryKey_ value 'null'. No Expense found with that primaryKey_ value.`
- **확인된 이해**: 원인은 위 항목의 "속성만 노출됨" 특성과 맞물려 있다. 프롬프트에는 `Raw Expense Description`,
  `Expense Title` 같은 **텍스트 속성만** 넣었지, 객체의 실제 식별자(primaryKey)는 어디에도 노출한 적이 없다.
  그런데 `Apply actions tool`은 **LLM이 스스로 모든 파라미터(대상 객체 포함)를 판단해서 채우는 방식**이라,
  LLM은 안 보이는 식별자를 요구받자 그냥 문자열 `"null"`을 지어내 호출했다.
  → **해결**: LLM에게 "어떤 객체인지"까지 판단시키지 말고, 애초에 확정된 값은 결정적(deterministic)으로
  고정하고, LLM에게는 "판단이 필요한 값"만 맡기도록 블록을 분리한다.
  ```
  기존(실패) 구조 — LLM이 전부 판단
  ┌─────────────────────────────────────┐
  │ Use LLM (+ Apply actions tool)       │
  │  - 대상 객체: LLM이 프롬프트에서 추측  │ ← 식별자가 안 보이니 "null" 지어냄
  │  - 카테고리값: LLM이 분류              │
  └─────────────────────────────────────┘

  수정(성공) 구조 — 역할을 분리
  ┌───────────────┐        ┌───────────────────────────┐
  │ Use LLM        │ 텍스트  │ Ontology "Action" 블록      │
  │ (String만 출력) │───────▶│  - 대상 객체: expense 입력   │ ← 우리가 이미 확정
  │  "Travel" 등    │        │    변수에 그대로 바인딩       │    (LLM 추측 아님)
  └───────────────┘        │  - 카테고리값: Use LLM 출력   │
                            └───────────────────────────┘
  ```
  Foundry는 이 두 번째 블록(`Ontology → Action`)을 추가하면, 파라미터 타입이 일치하는 입력 변수·블록 출력을
  **자동으로 매핑 제안**해준다(Object 타입 파라미터 ↔ Object 타입 입력 변수, String 파라미터 ↔ String 블록
  출력) — 직접 하나하나 연결선을 그을 필요 없이, 타입만 맞으면 알아서 이어준다.
- **일반화**: "LLM에게 판단(텍스트 생성)과 결정(어떤 레코드를 건드릴지)을 동시에 맡기면 결정 쪽에서 환각이
  난다"는 건 AIP Logic만의 특성이 아니라 **LLM 도구 호출(tool-calling) 전반의 공통 함정**으로 보인다 — 이후
  다른 자동화(n8n 등)에서 LLM에 쓰기 권한을 줄 때도 "대상 식별은 결정적으로 고정, LLM은 판단만" 원칙을
  적용할 만하다.
- **근거 실습**: AIP Logic Getting Started (2026-08-30)
- **관련**: [[Action Type]], [[AIP Logic 블록의 입력/출력 — Task prompt는 "보내는 그릇", LLM Output은 "받는 그릇"]]

---

## Use LLM 블록은 프롬프트에 명시적으로 넣은 것만 본다

- **내 질문/가설**: 텍스트 설명만 입력해서 카테고리 분류가 됐는데, "영수증 이미지 첨부 대신에 description을
  기준으로 expense category를 판별한거야?"
- **확인된 이해**: 맞다. `Use LLM` 블록은 System prompt + Task prompt에 **명시적으로 삽입한 것만** 본다.
  실습에서 실제로 실행 대상이었던 `Expense` 객체는 `Receipt Image`·`Receipt Attachment (PDF)`도 갖고
  있었지만, 그건 프롬프트에 넣은 적이 없어서 LLM은 그 존재 자체를 몰랐다. 심지어 그 객체의
  `Raw Expense Description` 속성도 실제로는 `No value`(빈 값)였고, 판단에 실제로 쓰인 유일한 텍스트는
  Preview run 패널에 직접 타이핑해 넣은 값(`출장비`, `사무도귀`)뿐이었다. 이미지를 실제로 "보게" 하려면
  `Media reference` 타입 입력을 별도로 추가하고 비전 지원 모델을 써야 한다 — 이번 실습은 순수 텍스트
  분류로 범위를 좁혔다.
- **근거 실습**: AIP Logic Getting Started (2026-08-30)
- **관련**: [[AIP Logic 블록의 입력/출력 — Task prompt는 "보내는 그릇", LLM Output은 "받는 그릇"]]

---

## Preview run ≠ 실제 반영 — Publish + Action 실행이 있어야 데이터가 진짜 바뀐다

- **내 질문/가설**: (탐색적으로 확인) Preview run에서 "Successfully ran" + "Proposed ontology edits"가
  뜨길래 이걸로 실제 데이터가 바뀐 줄 알고 넘어갈 뻔함.
- **확인된 이해**: Logic 편집기 화면 상단에 "Ontology edits are not applied when running a preview in
  Logic. Publish your Logic function to apply edits where functions are used."라고 명시돼 있다. 즉
  Preview run은 **"이 입력이면 이런 수정이 제안될 것"까지만 시뮬레이션**하고, 실제 온톨로지 데이터는
  건드리지 않는다. 실제로 데이터를 바꾸려면: ① Logic 함수를 **Publish** → ② 그 함수를 호출하는
  **Action Type**을 만들고(또는 Automate로 트리거) → ③ Object Explorer나 Workshop에서 그 Action을
  **실제로 실행**해야 한다. 실습에서 이 3단계를 다 거쳐서 실제 `Expense` 객체의 `Expense Category`가
  `No value` → `Office Supplies`로 바뀌는 것까지 Object Explorer에서 직접 확인했다.
  → **일반 원칙으로 확장**: Foundry의 "만들고 있는 화면"(Logic 편집기, 나중엔 Workshop 편집 모드 등)은
  기본적으로 **시뮬레이션 모드**이고, 실제 반영에는 별도의 "확정" 동작(Publish/Save/Deploy)이 있다는 걸
  전제하고 접근하는 게 안전하다.
- **다이어그램**:
  ```
  [Logic 편집기]                    [Publish]              [Action 실행]
  Preview run                         │                          │
   "Successfully ran"                 ▼                          ▼
   "Proposed ontology edits"    함수가 정식 버전을         Object Explorer/Workshop에서
     ↑ 여기까지는                 갖게 됨 (v1.0.0)          실제 버튼 클릭
     시뮬레이션일 뿐,                                              │
     실제 DB는 안 바뀜                                             ▼
                                                       Expense Category:
                                                       No value → Office Supplies
                                                       (진짜 반영됨)
  ```
- **근거 실습**: AIP Logic Getting Started (2026-08-30)
- **관련**: [[AIP Logic에서 온톨로지 쓰기 — LLM에게 "무엇을 바꿀지"까지 맡기지 말 것]]

---

## Ontology Manager vs Object Explorer — 요약본이 아니라 스키마 레이어 vs 데이터 레이어

- **내 질문/가설**: "온톨로지 매니저 app이 object explorer의 정리된 버전인가? 상위레벨 느낌."
- **확인된 이해**: 아니다. 하나가 다른 하나를 요약해서 보여주는 관계가 아니라, **완전히 다른 레이어**를
  다루는 별개의 도구다. DB로 치면 스키마 설계(DDL) 도구 vs 실제 데이터 조회(SELECT) 도구의 관계에 가깝다.
  ```
                   Ontology Manager                    Object Explorer
                   (설계도/스키마 레이어)                  (실제 데이터 레이어)
                 ┌───────────────────────┐          ┌───────────────────────┐
    다루는 것      │ Object TYPE           │          │ Object 인스턴스(레코드) │
                 │  "Expense"라는 틀      │  ────▶   │  "9796fae6-..." 그 건  │
                 │  Properties 20개 정의   │  같은 틀   │  Approver: Jenny Hong  │
                 │  Action Type 정의      │   위에서   │  Cost: No value        │
                 │                       │  실제값이  │  ...                   │
                 └───────────────────────┘  채워짐   └───────────────────────┘
                 비유: CREATE TABLE +                 비유: SELECT * FROM
                      ALTER TABLE (DDL)                     table (데이터 조회)
                 "카테고리 속성이 있나?"                "이 건의 카테고리 값은?"
                 "이걸 고칠 수 있는 Action이 있나?"      "Action 실행해서 실제로 고쳐보자"
  ```
- **실측 근거**: 이번 세션에서 Ontology Manager로는 `Expense Category` 속성 존재를 확인하고 그걸 수정할
  `Edit Expense Category` Action Type을 새로 설계·생성했고, Object Explorer로는 실제 객체
  (`9796fae6-...`)를 열어 `Expense Category: No value`라는 실제 값을 확인한 뒤 그 Action을 진짜 실행해
  `Office Supplies`로 바뀌는 것까지 확인했다 — 같은 온톨로지를 "설계 시점"과 "실행 시점"에 각각 본 것.
- **근거 실습**: AIP Logic Getting Started (2026-08-30)
- **관련**: [[온톨로지(Ontology) = DB 스키마 + 앱 3계층의 통합]]

---

## 온톨로지와 "시멘틱(semantic)" — 두 가지 다른 의미, 그리고 Semantic search ≠ Vector search (포함관계)

- **내 질문/가설**: 03번 실습을 마무리하며 "온톨로지와 시멘틱 의미는 어떻게 연결되는거야? 9번 프로젝트(Small Business Connector)에서 진행하는 것 같은데 미리 궁금해. 객체와 속성이랑은 또 다른거야?" → 이어서 "Semantic search는 vector 검색을 말하는거야? 임베딩된 벡터 검색이니까 좀 더 기술적인 단어에 해당하는건가?"
- **확인된 이해 (근거등급: 공식 문서 기반, 아직 실습으로 확인 안 함)**: Foundry 문서에서 "semantic"은 **두 가지 다른 층위**로 쓰인다.

  ```
  ① 넓은 의미 — 온톨로지 자체가 "의미론"
  ┌─────────────────────────────────────────┐
  │  원본 데이터소스(테이블·CSV)               │
  │         │  매핑                          │
  │         ▼                                │
  │  Object(고객이 뭔지) · Property(이름·나이) │
  │  · Link(누가 누구와 연결되는지)             │
  │  · Action(누가 무엇을 바꿀 수 있는지)       │
  └─────────────────────────────────────────┘
     → 원본 데이터소스를 Object·Property·Link로 매핑하는 행위 자체가
       "조직의 semantics를 정의하는 것"(공식 문서 표현). 이미 GLOSSARY의
       "온톨로지 = DB 스키마 + 3계층 통합" 항목과 같은 층위.

  ② 좁은 의미 — "Semantic search"라는 구체적 기능
  ┌─────────────────────────────────────────┐
  │  기존 Property(String, Integer 등)         │
  │         +                                │
  │  Vector/Embedding Property (신규 타입)      │
  │  "이 텍스트를 숫자 배열(벡터)로 변환"        │
  └─────────────────────────────────────────┘
     → 객체·속성과 별개의 개념이 아니라, 속성의 한 종류
       (Vector property, Dimension + Similarity Function으로 설정)로
       기존 스키마 위에 얹히는 것.
  ```

  **Semantic search vs Vector search — 포함관계이지 동의어가 아님**:
  ```
  Vector search (기술/구현 레벨)          ← 더 넓은 범주
   "벡터 사이의 거리를 계산해 가까운 걸 찾는다"
   텍스트든 이미지든 숫자 벡터면 다 적용 가능
        │
        │ (텍스트를 "의미"를 담은 벡터로 임베딩해서 쓰면)
        ▼
  Semantic search (목적/제품 레벨)        ← 그 벡터 검색의 한 활용 사례
   "언어·개념적 의미가 비슷한 걸 찾는다"
  ```
  Vector search는 "메커니즘"(벡터면 뭐든 거리 계산), Semantic search는 그 벡터가 **언어모델이 뽑은 "의미" 임베딩**일 때 붙는 이름 — "왜 이걸 하는가"를 설명하는 목적 레벨 용어. 완전한 동의어는 아니고 **semantic search ⊂ vector search**(포함관계).

  **Small Business Connector 맥락(README 실측, 실행은 아직 안 함)**: 사업체의 `사업 설명`(String) 텍스트를 임베딩해서 Vector property로 저장 → "Get Recommendations" 버튼이 내 사업체 벡터와 거리가 가까운(의미가 비슷한) 다른 사업체를 찾아줌. 태그·키워드가 정확히 안 겹쳐도 "친환경 포장재 스타트업"과 "지속가능 소재 공급업체"처럼 뜻이 비슷하면 매칭됨 — README의 "leveraging the semantics around your business"가 가리키는 게 이것.

  **기존 자동화 비유**: n8n에서 `WHERE tag = 'X'` 같은 정확 일치 필터 대신, 텍스트를 임베딩 API(OpenAI embeddings 등)로 벡터화해 코사인 유사도로 "비슷한 의미"를 찾는 것과 동일한 개념 — Foundry는 이걸 Vector property + Similarity Function이라는 스키마 요소로 표준화해서 온톨로지 안에 내장한 것.
- **이어진 질문 — RAG·GraphRAG와의 관계 (같은 날)**: "RAG나 GraphRag랑 관련있는건가? 시멘틱서치."
- **확인된 이해 (근거등급: RAG는 공식 문서로 확인, GraphRAG는 미확인/추정)**:
  - **RAG는 직접 연결**: 03-lead-management의 AIP Logic 캔버스에서 실제로 스쳐 지나갔던 "Start with a template"의 `Retrieval augmented generation (RAG)` 카드(QUERY → ANSWER, "Generate an LLM response based on relevant objects from your Ontology")가 바로 이것. 공식 문서: "Ontology-augmented generation is essentially RAG"이고, 그 Retrieval 단계를 채우는 3가지 방법 중 **Semantic search가 1순위 기본값**(나머지는 Keyword search, 그리고 둘을 RRF로 합친 Hybrid). 즉 **semantic search ⊂ RAG의 검색 단계** — 앞서 정리한 "vector search ⊂ semantic search"에 한 단계 더 얹힘.
  - **GraphRAG는 "구조적으로 가능하지만 공식 확인은 안 됨"**: 공식 문서(Ontology-augmented generation)에 Link(객체 간 관계)를 타고 검색하는 그래프 순회 방식은 언급이 없음 — 벡터/키워드/하이브리드 검색만 문서화돼 있음. 다만 온톨로지 자체가 Object(노드)+Link(엣지) 구조([[의존성 그래프의 두 종류 (설치 순서 vs 데이터 관계)]] 항목의 ERD/그래프 DB와 같은 개념)라 GraphRAG가 필요로 하는 지식그래프 전제는 이미 충족돼 있음. `Ontology → Get linked objects` 같은 블록으로 사람이 직접 Link를 타는 로직을 짜면 사실상 GraphRAG 효과를 낼 수 있으나, 벡터 검색처럼 버튼 하나로 켜지는 기본 제공 기능은 아닌 것으로 보임.
- **이어진 가설 — 만약 GraphRAG를 짠다면 경로도 결정론적일 것 (같은 날)**: "구조적으로는 graphrag를 지원할 수 있겠지만 foundry가 대상과 경로를 정할 때 결정론적인 실행을 우선시 하니까 graphrag도 정의된 path에 대해서만 답을 가져오고 실행할 것 같다는 생각이 들어."
  - **패턴 일치로 뒷받침됨 (근거등급: 추정이지만 이 세션 전체와 일관됨)**: 이 세션에서 반복 확인한 원칙 — [[Function + Action Type 조합 = "구조화 출력 LLM 호출 + 결정적 쓰기" — Skill/Command/하네스가 아니라 n8n·스크립트에 가까움]] 항목의 "① 내용 판단은 LLM, ② 대상/경로 결정은 코드로 고정"과 [[AIP Logic에서 온톨로지 쓰기 — LLM에게 "무엇을 바꿀지"까지 맡기지 말 것]] 항목의 `Apply actions tool` 실패 사례(LLM에게 대상 결정까지 맡기면 존재하지 않는 primaryKey를 지어내며 실패)를 그대로 GraphRAG에 대입한 추론.
  - 즉 만약 Foundry에서 GraphRAG를 짠다면: **"어떤 Link 타입을 몇 홉 탈지"(경로)는 로직 설계자가 미리 고정**하고, LLM은 그렇게 이미 정해진 경로로 가져온 객체들의 **내용만 판단(요약·답변 생성)**하는 구조일 가능성이 높다 — "LLM이 그때그때 어떤 관계를 타고 갈지 스스로 판단"하게 두면 앞서 실패한 패턴(대상 식별자를 LLM이 지어냄)이 그래프 순회 버전으로 재발할 위험이 있기 때문. 아직 실습으로 검증 안 됨 — 나중에 실제로 GraphRAG 스타일 로직을 짜보게 되면 이 가설을 실측으로 확인할 것.
- **가설 보완 — "막혀있다"가 아니라 "깨지니까 안 쓰게 됐다" (같은 날, 사용자 동의로 확정)**: "그러니까 의존성 그래프가 미리 만들어져 있어야 하는거고, 리소스는 graphrag에서 탐색을 할 수 있는것으로 이해했어. graphrag를 통채로 활용하는 개념은 아니고. llm이 개입하면 이부분이 쉽게 되겠지만, foundry에서는 선호하지 않는 방식인 것 같아." → 이 요약을 짚으면서 한 가지 보완함:
  - `Apply actions tool` 자체는 **Foundry가 실제로 제공하는 기능** — "LLM이 스스로 판단해서 도구(Action)를 고르고 호출"하는 에이전틱 패턴이 구조적으로 막혀있는 게 아니라 **지원은 된다.**
  - 다만 02번(Expense Reporting)·03번(Lead Management) 양쪽에서 실측했듯 이 방식은 대상 식별자를 LLM이 지어내며 실패했다.
  - 그래서 **"플랫폼이 구조적으로 못 하게 막는다"가 아니라 "LLM에게 경로 결정을 맡기면 실제로 잘 깨지니까, 신뢰성 있는 설계자들이 자연스럽게 안 쓰게 된다"가 더 정확한 표현**이라는 데 합의함. 즉 하드 제약이 아니라, 신뢰성 문제로 자연 선택된 모범 패턴(best practice) — 기업용 플랫폼 특성상 거버넌스·신뢰성을 우선하는 문화가 이 쏠림을 강화한다고 보는 게 맞을 것으로 정리.
- **근거 실습**: 아직 없음 — Small Business Connector(§1 Stage 4 ⑨) 진행 전 사전 학습. 공식 문서(WebFetch, 2026-08-30): [Semantic search Overview](https://www.palantir.com/docs/foundry/ontology/overview-semantic-search), [Core concepts](https://www.palantir.com/docs/foundry/ontology/core-concepts), [Properties Overview](https://www.palantir.com/docs/foundry/object-link-types/properties-overview), [Ontology-augmented generation](https://www.palantir.com/docs/foundry/ontology/ontology-augmented-generation)
- **관련**: [[온톨로지(Ontology) = DB 스키마 + 앱 3계층의 통합]], [[AIP 프로젝트 기획 프레임 — "의도·목적"에서 시작해 명사·동사·로직·트리거·프론트·배포까지]], [[Function + Action Type 조합 = "구조화 출력 LLM 호출 + 결정적 쓰기" — Skill/Command/하네스가 아니라 n8n·스크립트에 가까움]], [[AIP Logic에서 온톨로지 쓰기 — LLM에게 "무엇을 바꿀지"까지 맡기지 말 것]]

---

## Function + Action Type 조합 = "구조화 출력 LLM 호출 + 결정적 쓰기" — Skill/Command/하네스가 아니라 n8n·스크립트에 가까움

- **내 질문/가설**: `lead-classifier` 함수(LLM 분류+초안 생성)를 `Generate Draft Reply` 액션과 묶어 `Classify Lead & Generate Reply`라는 새 Action을 만들면서, 이게 뭘 닮았는지 순서대로 되물어봄 — "Claude Code의 skill 개념인가?" → "skill과 다르면 command 기능과 같은건가? command는 스크립트 기반으로 결정론적인 처리를 하잖아" → "그럼 하네스랑 비슷한 개념이야? 어떤 실행에 어떤 도구를 쓸지 정해두는 개념이잖아" → "그러면 n8n이나 파이썬 스크립트를 호출하는 개념이랑 비슷한가?"
- **확인된 이해**: 넷 다 실마리는 있었지만, 마지막 비유(n8n/Python 스크립트)가 정확했다.
  - **Skill 아님**: Skill은 로드된 뒤에도 제가(에이전트) 상황 따라 유연하게 판단해서 도구를 고르는 "지침 묶음". 이 파이프라인은 판단 여지가 없는 고정 실행 순서.
  - **Command 아님**: Command도 매 단계 실행을 여전히 LLM이 해석해서 도구 호출을 판단한다(스크립트처럼 보여도 실행 경로엔 LLM 판단이 매번 개입). 반면 `Generate Draft Reply` 쓰기 단계는 LLM이 전혀 관여하지 않는 순수 코드 배선.
  - **하네스와도 다름**: 하네스의 핵심은 "여러 도구를 쥐어주고 그중 뭘 쓸지는 LLM이 판단하게" 하는 **제한된 자유**. `Use LLM` 블록은 도구가 아예 없고(Tools 비워둠), 한 번만 호출되며, 출력이 Struct 스키마로 강제된다 — 자율성이 사실상 0. "도구를 미리 정해둔다"는 정신은 같지만, 하네스가 노리는 자율성 스펙트럼의 정반대 극단.
  - **n8n/Python 스크립트가 정확한 비유**: 구조가 1:1로 대응된다.
    - `Use LLM`(고정 프롬프트 + Struct 출력) = n8n의 LLM 노드 + Structured Output Parser 노드, 또는 `response = call_llm(prompt)` 후 pydantic으로 파싱
    - `Generate Draft Reply`(LLM 출력 필드를 결정적으로 배선) = n8n의 다음 노드(HTTP Request/DB Update 노드)가 이전 노드의 JSON을 그대로 받아씀, 또는 `db.update(id, response.field1, response.field2)`
    - `lead-classifier` 함수 전체 = n8n 워크플로우 전체 / 스크립트 함수 하나
    - Preview run = n8n의 테스트 실행(dry run)
    - Publish + Create Action = 워크플로우를 Webhook/버튼으로 실제 배포
  - **Foundry가 얹은 유일한 차이는 거버넌스 레이어**: 로직 구조 자체는 n8n/스크립트와 완전히 같고, Foundry가 추가로 주는 건 Action Type의 **Submission criteria**(누가 실행 가능), **Rules**(어떤 필드만 바꿀 수 있는지), 실행 이력이 온톨로지에 남는 감사로그다. n8n·스크립트로 똑같이 하려면 이 권한·감사 체계를 직접 구현해야 한다.
- **재질문으로 정정 (같은 날)**: "lead type을 판단하거나 draftReply를 쓸 때는 LLM이 개입하잖아. 너는 의사결정 측면에서 LLM 판단의 개입을 없애고 결정론적으로 처리한다는 것을 차별점으로 강조하고 싶은거야?" — "결정론적"이라는 표현이 부정확했다는 걸 스스로 짚어낸 질문. 판단이 **두 층위**로 나뉜다는 걸로 정정:

  | 층위 | 예시 | 누가 결정하나 |
  |---|---|---|
  | ① 내용 판단 (WHAT) | "이 문의가 가격문의인가 기술문의인가", "초안 문장을 어떻게 쓸까" | LLM이 그대로 판단 — 전혀 안 없어짐 |
  | ② 대상/경로 결정 (WHERE) | "어떤 Lead 객체에 쓸 것인가", "어떤 필드에 쓸 것인가", "어떤 Action을 호출할 것인가" | 설계 시점에 코드로 고정 — LLM이 관여 안 함 |

  "결정론적"이라고 강조했던 건 ②번(대상/경로)뿐이었고, ①번(분류·문장 생성)은 이 파이프라인의 존재 이유 자체라 LLM이 그대로 판단한다. 즉 핵심은 "LLM 판단을 없앤다"가 아니라 **"판단(내용)과 결정(대상)을 분리해서, 결정 쪽만 코드로 고정한다"** — [[AIP Logic에서 온톨로지 쓰기 — LLM에게 "무엇을 바꿀지"까지 맡기지 말 것]] 항목의 `Apply actions tool` 실패 사례(대상 식별자를 LLM이 지어내다 실패)가 바로 ①②를 분리 안 해서 난 문제였다는 걸 이 재질문으로 더 명확히 알게 됨.
- **한 번 더 재질문으로 정정 (같은 날)**: "inquiryType이 확률로 바뀐다는건 기준이 없다는거네." — 또 한 번 스스로 짚어낸 오해. 정정: **기준(가격문의/기술문의/파트너십/기타 4개 카테고리)은 System prompt에 명시적으로 있었다.** 같은 입력(James)에 결과가 달랐던 건 (1) 입력 자체가 경계 사례(데모 요청 = 기술문의로도 기타로도 그럴듯함)였고 (2) LLM 생성은 태생적으로 확률적 샘플링이라 같은 프롬프트+입력이라도 재실행마다 다를 수 있기 때문 — **"기준이 없다"가 아니라 "기준을 적용하는 추론 과정이 결정론적이지 않다"**가 정확하다. 이 변동성을 계측 가능하게 관리하는 게 `ROADMAP.md` Stage 3 `Feedback Loop with AIP Evals`의 목적과 직결된다.
- **실측으로 반증됨**: 두 번째 샘플 `Leonardo`(문의내용: "솔루션도입을 위한 파트너십을 논의하고 싶어요")에 같은 Action을 실행하니 `inquiryType: 파트너십`으로 흔들림 없이 정확히 분류됐다. James의 애매한 입력("데모요청")은 기술문의/기타로 왔다갔다했지만, Leonardo처럼 카테고리에 명확히 들어맞는 입력은 안 흔들렸다 — 변동의 원인이 "기준 부재"가 아니라 "입력의 모호함 + 생성 과정의 확률성"이라는 게 실측으로도 뒷받침됨.

---

## 배포(Deploy)의 두 층위 — 기능 배포(Action) vs 제품 배포(Workshop), Google Apps Script 비유

- **내 질문/가설**: "아까 함수를 action으로 만들어서 사용자가 실행할 수 있는 진입점을 만들었고, 그 다음에 workshop을 만들어서 실행버튼을 만들었잖아. 사용자 진입점 action을 만드는것까지는 배포가 아닌거야? workshop이 대시보드 배포한 개념인거야?" 이어서: "지금 실행한 CTA 기능은 구글시트에서 구글앱스스크립트로 자동 실행되게 한 개념이랑 비슷한것 같아."
- **확인된 이해**: Action 생성 시점에 이미 배포가 끝나있었다 — Workshop을 만들기 **전에** Object Explorer에서 James·Leonardo에게 `Classify Lead & Generate Reply`를 실제로 실행했다는 게 증거. 배포에는 두 층위가 있다:

  | 층위 | 언제 완료됨 | 비유 |
  |---|---|---|
  | ① 기능 자체의 배포(가용성) | `Publish`(함수 확정) + `Create Action`(진입점 생성) | 백엔드 API가 살아서 호출 가능해진 것 — Postman이나 curl로도 부를 수 있는 상태 |
  | ② 제품 경험의 배포(UX) | Workshop 모듈 제작·Save and publish | 그 API 위에 얹은 전용 프론트엔드/대시보드 — 일반 사용자가 Object Explorer 탐색법을 몰라도 되게 만든 것 |

  Object Explorer는 "누구나 쓸 수 있는 범용 데이터 브라우저"였고, Workshop은 그 위에 이 업무 전용으로 다듬어진 화면을 얹은 것 — **"Workshop = 대시보드/제품 배포"라는 이해가 정확**하다. 다만 Workshop이 대시보드만 만드는 도구는 아니고(양식·워크플로우 앱도 만듦), 이번 경우엔 딱 그 역할(리드 목록+실행 버튼)을 한 것뿐.

  **Google Apps Script CTA 비유도 정확**: Google Sheets에 버튼(도형) 하나 넣고 Apps Script 함수를 연결해서, 클릭하면 현재 선택된 행/셀 데이터를 기준으로 스크립트가 실행되는 구조 — 이번 CTA 버튼과 메커니즘이 거의 1:1이다.

  | Google Sheets + Apps Script | Foundry |
  |---|---|
  | 시트에 그린 버튼 | Workshop의 `Call-To-Action Button` |
  | 버튼에 연결된 함수 | `Classify Lead & Generate Reply` Action |
  | "현재 활성 셀/행"을 기준으로 스크립트 실행 | `Lead` 파라미터를 `Active Lead`(선택된 행)에 바인딩 |
  | 클릭 → 스크립트 실행 → 시트 데이터 갱신 | 클릭 → Action 실행 → 온톨로지 데이터 갱신 |

  **한 가지 차이**: Apps Script의 함수는 보통 그 시트에 종속돼서, 다른 시트나 웹앱에서 재사용하려면 따로 복사/재연결해야 한다. Foundry의 `Action Type`은 독립된 자원이라 Object Explorer·Workshop·OSDK(코드)·Automate 어디서든 같은 걸 재사용할 수 있고, 권한·감사 로그도 그 자원 하나에 공통으로 걸린다 — Apps Script로 치면 "여러 시트가 공유해서 쓰는, 중앙에서 권한 관리되는 함수 라이브러리"에 가깝다.
- **이어진 질문 — 공동 사용은 어떻게 배포하나 (같은 날)**: "배포(Workshop) 개념은 공동으로 사용하려면 어떻게 해야돼? SHARE LINK가 만들어질 수 있는거야?" → "anyone에게 배포하겠다는게 아니고, 기업내 다른 사람에게 어떻게 공유할 수 있는지 물어본거야." → "share를 누르기 전에. 배포 대상은 함수야 action이야?"
- **확인된 이해 (실측, 근거등급: 실측 — `Lead Inbox` 모듈에서 직접 `Share` 눌러봄)**:
  - 공유 대상은 함수(`lead-classifier`)도 Action(`Classify Lead & Generate Reply`)도 아니라 **Workshop 모듈(`Lead Inbox`) 자체** — 함수·Action은 사용자가 직접 열어볼 화면이 아니라 그 뒤의 내부 부품이기 때문. Vercel 비유로는 "GitHub 리포를 공유하는 게 아니라 배포된 웹사이트 URL을 공유하는 것"과 같은 구도.
  - `Lead Inbox`에서 `Share`(정확히는 `Access` 탭) 클릭 → **"Roles for this file are managed at the project level. Navigate to the containing project to manage roles."**라는 안내와 함께, 이 화면 자체엔 개별 파일 단위의 초대 기능이 없었다. 즉 **Workshop 모듈 개별로는 권한을 따로 안 주고, `03-lead-management` 프로젝트 전체 단위에서 멤버/역할을 관리**한다.
  - **Vercel/Apps Script와의 결정적 차이**: Vercel은 "이 배포"만 골라서 공개하고, Apps Script도 "이 웹앱"만 공유 대상을 정할 수 있다(파일 단위 공유). Foundry는 **프로젝트가 최소 공유 단위**다 — 프로젝트에 멤버를 초대하면 그 안의 Workshop 모듈뿐 아니라 Ontology·Action·Function 등 관련 리소스 전체에 접근 권한이 걸린다(단, 온톨로지 객체 자체는 `Security` 탭에서 더 세밀하게 별도 조정 가능 — `Action Type` 항목 참고). "URL만 공유하면 그 화면만 보이는" Apps Script/Vercel식 세밀한 개별 공유가 아니라 **프로젝트 멤버십 기반 공유**라는 게 이번 실측으로 확정됨.
  - 공유 링크도 "URL만 알면 로그인 없이 누구나"가 아니라, **프로젝트 멤버로 초대된 사람이 자기 Foundry 계정으로 로그인해야 접근 가능**한 구조로 보인다(기업용 플랫폼 기본값).
- **미해결로 남긴 지점 (근거등급: 미확인)**: "그럼 아까 화면에서는 share 버튼이 왜있는거지"라는 재질문에 끝까지 답을 못 찾았다. `Lead Inbox`의 `Share` → `Access` 탭은 접근 조건을 **보여주기만**(Requirements/Check access/Settings) 했고, "여기서 새 멤버를 초대"하는 버튼을 못 찾았다. 프로젝트 좌측 사이드바의 `Access graph`는 [[의존성 그래프의 두 종류 (설치 순서 vs 데이터 관계)]] 항목의 "설치/구조 그래프" 도구였지, 멤버 관리 화면이 아니었다(오탐 — 이름만 보고 잘못 짚음). **실제 "동료를 프로젝트 멤버로 초대하는" UI가 어디 있는지는 이번 세션에서 못 찾았고, 조직 관리자 권한이 별도로 필요한 영역일 가능성도 있다.** 다음에 이 주제를 다시 다룰 땐 프로젝트 폴더 우클릭 메뉴, 또는 프로젝트명 옆 톱니바퀴 아이콘부터 확인해볼 것.
- **근거 실습**: 03-lead-management Phase 5 (2026-08-30, Workshop `Lead Inbox` 모듈 제작 중 대화 + `Share`/`Access` 탭 직접 클릭)
- **관련**: [[Function + Action Type 조합 = "구조화 출력 LLM 호출 + 결정적 쓰기" — Skill/Command/하네스가 아니라 n8n·스크립트에 가까움]], [[기존 자동화(스크립트·n8n) ↔ Foundry 대응]], [[AIP 프로젝트 기획 프레임 — "의도·목적"에서 시작해 명사·동사·로직·트리거·프론트·배포까지]]
- **근거 실습**: 03-lead-management Phase 3~4 (2026-08-30, `lead-classifier` 함수 + `Classify Lead & Generate Reply` Action 제작 중 대화)
- **관련**: [[AIP Logic에서 온톨로지 쓰기 — LLM에게 "무엇을 바꿀지"까지 맡기지 말 것]], [[기존 자동화(스크립트·n8n) ↔ Foundry 대응]]
