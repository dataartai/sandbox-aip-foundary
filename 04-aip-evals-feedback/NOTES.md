# Feedback Loop with AIP Evals 실습 노트

> **학습목표**: 사용자 피드백이 온톨로지에 쌓이고 AIP Evals 평가 스위트에 동적으로 반영되는 검증·피드백 루프를 구축해, LLM 출력 품질을 "눈으로 판단"에서 "계측 가능한 루프"로 바꾸는 것.

원본: [aip-community-registry / Feedback Loop with AIP Evals](https://github.com/palantir/aip-community-registry/tree/develop/Feedback%20Loop%20with%20AIP%20Evals)

마켓플레이스 설치 흐름(검색→Create new installations→Inputs/Outputs 검토→Install)은 `02-expense-reporting`에서 이미 한 번 완주한 절차와 동일합니다 — 헷갈리면 `../02-expense-reporting/NOTES.md`가 정확한 선례입니다. 개념은 `../GLOSSARY.md`, 상위 진행 상태는 `../ROADMAP.md` 참고. 이 문서는 04번 고유 정보만 담습니다.

**개념 기록 규칙**: 새로 확인한 개념은 이 파일이 아니라 `../GLOSSARY.md`에 "내 질문/가설 → 확인된 이해" 형식으로 추가합니다. 이 파일은 진행 체크리스트·환경정보·이 실습 고유 함정만 담습니다.

---

## 내 환경 정보 (채워넣기)

| 항목 | 값 |
|---|---|
| Enrollment URL | `_shared/.env` 상속 (`https://dataartai.usw-23.palantirfoundry.com`) |
| 마켓플레이스 스토어 | `aip-practice-store` 재사용 예정 |
| 이번 실습 Foundry 프로젝트 (설치 산출물) | `04-aip-evals-feedback` (새로 생성 예정) |
| 설치한 제품 버전 | |
| `Field Extraction Job` 등 실제 온톨로지 객체명 | |
| 사용한 Evaluator | |
| Claims Parsing 처리 소요시간(실측) | |

---

## 진행 체크리스트

### 사전 점검 ✅ 완료
- [x] zip 로컬 스캔 — `THIRD_PARTY_APPLICATION` 없음 확인 (`../ROADMAP.md` 전체 스캔 표 참고)

### Phase 1 — 마켓플레이스 업로드·설치
- [ ] DevOps → `aip-practice-store` → Upload to store → `feedback_loop_evals.zip`
- [ ] Marketplace → 검색 → Create new installations → Generate new project(`04-aip-evals-feedback`)
- [ ] General/Inputs/Outputs 탭 확인 → Install
- [ ] 설치 완료 확인, Outputs에 어떤 리소스가 생겼는지 기록

### Phase 2 — Claims Parsing 프로세스 실행
- [ ] Workshop 앱에서 문서 선택 → Start Process → Claims Parsing
- [ ] 처리 완료 대기 및 결과 확인

### Phase 3 — 추출값에 피드백 제공
- [ ] 필드 최소 1개 👎 + reference value 입력
- [ ] (가능하면) 👍도 몇 개 남겨서 대비되는 케이스 확보

### Phase 4 — Object Explorer에서 테스트케이스 필터·저장
- [ ] `Field Extraction Job` 필터: `Is Test Case = true`
- [ ] Exploration으로 저장(Public 권한)

### Phase 5 — AIP Evals 평가 스위트 설정
- [ ] 백엔드 AIP Logic 함수(`logic` 폴더) 열기
- [ ] Evals 스위트 생성 → Object set으로 채우기 → Phase 4 Exploration 선택
- [ ] 피드백이 테스트케이스로 자동 흡수되는지 확인

### Phase 6 — Evaluator 구성
- [ ] Exact string match로 베이스라인 실행
- [ ] Keyword checker로 비교
- [ ] (선택) 커스텀 evaluator 시도

### Phase 7 — 평가 스위트 실행·결과 확인
- [ ] Run → 결과 대시보드에서 pass/fail·정확도 확인

### Phase 8 — 피드백 루프 실제로 돌려보기 (선택)
- [ ] 새 피드백 추가 → 재평가 → 반영 확인

---

## 함정 (미리 알아둘 것 — 직전 실습에서 이어지는 것)

1. **로컬 스캔은 설치 성공을 보장 안 함.** `THIRD_PARTY_APPLICATION`이 없다는 것만 확인됐을 뿐, Install 버튼까지 가서 최종 확인 필요 (`01-osdk-hello-world`의 교훈).
2. **AIP Evals 자체가 엔롤먼트 티어에 따라 안 보일 수 있음** (`../ROADMAP.md` §3에 이미 경고됨, 근거등급: 추정). 메뉴가 안 보이면 설정 실수가 아니라 티어 문제일 가능성 먼저 의심할 것.
3. **Evaluator는 하나로 끝내지 말 것.** README가 명시적으로 "Exact string match는 너무 엄격해서 오탐 남"이라 경고함 — Exact match만 써보고 "정확도가 낮다"고 오판하지 말고, Keyword checker와 비교까지 해야 이 Phase의 학습목표가 완성됨.
4. **03-lead-management에서 실측한 "LLM 판단의 확률적 특성"이 이 실습의 존재 이유.** (`../GLOSSARY.md` "확률적 결과 ≠ 기준 없음" 항목) 이번 실습에서 애매한 결과가 나와도 "AIP가 이상하다"가 아니라 "이게 바로 계측이 필요한 이유"로 받아들일 것.
5. **Phase 4의 Exploration 권한을 Public으로 저장하는 걸 빠뜨리지 말 것.** README가 명시한 대로, Public이 아니면 다음 Phase에서 Evals 스위트가 그 Object set을 못 찾을 가능성이 있음(미검증, 실측 시 확인).

---

## 진행 로그

- 2026-08-30: `04-aip-evals-feedback` 폴더 생성, PLAN.md·NOTES.md 작성. 원본 README 실측 완료(업무 흐름: 청구서 추출 → 피드백 → 테스트케이스화 → Evals 스위트 → Evaluator 비교 → 재평가). zip 사전 스캔에서 `THIRD_PARTY_APPLICATION` 없음 확인(`../ROADMAP.md` 전체 스캔의 일부, 상세 리소스 카운트는 미확인). Phase 1(마켓플레이스 업로드) 대기 중. **세션 종료 — 아직 Foundry 콘솔 작업은 시작 안 함, 계획서만 준비된 상태.** 다음 세션에서 Phase 1(DevOps 업로드)부터 시작.
