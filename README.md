# Terraform이 포함된 code-server

이 저장소는 브라우저에서 실행되는 오픈 소스 VS Code인 [code-server](https://github.com/coder/code-server)를 Terraform이 사전 설치된 상태로 실행하기 위한 Docker 구성을 제공합니다.

## 필수 조건

시스템에 다음 항목이 설치되어 있는지 확인하세요.

* [Docker](https://docs.docker.com/ko/get-docker/)
* [Docker Compose](https://docs.docker.com/compose/install/) (V2 권장)

## 시작하기

1.  **저장소 복제 (또는 파일 복사):**

    이 `Readme.md` 파일과 제공된 `Dockerfile`, `docker-compose.yml` 파일이 로컬 디렉토리에 있다면 이 단계를 건너뛸 수 있습니다. 그렇지 않다면 이 파일들이 포함된 저장소를 복제하세요.

2.  **Docker 이미지 빌드:**

    `Dockerfile`이 있는 디렉토리로 이동하여 다음 명령을 실행합니다.

    ```bash
    docker build -t code-server-with-terraform .
    ```

    이 명령은 `Dockerfile`의 지침에 따라 `code-server-with-terraform`라는 Docker 이미지를 빌드합니다. 지정된 Terraform 버전을 다운로드하여 설치합니다.

3.  **Docker Compose를 사용하여 code-server 컨테이너 실행:**

    같은 디렉토리에서 다음 명령을 실행합니다. 이 명령은 컨테이너가 호스트의 Docker 소켓 (`/var/run/docker.sock`)에 접근할 수 있도록, 현재 사용자의 `docker` 그룹 ID (GID)를 컨테이너에 전달합니다.

    ```bash
    DOCKER_GID=$(getent group docker | cut -d: -f3) docker compose up -d
    ```

    * **참고:** 이 명령은 함께 제공된 `docker-compose.yml` 파일이 `group_add:` 섹션에서 `${DOCKER_GID}` 환경 변수를 사용하도록 설정되어 있다고 가정합니다.
    * 만약 `docker` 그룹이 없거나 GID를 가져올 수 없는 경우 오류가 발생할 수 있습니다.

    이 명령은 `docker-compose.yml` 파일에 정의된 대로 `code-server-terraform` 컨테이너를 백그라운드에서 실행합니다 (`-d` 플래그).

4.  **웹 브라우저에서 code-server 접속:**

    웹 브라우저를 열고 `http://localhost:8080`으로 이동합니다. code-server 인터페이스가 나타납니다.

## 사용법

code-server가 실행되면 다음 작업을 수행할 수 있습니다.

* 마운트된 볼륨 (`.:/home/coder/project` 또는 `docker-compose.yml`에 지정된 다른 경로)의 파일을 탐색합니다. 브라우저에서 변경한 내용은 로컬 디렉토리에 반영되며, 그 반대의 경우도 마찬가지입니다.
* code-server 내에서 터미널을 열고 (터미널 > 새 터미널) Terraform 명령 (`terraform version`, `terraform init` 등)을 실행합니다. 지정된 Terraform 버전이 이미 설치되어 있습니다.

## 구성

* **Terraform 버전:** `Dockerfile`은 현재 Terraform 버전 `1.11.3`을 사용합니다. 이미지 빌드 전에 `Dockerfile`에서 `ARG TERRAFORM_VERSION` 줄을 수정하여 이 버전을 변경할 수 있습니다.

* **code-server 포트:** `docker-compose.yml` 파일은 호스트 머신의 포트 `8080`을 컨테이너의 포트 `8080`에 매핑합니다. 필요한 경우 호스트 포트를 변경할 수 있습니다.

* **마운트된 볼륨:** `docker-compose.yml` 파일은 기본적으로 현재 디렉토리 (`.`) 또는 특정 경로를 컨테이너 내부의 `/home/coder/project`에 마운트합니다. `docker-compose.yml` 파일의 `volumes` 섹션에서 이 설정을 확인하고 필요에 따라 조정할 수 있습니다.

* **Docker GID 전달:** 시작하기 섹션의 `docker compose up` 명령어는 호스트의 Docker GID를 컨테이너에 전달합니다. 이는 `docker-compose.yml`의 `group_add: - ${DOCKER_GID}` 설정과 함께 작동하여 컨테이너가 호스트 Docker 데몬과 통신할 수 있도록 합니다.

* **인증:** `docker-compose.yml` 파일은 `--auth none` 명령을 사용하여 code-server에 대한 인증을 비활성화합니다. **이는 일반적으로 프로덕션 환경에서는 권장되지 않습니다.** 보안 강화를 위해 인증을 구성해야 합니다. 자세한 내용은 [code-server 문서](https://github.com/coder/code-server/blob/main/docs/guide.md#authentication)를 참조하세요.