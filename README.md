# aip-practice

Palantir Foundry / AIP(AI Platform)를 실습으로 익히는 개인 워크스페이스입니다. [aip-community-registry](https://github.com/palantir/aip-community-registry)의 예제 프로젝트를 하나씩 설치·분석하면서, Foundry의 핵심 개념을 실제 화면에서 확인하고 정리합니다.

## 목적

- Foundry 웹 콘솔(DevOps, Marketplace, Ontology Manager, Object Explorer, Developer Console 등)의 실제 사용법을 손으로 익힌다
- **온톨로지(Ontology)** — Foundry의 중심 개념인 "행동 가능한 객체 층" — 을 실제 예제로 이해한다
- 로컬 개발 환경(OSDK)에서 Foundry 온톨로지 데이터에 접근하는 파이프라인을 직접 구축해본다
- 실습마다 겪은 시행착오와 함정을 기록해, 다음 실습에서 반복하지 않는다

## 구조

```
aip-practice/
├── _shared/                 # 엔롤먼트 공통값(.env, git 추적 제외)
├── 01-osdk-hello-world/     # 완료 — 로컬 Jupyter에서 OSDK로 온톨로지 객체 조회
├── 02-expense-reporting/    # 진행 중 — Ontology Action·Function·Workshop이 엮이는 워크플로우 실습
└── (계속 추가 예정)
```

각 실습 폴더는 다음 문서를 공통으로 갖습니다:
- `PLAN.md` — 그 실습의 정본 계획서(학습목표·단계별 절차·검증 기준)
- `NOTES.md` — 실측 기록, 진행 체크리스트, 함정 목록

## 학습 로드맵 (요약)

Foundry는 "무엇이 명사(객체)이고 무엇이 무엇과 연결되는가"부터 설계하는 **온톨로지 중심** 플랫폼입니다. 기존 자동화(스크립트/DB/API)와 다르게, 객체·쓰기 규칙(Action)·로직(Function/AIP Logic)·자동화(Automate)·화면(Workshop)이 하나의 정의를 공유합니다.

실습은 다음 순서로 진행합니다:

1. **읽기** — 로컬 코드(OSDK)로 기존 온톨로지 객체를 원격 조회한다 (01번)
2. **워크플로우 관찰** — Action(쓰기)·Function(로직)·Workshop(화면)이 온톨로지 위에서 어떻게 하나의 업무 흐름으로 엮이는지 완성된 예제로 학습한다 (02번)
3. **직접 설계** — Ontology Manager에서 객체 타입을 처음부터 직접 만들어보고, 그 위에 Action·화면을 얹는다
4. **검증·피드백 루프** — AIP Evals로 결과물의 품질을 계측하고 개선하는 순환 구조를 이해한다

## 원칙

- 원본 레포(`aip-community-registry`)는 읽기 전용 참고 자료로만 쓰고 수정하지 않습니다.
- 자격증명(`FOUNDRY_TOKEN` 등)은 각 실습 폴더의 `.env`에만 두며, 전부 git에서 제외됩니다.
- 각 실습을 시작하기 전 "이걸로 뭘 배우려는가"를 한 줄로 먼저 적어둡니다.

## 참고

- 원본 레지스트리: https://github.com/palantir/aip-community-registry
- Foundry 공식 문서: https://www.palantir.com/docs/foundry/
