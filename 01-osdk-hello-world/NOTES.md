# OSDK 'Hello World' 실습 노트

> **한 줄 요약**: 이번 실습 = 온톨로지 위의 **"읽기" 파이프라인 하나만 익힌 것.** 온톨로지를 새로 만들거나 그 위에 워크플로우를 얹은 게 아니다.

원본: [aip-community-registry / OSDK 'Hello World' Project](https://github.com/palantir/aip-community-registry/tree/develop/OSDK%20%27Hello%20World%27%20Project) (Justin Langfan)
영상: https://www.youtube.com/watch?v=u-XusTktitU

---

## 핵심 학습 — 다음 실습(Peak Explorer 등)에도 그대로 적용되는 개념

**온톨로지(Ontology)** = Foundry 서버에 저장된 "객체 타입 + 실제 데이터"의 조합.
- 이번 실습에서 쓴 `[Example] Airport` 객체는 **내가 만든 게 아니라 이미 서버에 있던 것**을 골라 쓴 것. SDK를 설치해서 온톨로지가 "생긴" 게 아니라, 원래 있던 온톨로지를 로컬에서 원격으로 읽는 통로를 만든 것.
- Object Explorer(웹 화면)와 Jupyter 코드는 **같은 서버 데이터를 보는 두 개의 창구**일 뿐이다. 어느 쪽으로 봐도 결과는 같다.

**OSDK(SDK)** = 로컬 개발 환경이 그 온톨로지에 원격으로 접근하게 해주는, 생성된 클라이언트 라이브러리.
- 코드에서 `.take(1)` 이나 `.get(primaryKey)` 를 실행하면 → 인터넷을 통해 Foundry 서버에 요청이 가고 → 서버가 저장하고 있던 실제 값을 응답으로 돌려준다. 값은 로컬에서 만들어지는 게 아니라 **서버에서 추출(fetch)되는 것**.

**이 파이프라인이 앞으로도 반복되는 기본 구조 — "읽기"란 정확히 이 5단계를 말한다:**
`Developer Console(앱 생성) → 쓸 온톨로지 객체 연결 → SDK 생성 → 로컬 설치 → 인증 → 코드로 조회`

⚠ 오해하기 쉬운 지점 — **이 파이프라인이 아닌 것 2가지:**
- **스토어 앱 설치(Marketplace/DevOps)** — 이건 "읽기"가 아니라 "새 온톨로지 객체·앱을 자동 생성해주는 시도"였고, 이번엔 실패해서 안 씀
- **Object Explorer로 눈으로 보는 것** — 우리가 만든 게 아니라 원래 있던 창구. "맞는지 확인"하는 용도로 썼을 뿐, 조립해서 익힌 대상이 아님

**이번 실습에서 쓴 앱 5개, 사용한 순서대로:**

| 순서 | 앱 | 역할 (이 앱이 원래 하는 일) | 이번 실습에서 한 일 |
|---|---|---|---|
| 1 | **DevOps** | 제품(패키지)을 **만들고 스토어에 등록·배포**하는 개발자(퍼블리셔)용 도구 | 스토어(`aip-practice-store`) 생성, zip 업로드 — 여기까지 성공 |
| 2 | **Marketplace** | 등록된 제품을 **찾아서 설치**하는 사용자(컨슈머)용 카탈로그·설치 창구 — DevOps의 짝 | 업로드된 제품 설치 시도 — 번들 속 리소스가 폐기 포맷이라 차단, 포기 |
| 3 | **Object Explorer** | 온톨로지 데이터를 **사람이 눈으로 탐색·조회**하는 화면 | 기존 객체 타입 목록을 훑어보고 `[Example] Airport` 선택 |
| 4 | **Ontology Manager** | 온톨로지의 **스키마(객체 타입·속성·연결·액션)를 정의·관리**하는 관리자 도구 | `[Example] Airport`의 API name(`ExampleAirport`)·primary key(`Airport Id`) 확인 |
| 5 | **Developer Console** | 외부 코드(로컬 앱)가 온톨로지에 접근하도록 **클라이언트 앱·SDK를 발급**하는 도구 | 클라이언트 앱(`osdk-hello-world-app`) 생성 → `ExampleAirport` 연결 → pip용 SDK 생성 |

즉 원래 계획은 `1 DevOps → 2 Marketplace`로 끝나고 거기서 온톨로지 객체가 자동으로 생겨야 했는데, 2번이 막혀서 `3 Object Explorer → 4 Ontology Manager`로 대체 객체를 찾은 뒤 `5 Developer Console`로 넘어갔다.

**이번 실습 = 온톨로지 위의 "읽기"만 익힌 것.** 온톨로지를 실제로 만들거나 그 위에 워크플로우를 얹으려면 아래 앱들이 필요한데, 이번엔 하나도 안 썼다 — 다음 실습(Peak Explorer, Personal Finance 등)에서 다룰 영역:

| 하고 싶은 것 | 쓰는 앱 |
|---|---|
| 새 객체 타입·속성·연결(Link) 정의 | **Ontology Manager** (수정 권한 필요 — 지금 쓴 Airport는 `Edits: Disabled`라 못 건드림) |
| 원본 데이터를 정제해서 온톨로지에 채워넣기 | **Pipeline Builder / Code Repositories** |
| 사람이 쓰는 화면(대시보드·입력폼)을 온톨로지 위에 만들기 | **Workshop** |
| "이런 조건이면 이런 액션 실행" 자동화 | **Automate**, **Foundry Rules** |
| 온톨로지 객체를 실제로 변경(쓰기)하는 로직 | **Action types**, **Functions** |

**conda vs pip** — 역할이 다른 도구다. conda는 파이썬 작업공간(환경) 자체를 만드는 도구, pip는 그 작업공간 안에 낱개 패키지 하나를 설치하는 도구. 이번 SDK는 conda 채널 대신 pip로 배포받았다(더 간단해서). 자세한 설명은 `PLAN.md`의 "용어 — conda vs pip" 참고.

---

## 내 환경 정보 (채워넣기)

| 항목 | 값 |
|---|---|
| Enrollment URL | ✅ `https://dataartai.usw-23.palantirfoundry.com` (`..\_shared\.env` 의 `FOUNDRY_HOSTNAME`) — 응답 확인됨 |
| Foundry Space | `dataartai` |
| 공용 프로젝트 (스토어 보관) | `aip-practice` — Sandbox project ✅ |
| 이번 실습 프로젝트 (설치 산출물) | `01-osdk-hello-world` — Sandbox project ✅ |
| 마켓플레이스 스토어 이름 | `aip-practice-store` ✅ 생성·zip 업로드 완료 (위치 `aip-practice`) |
| 설치한 패키지 이름 | |
| Developer Console 앱 이름 | |
| **생성된 SDK 패키지명** (`import` 할 이름) | ✅ PyPI명 `osdk_hello_world_app_sdk` (v0.1.0, pip, 생성 진행 중) |
| 객체 API name (`client.ontology.objects.___`) | ✅ `ExampleAirport` (기존 온톨로지 객체 재사용, PK: `Airport Id`) |
| 테스트용 primary key | |

> SDK 패키지명은 Developer Console에서 지은 앱 이름에서 파생됩니다.
> 노트북 샘플의 `my_todo_application_sdk`는 **예시일 뿐** 그대로 쓰면 안 됩니다.

---

## 진행 체크리스트

### Phase 1 — 로컬 환경
- [x] Miniconda 설치 (`C:\Users\besti\miniconda3`)
- [x] `conda init powershell` 실행
- [x] conda env `osdk-hello` 생성 (Python 3.11.16 + JupyterLab 4.6.2) ✅ 검증 완료
- [x] `..\_shared\.env` 에 `FOUNDRY_HOSTNAME` 설정 ✅
- [ ] 이 폴더 `.env` 의 `FOUNDRY_TOKEN` 채우기 (Phase 2 이후)

### Phase 2 — Foundry 웹 콘솔 ✅ 완료 (아래 ①은 폐기, ②로 우회)

**① zip 마켓플레이스 설치 경로 — 폐기됨.** `Foundry DevOps`에서 스토어 생성 → zip 업로드까지는 됐으나(스토어 `aip-practice-store`), Marketplace 설치가 번들 속 낡은 Developer Console 앱(Third Party Application 포맷)이 이 플랫폼 버전에서 폐기돼 `Install` 버튼 자체가 비활성화됨. DevOps `Start new version`도 비활성화(외부 zip 임포트라 편집 불가)라 고칠 방법 없음. **더 이상 손대지 않음.**

**② 실제로 완료한 경로 — 기존 온톨로지 객체 재사용:**
- [x] Ontology Manager에서 기존 객체 타입 `[Example] Airport`(API name `ExampleAirport`) 확인
- [x] Developer Console → New application → `osdk-hello-world-app` (Client-facing, 위치 `01-osdk-hello-world`)
- [x] Ontology SDK 리소스에 `[Example] Airport` 추가 → Save
- [x] **SDK versions 탭 → pip 옵션 확인 후 pip 선택** (conda 아님) → `Generate new version`
- [x] 생성된 버전 클릭 → PyPI 패키지명 `osdk_hello_world_app_sdk` 확인, 설치 명령어(PowerShell, `pip install` + `--index-url`/`--extra-index-url` + 토큰) 복사

### Phase 3 — 로컬 연결 ✅ 완료
- [x] `conda activate osdk-hello` (env 활성화만 conda, 설치는 pip)
- [x] SDK 설치는 **pip** (`pip install osdk_hello_world_app_sdk==0.1.0 ...`) — conda install 아님
- [x] `.env`에 `FOUNDRY_TOKEN` 저장
- [x] `notebook.ipynb` TODO 채우기 (SDK import·객체명·primary key)
- [x] 실행 → `take(1)` 확인 → PK(`"11003"`, 문자열) → `.get()` → `result.display_airport_name` → `'The Eastern Iowa'`

---

## 노트북 TODO 2곳 (2026-08-29 갱신 — hostname 2곳은 env 주입으로 제거됨)

| 셀 | 현재 값 | 채울 값 |
|---|---|---|
| 셀 1 · import | `from my_todo_application_sdk import FoundryClient` | 실제 SDK 패키지명 |
| 셀 2 · get | `primaryKey = "TODO - get a primary key..."` | 셀 1의 `take(1)` 출력에서 읽은 실제 PK |

hostname은 `os.environ["FOUNDRY_HOSTNAME"]`, 토큰은 `os.environ["FOUNDRY_TOKEN"]` 으로
`run-jupyter.ps1` 이 주입합니다 — 노트북에 URL도 토큰도 적지 않습니다.

**실행 순서 주의**: `take(1)`을 먼저 돌려 PK를 눈으로 확인한 뒤 `primaryKey`를 채우세요.

---

## 함정 (미리 알아둘 것)

1. **Foundry 내장 Jupyter에서는 안 됩니다.** Developer Console이 생성한 OSDK는 Foundry 내장 노트북에서 바로 못 씁니다. **로컬 노트북이 전제**이며, 원본 README가 이를 향후 개선 희망사항으로 적어뒀습니다.
2. **CORS는 아마 건드릴 필요 없습니다.** 이 노트북은 브라우저 OAuth 리다이렉트를 타지 않고 고정 토큰을 직접 주입하는 방식이라, CORS 계열 오류가 **실제로** 뜰 때만 손대세요.
3. **`AttributeError: <객체명>`** → 쓰려는 온톨로지 객체의 API name이 코드와 다른 것. Ontology Manager에서 실제 API name 확인 후 수정.
4. **SDK 버전에 따라 인증 클래스 이름이 다를 수 있습니다.** 이번엔 `UserTokenAuth`가 존재하지 않아 `Auth`/`Token` 추상 클래스를 직접 구현해야 했습니다(노트북 셀 1 참고). 다음 실습에서도 튜토리얼 코드의 import가 그대로 안 먹으면, 설치된 패키지 내부를 직접 확인하세요.
5. **토큰을 노트북 셀에 하드코딩하지 마세요.** `os.environ["FOUNDRY_TOKEN"]`을 읽도록 설계돼 있습니다. `.env`는 `.gitignore`로 제외되어 있습니다.
6. **원본 레포(`aip-community-registry`)에 커밋하지 마세요.** remote가 palantir 공식 저장소입니다.

---

## 실행 명령 모음 (PowerShell)

```powershell
# env 활성화 (conda 는 여기까지만 — 로컬 Python 환경 관리용)
conda activate osdk-hello

# SDK 설치는 conda 가 아니라 pip 로 함
# Developer Console → Ontology SDK → SDK versions → pip 버전 생성 → 그 행 클릭하면
# 아래 형태의 PowerShell 블록이 나온다 (토큰 포함, 매번 새로 복사할 것):
#   $env:FOUNDRY_TOKEN="<token>"
#   pip install osdk_hello_world_app_sdk==0.1.0 --upgrade `
#     --index-url "https://user:$env:FOUNDRY_TOKEN@<hostname>/artifacts/api/repositories/..." `
#     --extra-index-url "https://user:$env:FOUNDRY_TOKEN@<hostname>/artifacts/api/repositories/..."
#
# ⚠ Foundry가 주는 원본은 bash 식 줄바꿈(\)이라 Windows PowerShell 5.1에 그대로 붙여넣으면 깨진다.
# 클립보드에서 자동으로 한 줄로 합쳐서 실행:
#   $cmd = (Get-Clipboard -Raw) -replace '\\\s*\r?\n\s*', ' '
#   Invoke-Expression $cmd

# 노트북 실행 (.env 자동 주입)
cd D:\OneDrive\Cursorhome\aip-practice\01-osdk-hello-world
.\run-jupyter.ps1
```

---

## 진행 로그

- 2026-08-29: Phase 1 완료 — 실습 폴더 생성, Miniconda 26.7.1 설치, conda env `osdk-hello` (Python 3.11.16 / JupyterLab 4.6.2) 생성·검증. 다음은 Phase 2 (Foundry 웹 콘솔).
- 2026-08-29: 상위 워크스페이스 `aip-practice/` 도입. 경로를 `aip-practice/01-osdk-hello-world/` 로 이동하고 공통 규칙을 상위 `CLAUDE.md` 로 분리. 호스트명은 `_shared/.env` 로 공유.
- 2026-08-29: enrollment URL `https://dataartai.usw-23.palantirfoundry.com` 를 `_shared/.env` 에 설정. 호스트 응답 실측(`GET /` → HTTP 307 → `/workspace`)으로 URL 유효성 확인. 노트북을 env 주입 방식으로 개작하고 셀을 2개로 분리(take(1) 먼저 → PK 기입). 남은 TODO는 SDK 패키지명과 PK 2곳. Phase 2 대기 중.
- 2026-08-29: Foundry 프로젝트 2개 생성 — `aip-practice`(공용·스토어 보관)와 `01-osdk-hello-world`(설치 산출물). 둘 다 Sandbox project, Space는 `dataartai`. Foundry 프로젝트는 중첩되지 않아 로컬의 상위/하위 폴더 구조를 평면 프로젝트 2개로 대응시킴. 스토어는 실습마다 만들지 않고 `aip-practice` 안의 하나를 계속 재사용한다.
- 2026-08-29: **경로 피볷** — `OSDK in Local Jupyter Notebook.zip` 을 통한 Marketplace 설치 완전 차단 확정(실측: Install 버튼 비활성화, 툴팀 "Installation has blocking validation errors"; DevOps `Start new version` 도 비활성화로 수정 불가). 원인: 번들에 포함된 Developer Console 앱(Third Party Application 포맷)이 플랫d폼 미지원화됨.
  이로 인해 **이 zip/이 스토어는 더 이상 쓰지 않음.** 대신 이 엔롤먼트에 이미 설치된 기존 온톨로지 객체(`AIP Now Ontology` 외)를 재사용해 Developer Console 앱을 직접 만들고 SDK를 생성하는 경로로 피볷. 학습 목표(로컬 Jupyter에서 OSDK로 온톨로지 객체 조회)는 어떤 객체를 쓰든 동일하게 달성됨.
- 2026-08-29: Ontology Manager에서 기존 객체 타입 `[Example] Airport`(API name `ExampleAirport`, PK `Airport Id`, 178개 객체, Edits Disabled) 선택 확정. 다음: Developer Console에서 이 객체를 import하는 앱 생성.
- 2026-08-29: Developer Console 앱 `osdk-hello-world-app` 생성 완료 (Client-facing, `01-osdk-hello-world` 위치). Ontology SDK 에 `[Example] Airport` (`ExampleAirport`) 연결. **SDK versions 탭에서 pip 옵션 확인됨** → conda 대신 pip 로 진행 결정(conda 채널 인증 생략 가능).
- 2026-08-29: 로컴 노트북에서 셀 1 실행 성공 — 실제 `ExampleAirport` 객체 1개가 조회됨(`airport_id=11003`, `The Eastern Iowa`). 이 과정에서 많은 SDK 이름 불일치가 드러남:
  - `foundry_sdk_runtime.auth` 모듈 자체가 존재하지 않음 (`_auth`만 있음)
  - `UserTokenAuth` 클래스 자체가 이 SDK 버전(2.231.0)에 없음
  - `FoundryClient.__init__`의 `auth` 파라미터는 `foundry_sdk._core.auth_utils.Auth` 추상 클래스를 요구 — `PublicClientAuth`/`ConfidentialClientAuth`(OAuth 플로우)만 있고 정적 토큰용 구현체는 없음
  → `Auth`/`Token` 추상 클래스를 직접 구현(`StaticTokenAuth`/`StaticToken`, 노트북 셀 1에 포함)해서 우회. 이 패턴은 SDK generator 2.231.0 계열에서 재사용 가능할 가능성이 높음(근거등급: 추정).
- 2026-08-29: **실습 최종 완료.** 셀 2 primaryKey 타입 수정(int → `"11003"` 문자열, ValueError로 확인됨) 후 `result.display_airport_name` → `'The Eastern Iowa'` 출력 확인. 로컴 Jupyter → OSDK → Foundry 온톨로지 객체 조회라는 이 실습의 최종 목표 달성됨. 다음 실습(Peak Explorer 또는 Personal Finance) 진행 시 참고: SDK generator 2.231.0에서는 `UserTokenAuth`가 없고 `Auth`/`Token` 추상 클래스를 직접 구현해야 하며, primary key 타입은 `take(1)` 출력의 따옴표 유무만으로 판단하지 말고 ValueError 메시지로 확인할 것.
