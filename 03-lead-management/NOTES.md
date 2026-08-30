# Lead 자동 회신 초안 시스템 — 실습 노트

> **학습목표**: 패키지 없이 Ontology Manager에서 객체 타입·속성·Action Type을 처음부터 직접 설계하고, AIP Logic Getting Started에서 익힌 패턴(LLM은 판단만, 대상 객체는 결정적으로 고정)을 재사용해 실제 쓰기까지 완주하는 것.

원본 없음 — 이 실습은 실제 업무(홈페이지 리드 문의 자동 회신 워크플로우)를 온톨로지로 옮겨보는 직접 설계 실습입니다. 상세 계획은 `PLAN.md` 참고. 헷갈리면 `../ROADMAP.md` §0.5(압축 트랙), `../GLOSSARY.md`(개념)를 참고하세요. 이 문서는 이 실습 고유 정보만 담습니다.

**개념 기록 규칙**: 새로 확인한 개념은 이 파일이 아니라 `../GLOSSARY.md`에 "내 질문/가설 → 확인된 이해" 형식으로 추가합니다. 이 파일은 진행 체크리스트·환경정보·이 실습 고유 함정만 담습니다.

---

## 내 환경 정보 (채워넣기)

| 항목 | 값 |
|---|---|
| Enrollment URL | `_shared/.env` 상속 (`https://dataartai.usw-23.palantirfoundry.com`) |
| 이번 실습 Foundry 프로젝트 | `03-lead-management` (Object type 생성 마법사의 Location 선택 창 → "+ Create new project"로 생성) |
| `Lead` Object Type API name | `Lead` (속성 API name: contactName·email·inquiryContent·inquiryType·status·draftReply·inquiredAt, PK 자동) |
| `lead-classifier` Logic 함수 버전 | v1.0.0 (Publish 완료) |
| `Classify Lead & Generate Reply` Action | API name `classify-lead-generate-reply`, Input: Lead, Rules: Run lead-classifier |
| 실제 사용한 문의유형 카테고리 | 가격문의 / 기술문의 / 파트너십 / 기타 (4개, System prompt에 명시) |

---

## 진행 체크리스트

### Phase 0 — 의도·목적 확정 ✅ 완료
- [x] 스코프 확정: 실제 이메일 발송 제외, "초안 생성 후 객체에 저장"까지만 (`PLAN.md` Context 참고)
- [x] `Lead` 스키마 8개 속성 확정

### Phase 1 — Object Type `Lead` 설계 ✅ 완료
- [x] Ontology Manager에서 새 Object Type `Lead` 생성 (프로젝트 `03-lead-management` 새로 생성 — Location 선택 창 맨 아래 "+ Create new project" 링크로 찾음, 홈 화면엔 프로젝트 생성 버튼이 안 보였음)
- [x] 속성 8개 추가 (Primary Key, contactName, email, inquiryContent, inquiryType, status, draftReply, inquiredAt/Timestamp). Title은 contactName으로 지정(Primary Key는 UUID라 사람이 못 알아봄 — Title은 고유할 필요 없이 표시용이라 문제없음)
- [x] Save → Ontology Manager Overview에서 속성 8개·Action types 1개(Create Lead) 확인. Object Explorer 검색은 초기 인덱싱 중이라 즉시 안 뜰 수 있음(정상)

### Phase 2 — Action Type 설계 ✅ 완료
- [x] `Create Lead` (Create object 타입) — Object type 생성 마법사 Step 4에서 자동 생성됨 (Modify Lead·Delete Lead는 스코프 밖이라 체크 해제하고 생성 안 함)
- [x] `Generate Draft Reply` (Modify object(s) 타입, API name `generate-draft-reply`) 생성 — Input: `Lead`(대상 객체 고정) + `inquiryType`·`draftReply`·`status`(수정 파라미터). contactName·email·inquiryContent·inquiredAt은 매핑에서 제외해 수정 불가하게 좁힘

### Phase 3 — AIP Logic 함수 ✅ 완료
- [x] `lead-classifier` Logic 함수 생성 (Input: Object Lead, 변수명 `lead`), 프로젝트 `03-lead-management`
- [x] `Use LLM` 블록 — System prompt에 문의유형 3분류(가격문의/기술문의/파트너십/기타) 기준 명시 + 초안 작성 지시. Output을 `Struct{inquiryType: String, draftReply: String}`로 구조화(Structured output mode: Prompt only)
- [x] `Ontology → Action` 블록 — `Generate Draft Reply` 실행, `Lead`는 Input `lead`에 결정적으로 바인딩, `inquiryType`·`draftReply`는 `Use LLM`의 Struct 출력에 연결, `status`는 고정 문자열 `"초안생성됨"`
- [x] Preview run 검증(James로 테스트, 정상 확인) → Publish (v1.0.0)
- [x] Publish 후 `Create Action`으로 `Classify Lead & Generate Reply` Action type 생성 — 함수를 사람이 누를 수 있는 진입점으로 노출(Input: Lead, Rules: Run lead-classifier)

### Phase 4 — end-to-end 검증 ✅ 완료
- [x] 샘플 리드 2건 입력 — `James`(문의: "솔루션도입 검토를 위한 데모요청", 경계 사례) / `Leonardo`(문의: "솔루션도입을 위한 파트너십을 논의하고 싶어요", 명확한 사례)
- [x] `Classify Lead & Generate Reply` Action 실제 실행 (Object Explorer → 각 리드 → Actions, Preview/Test run 아닌 진짜 실행)
- [x] Object Explorer에서 실제 반영 확인 — James: `inquiryType 기타`, Leonardo: `inquiryType 파트너십`(정확). 둘 다 `draftReply` 실제 문장, `status: 초안생성됨`으로 "Edits successfully applied" 배너 확정
- [x] (부가 관찰) 애매한 입력(James)은 분류가 흔들리고, 명확한 입력(Leonardo)은 안 흔들림 — `GLOSSARY.md`에 기록

### Phase 5 — Workshop 화면 (선택) ✅ 완료
- [x] 리드 목록 + "초안 생성" 버튼 Workshop 앱 — `Lead Inbox` 모듈(`Inbox template` 기반), `Object Table` + 상세 패널 자동 생성. `Call-To-Action Button`(라벨 "초안 생성")의 On click을 `Classify Lead & Generate Reply` Action에 연결, `Lead` 파라미터는 Object Table의 "Active Lead"(선택된 객체) 변수에 바인딩 + Visibility Hidden(폼 안 뜨고 바로 실행). `View` 모드에서 Leonardo에 실제 실행해 정상 동작 확인(Object Explorer와 동일한 데이터에 씀 — 별도 저장소 아님)

---

## 함정 (미리 알아둘 것 — 직전 실습에서 이어지는 것)

1. **LLM에 Apply actions tool을 직접 쥐어주지 말 것.** AIP Logic Getting Started에서 실측: LLM 블록에 `Apply actions tool`을 추가하고 대상 객체를 프롬프트 속성으로만 노출하면, LLM이 객체의 실제 식별자(primaryKey)를 몰라 `"null"`을 지어내 Action 호출이 실패한다. **`Ontology → Action` 블록을 별도로 추가해 대상 객체는 Input 변수에 결정적으로 바인딩**하고, LLM은 판단이 필요한 값(문의유형·초안 텍스트)만 만들게 분리할 것. 상세: `../GLOSSARY.md` "AIP Logic에서 온톨로지 쓰기".
2. **Preview run은 실제 데이터를 안 바꾼다.** Publish → Action Type 생성 → 실제 실행까지 가야 진짜 반영됨. `../GLOSSARY.md` "Preview run ≠ 실제 반영" 참고.
3. **Ontology Manager(설계)와 Object Explorer(데이터)는 다른 화면이다.** 스키마를 고칠 땐 Ontology Manager, 실제 값을 넣고 확인할 땐 Object Explorer. `../GLOSSARY.md` "Ontology Manager vs Object Explorer" 참고.
4. **실제 이메일 발송은 이번 스코프 밖.** 초안 생성까지만 하고, 발송은 사람이 수동으로 한다고 가정(human-in-the-loop). 나중에 진짜 자동 발송이 필요해지면 Automate + 이메일 커넥터가 필요한 별도 실습(`../ROADMAP.md` Stage 2~3)으로 넘어갈 것.

---

## 진행 로그

- 2026-08-30: `03-lead-management` 폴더 생성, PLAN.md·NOTES.md 작성. 실제 업무(홈페이지 리드 문의 자동 회신)를 소재로 스코프를 "초안 생성까지"로 확정하고 `Lead` 스키마 8개 속성 확정. Phase 1(Ontology Manager에서 Object Type 생성) 대기 중.
- 2026-08-30: Phase 1~4 전부 완주. `Lead` Object type(속성 8개) 직접 설계 → `Create Lead`·`Generate Draft Reply` Action type 설계(후자는 3개 속성만 수정 가능하게 좁힘) → `lead-classifier` AIP Logic 함수 작성(Use LLM Struct 출력 + Ontology Action 블록 결정적 바인딩) → Publish → `Create Action`으로 `Classify Lead & Generate Reply` 생성 → 샘플 리드 2건(James·Leonardo)에 실제 실행까지 확인. 실측 함정: Ontology Manager 안의 모든 Preview/Test run 화면은 실제 데이터를 절대 안 바꿈(설계 검증용) — 실제 반영은 항상 Object Explorer/Workshop에서 실행해야 함. 대화 중 나온 "이 구조가 Claude Code의 Skill/Command/하네스 중 뭐랑 비슷한가"라는 질문은 결국 "n8n 워크플로우·Python 스크립트에 거버넌스(권한·감사)를 얹은 것"이라는 결론으로 `GLOSSARY.md`에 정리. Phase 5(Workshop, 선택)만 남음.
