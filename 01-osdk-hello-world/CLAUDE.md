# 01-osdk-hello-world

Palantir Foundry **OSDK 'Hello World'** 입문 실습.
Foundry Ontology의 객체 데이터를 로컬 Jupyter 노트북으로 끌어오는 것이 목표.

> 공통 규칙(원본 레포 취급, 토큰 취급, conda 명명, Foundry 제약)은 상위 `aip-practice/CLAUDE.md`에 있고 자동 상속됩니다. 여기에는 **이 실습 고유 사항만** 적습니다.

원본: [aip-community-registry / OSDK 'Hello World' Project](https://github.com/palantir/aip-community-registry/tree/develop/OSDK%20%27Hello%20World%27%20Project) (Justin Langfan)
영상: https://www.youtube.com/watch?v=u-XusTktitU

## 문서 위계

- **`PLAN.md`** — 정본 계획서. Phase 1~3 설계 + 현재 상태 + 검증 기준. **작업 시작 전 반드시 읽을 것.**
- **`NOTES.md`** — 진행 체크리스트. 엔롤먼트 URL·SDK 패키지명 등 사용자가 채워넣는 정보표.
- `README-original.md` — 원본 튜토리얼 README 사본 (수정 금지, 참조용)

## 현재 상태

- **Phase 1 (로컬 환경) 완료** — conda env `osdk-hello` (Python 3.11.16 / JupyterLab 4.6.2)
- **Phase 2 (Foundry 웹 콘솔) 대기** — 사용자가 직접 수행
- **Phase 3 (로컬 연결) 대기** — Phase 2의 `Start Developing` 명령어와 SDK 패키지명이 있어야 시작 가능

## 실행

```powershell
conda activate osdk-hello          # 새 터미널에서만 동작
.\run-jupyter.ps1                  # ..\_shared\.env → .env 순으로 읽어 주입 후 jupyter lab 실행
```

- env 절대경로: `C:\Users\besti\miniconda3\envs\osdk-hello\python.exe`
- `FOUNDRY_HOSTNAME`은 `..\_shared\.env`, `FOUNDRY_TOKEN`은 이 폴더의 `.env`

> env 이름이 상위 규칙(`aip-<슬러그>`)과 다릅니다. Phase 1을 규칙 확정 전에 만들었기 때문입니다. 바꾸려면 `conda create -n aip-osdk-hello --clone osdk-hello` 후 원본 삭제.

## 이 실습 고유 함정

- README가 `http://localhost:8080` CORS 설정을 언급하지만, 이 노트북은 `UserTokenAuth`(토큰 직접 주입) 방식이라 브라우저 OAuth를 타지 않습니다. CORS 오류가 **실제로** 뜰 때만 손댑니다. (근거등급: 분석 — 노트북 코드 실측)
- `AttributeError: osdkTodoTask` → 설치 시 객체 API name이 다르게 잡힌 것. Ontology Manager에서 실제 API name 확인 후 노트북 수정.
- 노트북의 `my_todo_application_sdk`는 **예시 이름**입니다. 실제 SDK 패키지명으로 반드시 교체해야 합니다.

## 실패 시 진단 순서

인증(401/403) → 호스트명 오타 → SDK 패키지명·객체 API명 불일치(`AttributeError`) → PK 불일치 → 네트워크·CORS
