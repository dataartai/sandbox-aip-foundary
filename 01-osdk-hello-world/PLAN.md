# OSDK 'Hello World' 실습 환경 구축

> **문서 위치**: 이 파일은 실습 프로젝트(`D:\OneDrive\Cursorhome\aip-practice\01-osdk-hello-world`)의 정본 계획서입니다.
> 원본 레포(`aip-community-registry`)는 읽기 전용 참고 자료이며 수정하지 않습니다.

## 현재 상태 (2026-08-29)

| Phase | 상태 |
|---|---|
| **Phase 1 — 로컬 환경** | ✅ **완료 · 검증 통과** |
| **Phase 2 — Foundry 웹 콘솔** | ✅ **완료** — 기존 온톨로지 객체(`ExampleAirport`) 재사용 경로로 우회 |
| **Phase 3 — 로컬 연결 및 노트북 실행** | ✅ **완료 · 최종 검증 통과** — `result.display_airport_name` → `'The Eastern Iowa'` |

**2026-08-29 추가 진행**

- Enrollment URL 확정: `https://dataartai.usw-23.palantirfoundry.com` (`..\_shared\.env` 의 `FOUNDRY_HOSTNAME`). 호스트 응답 실측 — `GET /` → HTTP 307 → `/workspace` (로그인 리다이렉트). 도메인·TLS 유효. (근거등급: 실측)
- 노트북 선행 개작: hostname을 `os.environ["FOUNDRY_HOSTNAME"]` 으로 바꿔 TODO 4곳 → **2곳**(SDK 패키지명·PK)으로 줄임. `take(1)` 먼저 실행하도록 셀을 2개로 분리.
- ⚠ 구 실습 경로 `D:\OneDrive\Cursorhome\osdk-hello-world-practice\` 는 빈 폴더. 마켓플레이스에 올릴 zip 은 이 폴더의 `OSDK in Local Jupyter Notebook.zip` 이다.

**Phase 1 실측 결과**

| 검증 항목 | 결과 |
|---|---|
| `conda --version` | `conda 26.7.1` ✅ |
| env `osdk-hello` Python | `Python 3.11.16` ✅ |
| `import jupyterlab` | `jupyterlab 4.6.2` → `ok` ✅ |
| `jupyter` CLI | IPython 9.15.0 / ipykernel 7.3.0 ✅ |

- Miniconda 설치 경로: `C:\Users\besti\miniconda3` (winget 부재 → 공식 인스톨러 무인 설치, `AddToPath=0`)
- `conda init powershell` 이 `D:\OneDrive\문서\WindowsPowerShell\profile.ps1` 을 수정 → **새 터미널**에서만 `conda` 인식
- conda 채널 ToS 승인 완료: `pkgs/main`, `pkgs/r`, `pkgs/msys2`

**실습 종료 (2026-08-29).** 목표 달성: 로컬 Jupyter에서 OSDK로 Foundry 온톨로지 객체 조회 성공.

**용어 — conda vs pip (이 실습에서 헷갈리기 쉬운 지점):** 둘은 경쟁 관계가 아니라 계층이 다르다.
- **conda** = 파이썬이 돌아가는 독립된 작업공간(환경) 자체를 만들고 관리하는 도구. Phase 1에서 `osdk-hello` 환경을 이걸로 만들었고, **지금도 계속 conda를 씀 — 안 바뀌었다.**
- **pip** = 그 작업공간 안에서 낱개 패키지(라이브러리) 하나를 설치하는 표준 도구. Developer Console에서 "Foundry SDK를 conda 채널로 배포할지, pip(PyPI 방식)로 배포할지" 선택하는 화면이 있었고, **pip를 선택**했다(conda 채널 인증 절차를 생략할 수 있어서 더 간단함).
- 즉 "환경 만들기 = conda, 그 안에 Foundry SDK 설치 = pip"로 **역할이 나뉜 것**이지, 체크 없이 진행한 게 아니다.

> ⚠ **아래 Phase 2·3 절차는 원래 계획이며 실제로 밟은 경로와 다릅니다.** 마켓플레이스 zip 설치는 차단되어 폐기됐고, 기존 온톨로지 객체 재사용 경로로 우회했습니다. **실제로 밟은 절차와 함정은 `NOTES.md` 의 진행 로그가 정본입니다.**

**다음 실습으로**: [../ROADMAP.md](../ROADMAP.md) 참조.

---

## Context

사용자가 `aip-community-registry`의 **OSDK 'Hello World' Project**(Justin Langfan)를 AIP 입문 실습으로 진행하려 한다. 목표는 Foundry Ontology의 객체 데이터를 로컬 Jupyter 노트북으로 끌어오는 것.

현재 저장소를 실측한 결과:

- `D:\OneDrive\Cursorhome\aip-community-registry`의 git remote는 **`https://github.com/palantir/aip-community-registry.git`** (사용자 fork 아님, 브랜치 `develop`). 즉 이 레포는 **참고 자료 클론**이지 실습장이 아니다.
- `OSDK 'Hello World' Project/` 폴더에 있는 것은 4개뿐: `README.md`, `notebook.ipynb`(TODO 골격 15줄), `OSDK in Local Jupyter Notebook.zip`(마켓플레이스 패키지 — `manifest.json` + 바이너리 1개), `LICENSE`. **실행 가능한 코드도, 환경 정의도 없다.**
- 실습에 실제로 필요한 것들 — 개인 `FOUNDRY_TOKEN`, 내 엔롤먼트 전용으로 생성되는 SDK 패키지 — 은 전부 **개인 자격증명**이라 공식 레포 클론에 두면 안 된다.

**결론(사용자 확정): 별도 폴더에서 실습한다.** 현재 레포는 `notebook.ipynb`와 `.zip`의 소스로만 쓴다.

로컬 환경 실측:
- `python` → `C:\Users\besti\AppData\Local\Programs\Python\Python313\python.exe` (3.13.1) ✅
- `conda` → **없음** (Bash·PowerShell PATH 모두, `~\anaconda3`·`~\miniconda3`·`C:\ProgramData\*conda3` 모두 부재) ❌
- `jupyter` → **없음** ❌

README가 "Generate an SDK for **conda**"를 지시하므로 conda 설치가 선결 조건이다.

---

## 실습 폴더

```
D:\OneDrive\Cursorhome\aip-practice\
├── CLAUDE.md                               # 모든 실습 공통 규칙 (하위로 자동 상속)
├── .gitignore
├── _shared\
│   ├── .env                                # FOUNDRY_HOSTNAME (엔롤먼트 공통값)
│   └── .env.example
└── 01-osdk-hello-world\                     ← 이 실습
    ├── PLAN.md                             # 이 문서 — 정본 계획서
    ├── NOTES.md                            # 진행 체크리스트 + 채워넣을 정보표 + 함정
    ├── CLAUDE.md                           # 이 실습 고유 컨텍스트
    ├── notebook.ipynb                      # ✅ 완주됨 — SDK명 osdk_hello_world_app_sdk, 객체 ExampleAirport, 커스텀 Auth 구현 포함
    ├── run-jupyter.ps1                     # _shared\.env → .env 순 주입 후 jupyter lab
    ├── .env                                # FOUNDRY_TOKEN (git 추적 제외)
    ├── .env.example
    ├── .gitignore
    ├── README-original.md                  # 원본 README 사본
    └── OSDK in Local Jupyter Notebook.zip  # Foundry 마켓플레이스 업로드용 패키지 [실제: 이 엔롤먼트에서 설치 자체가 차단됨 — 사용 안 함, 아래 참고]
```

원본 레포는 건드리지 않는다(읽기 전용 참고). 공통 규칙은 상위 `aip-practice/CLAUDE.md` 참조.

---

## Phase 1 — 로컬 환경 ✅ 완료

1. **Miniconda 설치** — Anaconda 대신 Miniconda 권장(가볍고 Palantir conda 채널만 추가하면 됨).
   - `winget install Anaconda.Miniconda3` 또는 공식 인스톨러.
   - 설치 후 **새 터미널**에서 `conda --version` 확인. PATH에 안 잡히면 `Anaconda Prompt` 사용 또는 `conda init powershell`.
2. **실습 폴더 생성 + 파일 복사**
   - `notebook.ipynb`를 `OSDK 'Hello World' Project\`에서 복사.
   - `.gitignore` 작성 (`.env`, `*.token`, `.ipynb_checkpoints/`).
3. **conda env 생성**
   ```
   conda create -n osdk-hello python=3.11 jupyterlab -y
   conda activate osdk-hello
   ```
   - Python 3.13이 이미 있지만 **쓰지 않는다**: Palantir OSDK conda 패키지의 지원 버전이 3.13까지 올라왔다는 확인이 없다(근거등급: 추정). 3.11이 안전한 기본값이며, Developer Console의 `Start Developing` 탭이 다른 버전을 지시하면 그쪽을 따른다.

**이 단계에서 SDK는 아직 설치하지 못한다** — SDK 패키지는 Phase 2에서 내 엔롤먼트 전용으로 생성되어야 존재한다.

---

## Phase 2 — Foundry 웹 콘솔 (원안 — 정정 사항은 [실제: ...]로 인라인 표기)

README(`OSDK 'Hello World' Project/README.md:10-58`) 순서 그대로:

1. **마켓플레이스 업로드** — `{enrollment-url}/workspace/marketplace` → 스토어 선택/생성 → `Upload to Store` → `OSDK in Local Jupyter Notebook.zip` 업로드.
2. **패키지 설치** — General Setup(이름·위치) → Input(입력 없음, 통과) → Content Review(Ontology·Developer Console·Functions 확인) → Validation → Install.
   - 여기서 **To Do Application**과 `OSDK Task` 온톨로지 객체가 생긴다. **[실제: 여기까지 도달 못 함 — 번들 속 앱이 폐기 포맷이라 `Install` 자체가 차단됨. 기존 객체 `ExampleAirport` 재사용으로 대체했다. 상세는 `NOTES.md` 참고.]**
3. **Developer Console 애플리케이션 생성**
   - 새로 생긴 **`OSDK Task` 객체를 import**
   - Application type: **Client facing application**
   - Redirect URL: `http://localhost:8080/auth/callback` (자동 채워짐)
4. **SDK 생성** — Developer Console → Ontology SDK → SDK versions 탭에서 언어/패키지 관리자 선택. **conda 대신 pip를 권장한다** — pip 옵션이 있으면(실측: 이 엔롤먼트엔 npm/pip/conda/maven/other 전부 존재) conda 채널 ToS 승인·채널 추가 같은 선행 설정을 건너뛸 수 있다. 여기서 정해지는 **패키지 이름을 `NOTES.md`에 기록**한다. 노트북 샘플의 `my_todo_application_sdk`는 예시일 뿐이며 실제 이름은 내가 지은 앱 이름에서 파생된다.
5. **생성된 버전 행을 클릭해 설치 명령어 전부 복사** — pip 기준으로는 `pip install <sdk-package> --index-url ... --extra-index-url ...` 형태(토큰 포함)가 나온다. 이 화면이 로컬 설치의 단일 진실 원천이다.
   - ⚠ 이 명령어는 bash 식 줄바꿈(`\`)으로 돼 있어 Windows PowerShell 5.1에 그대로 붙여넣으면 깨진다. `$cmd = (Get-Clipboard -Raw) -replace '\\\s*\r?\n\s*', ' '; Invoke-Expression $cmd` 로 우회한다(`NOTES.md` 실행 명령 모음 참고).

---

## Phase 3 — 로컬 연결 및 노트북 실행 (원안 — 정정 사항은 [실제: ...]로 인라인 표기)

1. **SDK 설치** — `conda activate osdk-hello`(env 활성화만 conda, 패키지 설치는 **pip**) 후 SDK versions 탭에서 복사한 pip 명령 실행.
2. **토큰 설정** — `Start Developing`이 준 토큰을 `.env`에 저장하고, 노트북 실행 전 환경변수로 주입.
   - PowerShell 세션: `$env:FOUNDRY_TOKEN = "<token>"` 후 같은 세션에서 `jupyter lab` 실행.
   - 토큰을 **노트북 셀에 하드코딩하지 않는다** — 노트북 코드가 `os.environ["FOUNDRY_TOKEN"]`을 읽도록 설계돼 있다.
3. **`notebook.ipynb` 남은 TODO 2곳 채우기** (hostname 2곳은 env 주입으로 이미 제거됨):
   | 셀 | 채울 값 |
   |---|---|
   | 셀 1 `from my_todo_application_sdk import FoundryClient` | Phase 2-4 에서 기록한 실제 SDK 패키지명 |
   | 셀 2 `primaryKey = ...` | 셀 1 `take(1)` 출력에서 읽은 실제 PK |

   **[실제: "빈칸 2곳 채우기"보다 훨씬 컸다.** SDK generator 2.231.0엔 튜토리얼이 쓰는 `UserTokenAuth` 클래스 자체가 없어서, 셀 1에 `Auth`/`Token` 추상 클래스 커스텀 구현(`StaticTokenAuth`)을 통째로 새로 써야 했다 — 세 번째 관문이었고 이 표엔 안 적혀 있었다. 상세는 `NOTES.md` 함정 4번.]

4. **실행 순서** — `take(1)`을 먼저 돌려 PK를 눈으로 확인한 뒤 `primaryKey`를 채우고 `.get()` → `result.description` 출력까지. **[실제: 최종 코드는 `result.display_airport_name` → `'The Eastern Iowa'`. `description`이라는 속성 자체가 이 객체엔 없다.]**

---

## 함정 / 미리 알아둘 것 (원안 — 정정 사항은 [실제: ...]로 인라인 표기)

- **Foundry 내장 Jupyter에서는 안 된다.** Developer Console이 생성한 OSDK는 Foundry 내장 노트북에서 바로 못 쓴다. 로컬 노트북이 전제이며, README가 이를 향후 개선 희망사항으로 적어뒀다(`README.md:61-64`).
- **CORS 설정은 이 노트북에는 불필요할 가능성이 높다.** README가 control panel에서 `http://localhost:8080` CORS 허용을 언급하지만, `notebook.ipynb`는 고정 토큰을 직접 주입하는 방식이라 브라우저 OAuth 리다이렉트를 타지 않는다(근거등급: **추정** — 이 항목을 쓸 당시 실제 SDK를 받아보기 전이라 원본 튜토리얼 코드만 읽고 판단했다. 결론 자체는 나중에 맞는 것으로 확인됐지만, "분석"이라 표기한 건 과했다). 401/403이 아니라 CORS 계열 오류가 실제로 뜰 때만 손댄다. **[실제로 근거가 됐던 클래스명 `UserTokenAuth`는 SDK 2.231.0에 존재하지 않았다 — 결론은 맞았지만 든 근거는 틀렸다. 커스텀 `StaticTokenAuth`로 구현했다.]**
- **객체 API 이름 표기 차이.** 노트북 원본은 `client.ontology.objects.osdkTodoTask`를 쓴다. 설치 시 객체 API 이름이 다르게 잡히면 여기서 `AttributeError`가 난다 → Ontology Manager에서 실제 API name을 확인해 맞춘다. **[실제 최종 코드는 `client.ontology.objects.ExampleAirport` — `osdkTodoTask`는 애초에 존재한 적 없는 객체(zip 설치 자체가 막혔으므로)다.]**
- **패키지 zip은 Foundry에 올려야만 의미가 있다.** 로컬에서 압축을 풀어봐야 `manifest.json`과 바이너리 blob 하나뿐이고 읽을 코드가 없다.
- **원본 레포에 커밋하지 않는다.** remote가 palantir 공식 저장소라 실수로 push할 대상이 아니다.

---

## 검증 (end-to-end) (원안 — 정정 사항은 [실제: ...]로 인라인 표기)

각 단계에서 다음이 통과해야 다음으로 넘어간다:

1. `conda --version` → 버전 출력 (Phase 1)
2. `conda activate osdk-hello && python -c "import jupyterlab; print('ok')"` → `ok` (Phase 1)
3. Foundry 마켓플레이스에 패키지가 **Installed** 상태로 보이고, Ontology Manager에 `OSDK Task` 객체와 샘플 행이 존재 (Phase 2) **[실제: 달성 불가능한 기준으로 판명 — 이 zip은 설치 자체가 차단됨. 이 경로는 폐기됐다.]**
4. `conda activate osdk-hello && python -c "import <sdk_package>; print('ok')"` → `ok` (Phase 3-1)
5. `python -c "import os; print(bool(os.environ.get('FOUNDRY_TOKEN')))"` → `True` (Phase 3-2)
6. **최종 성공 기준**: 노트북에서 `print(osdkTodoTaskObject.take(1))`이 실제 객체를 출력하고, `result.description`이 문자열을 반환. **[실제 최종 코드: `exampleAirportObject.take(1)` → `result.display_airport_name` → `'The Eastern Iowa'`. `osdkTodoTaskObject`도 `result.description`도 실제로 쓰인 적 없다.]**

실패 시 진단 순서: 인증(401/403) → 호스트명 오타 → SDK 패키지명/객체 API명 불일치(`AttributeError`) → PK 불일치(`None`/not found) → 네트워크·CORS.

---

## 참고 자료

- 원본 README: `D:\OneDrive\Cursorhome\aip-community-registry\OSDK 'Hello World' Project\README.md`
- 노트북 골격: 같은 폴더 `notebook.ipynb`
- 공식 영상 튜토리얼: https://www.youtube.com/watch?v=u-XusTktitU
- 마켓플레이스 설치 문서: https://www.palantir.com/docs/foundry/marketplace/install-product
- ~~다음 단계 추천 경로(레지스트리 가이드 기준): OSDK 'Hello World' → Peak Explorer 또는 Personal Finance 설치 → Media and Derived Properties~~ **[실제: 이 순서는 폐기됨. 최신 순서는 `../ROADMAP.md` §0.5(Palantir 지원 준비용 압축 트랙) 참조 — 다음은 Expense Reporting.]**
