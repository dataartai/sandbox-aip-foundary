# Expense Reporting 실습 노트

> **학습목표**: 온톨로지 위에서 Action(쓰기)·Function(AIP Logic)·Workshop(화면)이 하나의 업무 흐름으로 엮이는 실제 사례를 뜯어보고, Ontology Manager에서 Action Type을 직접 편집해보는 것.

원본: [aip-community-registry / Expense Reporting](https://github.com/palantir/aip-community-registry/tree/develop/Expense%20Reporting)

마켓플레이스·DevOps·Ontology Manager 등 **앱 사용법 자체는 01번에서 이미 익혔습니다** — 헷갈리면 `../01-osdk-hello-world/NOTES.md`의 "이번 실습에서 쓴 앱" 표를 먼저 참고하세요. 이 문서는 02번 고유 정보만 담습니다.

---

## 내 환경 정보 (채워넣기)

| 항목 | 값 |
|---|---|
| Enrollment URL | `_shared/.env` 상속 (`https://dataartai.usw-23.palantirfoundry.com`) |
| 마켓플레이스 스토어 | `aip-practice-store` 재사용 (01번에서 만든 것 그대로) |
| 이번 실습 Foundry 프로젝트 (설치 산출물) | |
| 설치한 제품 버전 | |
| Action Type 편집 완료 여부 (Phase 2) | |
| Phase 4에서 고른 확장 항목 | |

---

## 진행 체크리스트

### 사전 점검 ✅ 완료
- [x] zip 로컬 스캔 — `THIRD_PARTY_APPLICATION` 없음 확인 (`ROADMAP.md` 전체 스캔 표 참고)

### Phase 1 — 마켓플레이스 업로드·설치
- [ ] DevOps → `aip-practice-store` → Upload to store → `expense_reporting.zip`
- [ ] 이 실습 전용 Foundry 프로젝트 생성(Sandbox)
- [ ] Marketplace → Create new installations → 그 프로젝트 지정
- [ ] Content Review → Validation → **Install 버튼 활성화 확인** → Install
- [ ] 설치 확인: Ontology Manager에 `Expense`·`Project` 객체 타입 존재

### Phase 2 — Action Type 편집
- [ ] Ontology Manager → Action Types → `Create Expense`
- [ ] Rules에 `Receipt Attachment (PDF)`·`Receipt Image` 추가 → Save

### Phase 3 — 개념 탐구
- [ ] `Expense`/`Project` 객체 타입 구조 확인
- [ ] `Expense`에 연결된 Action Types 전체 확인
- [ ] Workshop 승인 앱 열어서 Action 연결 확인
- [ ] AIP Logic/Function에서 자동 승인 에이전트 확인
- [ ] Automate 트리거 확인(있다면)

### Phase 4 — 확장 연습 (선택)
- [ ] 항목 1개 선택해서 실제로 편집·저장

---

## 함정 (미리 알아둘 것)

1. **로컬 Python 환경이 기본적으로 필요 없습니다.** 이 실습은 전부 웹 콘솔 작업입니다. Phase 4에서 OSDK로 확장하기로 하면 그때 `conda create -n aip-expense-reporting ...` 로 새 env를 만드세요(01의 `osdk-hello`는 상위 규칙 확정 전이라 예외였을 뿐, 새 실습은 `aip-<슬러그>` 규칙을 따릅니다).
2. **Action Type 편집(Phase 2)을 건너뛰지 마세요.** README가 명시한 필수 단계이며, 안 하면 영수증 첨부가 액션에 반영되지 않습니다.
3. **`Project` 객체가 비어 보이는 건 의도된 것입니다.** README가 "PK+Title뿐인 notional object, 직접 확장해서 쓰라"고 명시했습니다. 버그가 아닙니다.
4. **01번에서 겪은 함정 중 여전히 유효한 것**: 원본 레포에 커밋 금지, 토큰 하드코딩 금지(Phase 4에서 OSDK 쓸 경우), Foundry 프로젝트는 중첩 안 됨.

---

## 진행 로그

- 2026-08-30: `02-expense-reporting` 폴더 생성, PLAN.md·NOTES.md 작성. README 실측 완료(핵심 흐름·필수 편집 단계·확장 여지 3가지 파악). zip 사전 스캔에서 `THIRD_PARTY_APPLICATION` 없음 확인(ROADMAP.md 전체 스캔의 일부). Phase 1(마켓플레이스 업로드) 대기 중.
