# Lead 자동 회신 초안 시스템 — 직접 설계 실습 계획서

> **문서 위치**: 이 파일은 실습 프로젝트(`D:\OneDrive\Cursorhome\aip-practice\03-lead-management`)의 정본 계획서입니다.
> **이 실습엔 원본 레포가 없습니다.** 01·02번과 달리 `aip-community-registry`의 완성된 패키지를 설치·관찰하는 게 아니라, **패키지 없이 온톨로지를 처음부터 직접 설계**하는 실습입니다(`ROADMAP.md` §0.5의 3번).
> 공통 규칙(토큰 취급, conda 명명, Foundry 제약, 학습목표 표기 의무)은 상위 `aip-practice/CLAUDE.md`에 있고 자동 상속됩니다.

## 학습목표

> 이 실습 = **패키지 없이 Ontology Manager에서 객체 타입·속성·Action Type을 처음부터 직접 설계**하고, 방금 AIP Logic Getting Started에서 익힌 패턴(LLM은 판단만, 대상 객체는 결정적으로 고정)을 재사용해 실제 쓰기까지 완주하는 것 하나만 익히는 것.

01·02번이 "이미 완성된 온톨로지를 설치해서 관찰"하는 실습이었다면, 이번은 처음으로 **빈 화면에서 명사(Object Type)부터 직접 고르는** 실습입니다. `ROADMAP.md` §0.5(Palantir 지원 준비용 압축 트랙)의 3번.

---

## 현재 상태 (2026-08-30)

| Phase | 상태 |
|---|---|
| **Phase 0 — 의도·목적 확정** | ✅ 완료 (아래 Context 참고) |
| **Phase 1 — Object Type `Lead` 설계** | ✅ 완료 (2026-08-30) |
| **Phase 2 — Action Type 설계 (`Create Lead`, `Generate Draft Reply`)** | ✅ 완료 (2026-08-30) |
| **Phase 3 — AIP Logic 함수 작성·Publish** | ✅ 완료 (2026-08-30) |
| **Phase 4 — 샘플 데이터로 end-to-end 검증** | ✅ 완료 (2026-08-30) |
| **Phase 5 — Workshop 화면 (선택)** | ✅ 완료 (2026-08-30) |

---

## Context

### 실제 업무 배경
홈페이지로 들어오는 리드(lead) 문의에, 담당자가 확인하기 전에 자동으로 이메일 회신을 보내는 워크플로우를 실제로 운영 중(n8n 기반으로 추정). 이번 실습은 그 실제 사례를 온톨로지로 옮겨보는 것.

### 이번 실습의 스코프 결정 — "여러 도구 의존성 없이 간단하게"
사용자 요청에 따라, **실제 이메일 발송(SMTP/이메일 커넥터 연동)은 이번 스코프에서 제외**합니다. 이유:
- 실제 발송까지 가면 Compute Module이나 Automate의 이메일 커넥터 같은 Stage 2~3 도구가 추가로 필요해져, "직접 설계" 학습목표와 무관한 복잡도가 늘어남
- 이번 실습의 핵심은 "온톨로지를 처음부터 설계하는 감각"이지 "완성된 리드 관리 시스템을 만드는 것"이 아님

대신 **"자동 회신 초안을 만들어서 객체에 저장해두는 것"까지만** 합니다 — 사람이 최종 검토 후 발송하는 human-in-the-loop 구조. 이건 02번(Expense Reporting)에서 실측 확인한 "Action Type은 호출 주체를 안 가린다"([[Action Type]], `../GLOSSARY.md`)는 개념과도, 방금 AIP Logic 실습에서 만든 "LLM은 판단만, 대상 객체는 결정적으로 고정" 패턴과도 그대로 이어집니다.

**데이터 입력도 실제 홈페이지 폼 연동 없이, Ontology Manager/Object Explorer에서 직접 예제 리드 몇 건을 입력**합니다 — 웹훅·폼 연동은 범위 밖(나중에 Push-Based Events 실습, `../ROADMAP.md` Stage 2 ⑥에서 다룰 영역).

### 기획 프레임 (0~8, `../ROADMAP.md` §2)

| # | 항목 | 이번 실습 결정 |
|---|---|---|
| 0. 의도·목적 | 담당자가 리드를 확인하기 전에 AI가 답장 초안을 미리 만들어둬서 응답 속도를 높인다 (사람이 최종 검토 후 발송) |
| 1. 명사 | `Lead` 객체 타입 하나만. Link(다른 객체 연결)는 이번엔 생략 — 단일 객체로 먼저 완주 |
| 2. 저장 | 실제 폼 연동 없이 Ontology Manager/Object Explorer에서 직접 예제 데이터 입력 |
| 4. 동사 | `Create Lead`(수동 생성), `Generate Draft Reply`(AIP Logic 호출해서 분류+초안 갱신) |
| 5~6. 로직/LLM | AIP Logic: 문의 내용 읽고 (a) 문의 유형 분류 (b) 답장 초안 텍스트 생성 → Action으로 `Lead`에 써넣기 |
| 7. 트리거 | 생략 — 사람이 버튼 눌러 수동 실행 |
| 8. 프론트 | 선택 — 시간 되면 Workshop으로 리드 목록 + "초안 생성" 버튼 |

### `Lead` 객체 스키마 (확정)

| 속성 | 타입 | 비고 |
|---|---|---|
| Primary Key | (자동) | |
| 문의자명 | String | |
| 이메일 | String | |
| 문의내용 | String | 원문 |
| 문의유형 | String | LLM이 분류 (가격문의/기술문의/파트너십/기타 등 — 실제 카테고리는 진행하며 조정 가능) |
| 상태 | String | 신규 / 초안생성됨 / 발송완료 / 보류 |
| 자동회신초안 | String | LLM이 생성 |
| 문의일시 | Date/Timestamp | |

---

## 실습 폴더

```
D:\OneDrive\Cursorhome\aip-practice\
└── 03-lead-management\                  ← 이 실습
    ├── PLAN.md                          # 이 문서 — 정본 계획서
    └── NOTES.md                         # 진행 체크리스트 + 채워넣을 정보표 + 함정
```

원본 레포 없음(직접 설계). 엔롤먼트 공통값은 상위 `_shared\.env` 상속. Foundry 프로젝트는 이 폴더와 이름을 맞춰 `03-lead-management`로 새로 생성.

---

## Phase 1 — Object Type `Lead` 설계

1. **Ontology Manager** → 새 Object Type 생성 (Object types → `+ New` 또는 유사 진입점)
2. 위 스키마 표대로 속성 8개 추가 — Primary Key는 자동 생성 방식 선택(예: UUID 또는 순번), 나머지는 String/Date 타입으로
3. Plural name, Description 등 메타데이터 채우기
4. Save → Object Explorer에서 빈 객체 타입이 실제로 보이는지 확인

**02번에서 재사용할 감각**: `Expense` 객체 스키마 볼 때 익힌 "속성 하나하나가 실제로 무슨 역할인지" 판단하는 눈. 이번엔 그걸 직접 만들어보는 차례.

---

## Phase 2 — Action Type 설계

### `Create Lead` (수동 생성용)
- Object actions → **Create object** 선택 → `Lead` 대상 → 속성 대부분을 파라미터로 노출(자동회신초안·문의유형·상태는 생성 시점엔 빈 값/기본값 "신규"로 두고 나중에 Action 2로 채움)

### `Generate Draft Reply` (AIP Logic 호출용)
- Object actions → **Modify object(s)** 선택 → `Lead` 대상
- 수정 가능 속성: `문의유형`, `자동회신초안`, `상태`(→"초안생성됨")
- **AIP Logic Getting Started에서 실측한 함정 그대로 재적용**: 이 Action은 나중에 AIP Logic의 `Use LLM` 블록이 직접 호출(Apply actions tool)하게 하지 말고, **Ontology "Action" 블록으로 별도 분리**해서 대상 `Lead` 객체는 입력 변수로 결정적으로 바인딩하고, LLM 출력(문의유형·초안 텍스트)만 파라미터로 연결한다 (`../GLOSSARY.md` "AIP Logic에서 온톨로지 쓰기" 항목 참고).

---

## Phase 3 — AIP Logic 함수 작성

1. AIP Logic → 새 함수 생성 (프로젝트: `03-lead-management`), 이름 예: `lead-classifier`
2. Input: `lead`(Object: Lead)
3. `Use LLM` 블록: System prompt에 "문의 내용을 보고 (1) 문의유형 분류 (2) 정중한 답장 초안 작성"을 지시, Task prompt에 `lead.문의내용` 등 필요한 속성 삽입
   - Output 구조화 여부 검토: 문의유형+초안을 한 번에 받으려면 Structured output mode(예: JSON 형태로 두 필드 동시 출력)를 써볼 만함 — 02번 실습에선 String 하나만 다뤘으니 이번엔 확장 포인트
4. `Ontology → Action` 블록 추가: `Generate Draft Reply` 실행, `Lead` 파라미터는 Input `lead`에 고정, `문의유형`/`자동회신초안`은 LLM 출력에서 연결
5. Output 타입: `Ontology edits`
6. Preview run으로 검증 → Publish

---

## Phase 4 — 샘플 데이터로 end-to-end 검증

1. Object Explorer(또는 `Create Lead` Action)로 예제 리드 2~3건 직접 입력 (문의내용은 실제 업무에서 받는 문의 톤으로)
2. 각 리드에 대해 `Generate Draft Reply` Action 실제 실행 (Preview 아니라 진짜 실행)
3. Object Explorer에서 `문의유형`·`자동회신초안`·`상태`가 실제로 채워졌는지 확인
4. (선택) 초안 내용이 실제로 쓸 만한 톤인지 검토 → 프롬프트 튜닝

---

## Phase 5 — Workshop 화면 (선택)

시간 되면 리드 목록 + "초안 생성" 버튼이 있는 간단한 Workshop 앱을 얹어, 02번에서 본 "Expense Portal" 패턴을 스스로 재현해본다.

---

## 검증 (end-to-end)

1. `Lead` Object Type이 Ontology Manager에 존재, 속성 8개 정의됨
2. `Create Lead`·`Generate Draft Reply` Action Type 존재, 규칙이 스키마와 일치
3. `lead-classifier` Logic 함수 Publish 완료
4. 샘플 리드 최소 1건에서 `Generate Draft Reply` 실제 실행 → `자동회신초안`이 빈 값에서 실제 텍스트로 바뀌는 것 확인

**최종 성공 기준**: "의도·목적 → 명사 → 동사 → 로직 → (트리거/프론트)" 순서로 처음부터 끝까지 스스로 판단해서 만든 온톨로지가, 실제로 샘플 데이터에 대해 동작하는 것.

---

## 참고 자료

- 상위 로드맵: `../ROADMAP.md` §0.5(압축 트랙 3번), §2(기획 프레임)
- 개념 노트(누적): `../GLOSSARY.md` — 특히 "AIP Logic에서 온톨로지 쓰기", "Ontology Manager vs Object Explorer" 항목
- 직전 실습(AIP Logic Getting Started) 진행 로그: `../02-expense-reporting/NOTES.md`
