# 1. Image와 Container의 기본

Image는 실행 환경에 대한 템플릿/blueprint이며, container는 image의 실행 인스턴스입니다.

Image에 있는 코드, 실행 환경이 실행된 Container에 '복사'되는 것이 아니라, 그 위에 부가 레이어를 추가하여 리소스, 메모리 등을 할당합니다.

같은 image에서 여러 container를 만들 수(실행할 수) 있습니다.

## 1) Image로 Container 실행하기

새로운 이미지를 직접 만들거나, docker hub에서 제공하는 이미지를 사용할 수 있습니다.

보통 새로운 이미지를 만들 때도 docker hub에서 기반이 되는 이미지를 가져와 사용하게 됩니다.

```bash
docker run node
```

해당 이미지가 없는 경우 docker hub에서 pull합니다

## 2) Image로 Container를 실행함과 동시에 상호작용하기

```bash
docker run -it node
```

## 3) 실행중인 Container 확인하기

```bash
docker ps -a
```

# 2. Dockerfile로 image 템플릿 생성 및 빌드(image 생성)하기

주의: 상대경로(`./`), 절대경로(`/`)

Dockerfile은 layer system을 기반으로 하며, 모든 레이어는 캐싱이 가능합니다.

즉, 한 레이어마다 변경된 파일 내용/명령어를 파악하여 변경이 시작된 지점 이전은 캐싱된 것으로, 그 이후부터 다시 re-build합니다.

그러므로 예를 들어 npm 기반 프로젝트의 경우, 효율적 처리를 위해 `package.json`을 `COPY`한 후 `npm install`, 이후 `COPY . /app` 순으로 레이어를 구성하는 것이 좋습니다.

코드 변경 사항이 발생할 때마다 `npm install`을 할 필요가 없기 떄문이죠.

## 1) `FROM [image]`

가져와 기반이 될 image(로컬에 없으면 docker hub에서 가져옴)

## 2) `WORKDIR [/the/workdir/path]`

작업을 시작할 위치(서브 디렉토리를 생성하여 사용하는 것이 좋음)

## 3) `COPY [source] [dest]`

-   source(host file system): 이미지 외부에서 복사해올 디렉토리(Dockerfile 제외)
-   dest: 복사해와 image/container에 위치시킬 디렉토리(절대경로로 예를 들면 `/app`, 상대경로로 예를 들면 `./`)

## 4) `RUN [command]`

-   Image가 빌드될 때 실행될 것(서버를 시작하는 명령어는 쓰면 안되겠지)

## 5) `EXPOSE [port]`

-   container가 열어둘 port

## 6) `CMD [[command1], [command2], ...]`

-   container가 실행될 때마다 실행할 명령어: `CMD ["node", "server.js"]`

## 7) 이후 Dockerfile로 image 생성하기

```bash
docker build [Dockerfile 위치]
```

## 8) container 실행하기

`EXPOSE`를 사용했던 경우, -p 태그를 추가하여 host port와 대응되어 열어줄 container port를 작성해야 합니다.

```bash
docker run -p [HOST포트:Container포트] [image 이름]
```

## 9) 추가: ENV와 ARG

ENV는 3가지 방식이 있습니다.

-   `Dockerfile`: `ENV PORT 80` 이후 `EXPOSE $PORT`, `process.env.PORT`
-   명령어: `--env PORT=80` or `--e PORT=80`
-   `.env`: `--env-file 파일 경로`

ARG는 build 시에만 사용 가능하다. 즉, `Dockerfile`에서나 build 명령어(`--build-arg DEFAULT=8000`)로 사용할 수 있습니다. 후자가 전자보다 더 높은 우선순위를 가집니다.

```Docker
ARG DEFAULT_PORT=80

ENV PORT $DEFAULT_PORT

EXPOSE $PORT
```

# 3. Image, Container의 여러 옵션과 명령어들

-   `docker ps`: 실행중인 모든 container를 보여줌

    -   `docker ps -a`: 중지된 것까지 포함

-   `docker run [image id 혹은 name(tag)]`: 변경된 이미지 기반 container 시작

    -   해당 container는 default로 foreground(attached)에서 실행됨
    -   detached mode: `-d`
    -   input 필요한 경우(pseudo 터미널과 함께): `-it`

-   `docker start [container id 혹은 name(tag)]`: 변경된 image가 없이 그냥 container 시작

    -   해당 container는 default로 background(detached)에서 실행됨
    -   attached mode: `-a`
    -   input이 필요한 경우(pseudo 터미널과 함께): `-a -i`

-   이미 실행된 container에 attach

    -   `docker attach [container id 혹은 name(tag)]`
    -   `docker logs -f [container id 혹은 name(tag)]`

-   삭제

    -   image: `rmi`
    -   사용되지 않는 모든 image 제거: `docker image prune`
    -   container: `rm`
    -   중지된 container 자동 제거하기(주로 쓰임): 실행할 때 `docker run --rm ...`

-   Inspect image: `docker image inspect [image id 혹은 name(tag)]`
-   copy container file/folder(바람직하지는 않음): `docker cp [볼사하려는 것 HOST 디렉토리] [container id 혹은 name(tag)]:/[디렉토리]` 혹은 `docker cp [container id 혹은 name(tag)]:/[디렉토리] [볼사하려는 것 HOST 디렉토리]`

-   name, tag 지정하기

    -   name: `--name [이름]`
    -   tag: version과 같은 옵션 정보 `-t [이름]:[태그]`

# 4. 이미지 공유하기

보통 빌드되어 완성된 이미지를 Docker Hub에 공유하며, Dockerfile을 공유하지는 않습니다.

같은 repository에 push하면 tag에 계속 표시됩니다.

-   로그인(초기에 한 번만 하면 됨): `docker login`
-   이름을 Docker Hub repository와 동일하게 설정(기존 이미지 이름 변경 혹은 새로 이미지 생성): `docker tag [기존 이름]:[기존 태그] [복제할 이름]`

-   push(로그인 필요)

    ```bash
    docker push yeongyin/goalapp:tagname
    ```

-   pull(로그인 필요 없음)

    ```bash
    docker pull yeongyin/goalapp:tagname
    ```

    혹은 그냥 바로 컨테이너를 실행한다면 다음과 같이 할 수 있으나, 자동으로 latest version을 반영하진 못하긴 때문에 수동으로 `pull`하길 바랍니다.

    ```bash
    docker run yeongyin/goalapp:tagname
    ```

# 5. 데이터 관리 및 볼륨(volume)

## 1) 데이터 종류

데이터의 종류는 Application, Temporary App Data, Permanent App Data가 있을 것입니다.

### Application(image)

image는 "read-only", 즉 수정이 불가합니다.

그러므로 프로젝트에서 어떤 데이터를 변경한다는 것은 image를 re-build해야 한다는 것과 같습니다. 이미지 내부에 그러한 데이터들 저장(store)하고 있다는 것입니다.

### Temporary App Data(container)

하지만 기본적으로 "read-write"가 가능한 container에 저장된 데이터 중 일부는 일시적이며, container가 종료됨과 동시에 삭제될 수 있습니다. 예를 들어 user input, fetched data, temporary files 등등이 있죠.

이는 image layer를 감싸고 있는 container layer에서만 이루어지며, image layer의 데이터 변화와는 관계가 없습니다. Image layer는 "read-only"라는 사실을 잊지 맙시다.

### Permanent App Data

이는 container가 삭제되더라도 유지되어야 하는 데이터이며, 데이터베이스에 저장된 유저 정보와 같은 것들이 이에 해당됩니다.

read+write가 가능하고 영구적인 이 데이터는, 'volume'의 도움을 받아 구현 가능합니다.

## 2) External Data Storages

HOST에 저장된 폴더이며, 이를 container의 특정 경로와 연결시킨다.

"read-write"가 가능한 Permanent data이며 HOST에 파일을 추가하면 container에, container에서 파일을 추가하면 HOST에 반영된다.

-   volume 조회
    ```bash
    docker volume ls
    ```
-   사용하지 않는 volume 제거: 기본적으로 volume은 `--rm`과 함께 시작된 container가 종료되었을 때 자동으로 삭제되며, 그렇지 않은 경우에는 수동으로 삭제해주어야 합니다.
    ```bash
    docker volume rm [VOL_NAME]
    ```
    ```bash
    docker volume prune
    ```

### Volumes(docker가 관리)

우리가 직접 접근할 필요가 없는 데이터이며(실제로 경로를 찾기 힘듦), docker가 직접 관리합니다.

Container 외부의 특정 폴더에 연결된 Docker 내부 폴더/파일입니다.

-   Anonymous volumes: 우리가 모르는 어떤 HOST 경로에 container 경로가 매핑됩니다. 해당 HOST 경로를 정학히 알 수 없으며, container가 shut down 되면 사라집니다. 그러므로 temporary data라 할 수 있습니다. 이 경우에는 `Dockerfile`에 미리 작성하며 물론 container를 실행할 때도 작성할 수 있습니다.

    ```Docker
    VOLUME [ "경로" ]
    ```

    혹은

    ```bash
    docker run -v :[CONTAINER 경로] [IMAGE 이름]
    ```

    Anonymous volume은 이미 존재하는 데이터를 잠그는 데에도 유용합니다. Container 내부 경로의 우선순위를 높여서 이를 가능하게 하는데, 아래 `node_modules`에 대한 정보를 확인해보세요.

-   Named volumes: container가 shut down되도 HOST, container 내 volume은 사라지지 않습니다. 영구적이어야 하지만 해당 파일에 엑세스할 필요가 없는 경우에 사용합니다. 이 경우에는 `Dockerfile`에 작성하지 않고 container를 실행할 때 다음과 같이 작성합니다.

    ```bash
    docker run -v [volume 이름]:[CONTAINER 경로] [IMAGE 이름]
    ```

    Named volume은 실제로 general 데이터로, 여러 container가 이를 공유할 수 있습니다.

### Bind Mounts(우리가 관리)

실제로 HOST 경로를 알고 있는 데이터입니다. 우리가 직접 매핑할 HOST 경로를 선언하게 됩니다.

그렇기 때문에, bind mounts는 permanent, editable data에 적합합니다.

예를 들면 source code가 있습니다. Container는 image의 스냅샷을 기반하여 실행되기 때문에 막 변경한 데이터가 container에 반영되지 않는데, bind mounts 데이터로 처리하면 container가 실행될 때 해당 data를 반영하게 되며, 물론 변경점이 발생할 때마다 container에도 반영됩니다.

Bind Mounts도 container에만 반영해야 하기 때문에 `Dockerfile`에 작성하지 않습니다.

Host(프로젝트 전체) 파일들을 image를 이용해 만든 container에 덮어 씌우는데, 이 떄 `node_modules`는 사라지게 되는 문제가 있습니다(Host에서는 `npm install`을 안 해서 `node_modules`가 존재하지 않는다는 가정 하에).

해당 문제를 해결하기 위해 "더 긴 container 내부 경로를 채택한다"는 Docker volume에 원칙을 이용하여 `-v /app/node_modules`와 같은 anonymous volume을 하나 추가합니다.

그리고 마지막으로, HOST에서만 해당 내용을 변경 가능하고 container에서는 HOST의 내용을 변경하면 안되기 때문에 "read-only" 처리해주어야 합니다. 그래서 'container 경로' 뒤에 `:ro`를 추가해줍니다. 여기서 `-v /app/temp` anonymous volume도 추가해야 하는데, 이유는 아시겠죠?

```bash
docker run -v "[HOST 절대경로(즉, 프로젝트 절대경로)]:[CONTAINER WORKDIR]:ro" -v /app/temp -v /app/node_modules[IMAGE 이름]
```

이 때, 경로에 공백이나 특수문자가 있을 수 있으므로 경로 부분을 따옴표로 묶기를 권장합니다.

이렇게 프로젝트 전체를 binding하였기 때문에, docker 명령어로는 데이터를 삭제할 수 없으며 host의 파일을 직접 제거하는 것이 유일한 방법입니다.

### Bind Mounts 추가: Nodejs 웹 서버의 경우, 서버 변경점을 반영하기 위해서는 `nodemon`을 적용해야

```json
"scripts": {
	"start": "nodemon server.js"
},
"devDependencies": {
	"nodemon": "2.0.4"
}
```

```Docker
CMD [ "npm", "start" ]
```

이후 rebuild

### 앱 전체를 bind mount로 처리할 거면 `Dockerfile`에 `COPY`가 필요할까요?

네! 스냅샷 image는 production 환경에서 필요하기 때문입니다.

### `.dockerignore`와 작성해야 할 것들

`.dockerignore` 파일에 작성된 것은 이미지 빌드 시 `COPY`에서 무시됩니다.

보통 `node_modules`와 `.git`은 포함하는 것이 좋습니다.

# 6. 네트워킹(컨테이너 외부와 소통하기)

## 1) world-wide api <- container

가능

## 2) host <- container

domain을 `localhost` 대신 `host.docker.internal`로 사용하면 container가 실행된 HOST의 ip로 변환됩니다.

예를 들면, db가 로컬 환경인 경우 container에서 연결할 db 주소를 위와 같이 작성하면 됩니다.

## 3) container <- container

하나의 컨테이너는 하나의 역할만 하는 것이 좋기에, 여러 컨테이너로 프로젝트를 구성하는 것은 흔한 작업이 될 것입니다.

보통 db - server 간의 관계가 그렇습니다

### 원시적인 방법(비추천)

참조할 대상 container를 먼저 실행(예를 들면 db)한 후 `docker inspect`로 ip를 요청할 container의 domain에 작성하여 실행합니다.

### container networks

네트워크 생성

```bash
docker network create 네트워크 이름
```

이후 통신할 container 실행

```bash
docker run --network 네트워크 이름 ...
```

동일한 네트워크를 사용하면 container 서로간의 연결을 허용합니다.

그리고 domain의 경우 연결하려는 container의 name을 적어주면, ip를 하드코딩할 필요 없이 자동으로 해당 ip로 변환됩니다.

여기서 좋은 점은, db container와 같이 다른 곳이 아니라 오로지 '다른 container'에게만 요청을 받는 경우에는 port를 열지 않아도 된다는 것입니다.

# 7. 다중 container application with Docker Compose

Docker Compose란?: application(동일한 host)을 구성하는 여러 image(container)를 한 파일 내에서 build, start, stop... 할 수 있습니다(Orchestration Commands).

(물론 귀찮은 명령어 입력을 편하게 하기 위해 단일 container에서도 유용하게 사용됩니다)

물론, Docker Compose는 Dockerfile을 대체하는 개념이 아니며, image나 container 또한 마찬가지 입니다. 그리고 다른 host를 container를 관리하는 데에도 적합하지 않습니다.

Docker Compose에서 service는 container와 거의 동일합니다.

이제 `docker-compose.yaml` 파일을 작성해봅시다.

## 0) 기본 설정과 명령어

이 파일은 들여쓰기로 구문이 구분됩니다.

default mode는 attached mode이며, 막약 detached mode를 원하면 `-d`를 입력합니다

Docker Compose를 통해 container를 '실행'하면 이와 동시에 container끼리 공유하는 default network가 같이 생성됩니다.

-   `docker-compose build`: 빌드만 다시 할 경우. container를 시작하지는 않음
-   `docker-compose up -d`: detached mode로 빌드 및 시작
-   `docker-compose up -d --build`: 새로운 이미지를 무조건 빌드, Dockerfile이 변경된 경우
-   `docker-compose down`: 모든 container와 network를 중지하고 삭제
-   `docker-compose down -v`: volume도 삭제(보통 영구 데이터이므로 좋지는 않음)

## 1) `version`

기능에 따라 버전 구분(어떤 기능을 사용할 수 있는지)

Optional: 사실 우리가 구현하는 대부분의 기능들은 이 버전과 크게 관련 없을 것입니다.

```yaml
version: "3.8"
```

## 2) `services`

`services`의 하위 자식들은 container가 될 것이며, 각각의 container는 이름을 마음대로 지정할 수 있습니다.

```yaml
services:
    db:
    backend:
    frontend:
```

물론 실행되는 container의 실제 이름은 `[프로젝트 이름]_[service 이름]_1`과 같은 텍스트가 추가되어 변경되지만, 도커 내부적으로는 작성한 이름 그대로 사용하니 걱정하지 마세요.

-   주의: 서로 네트워킹하려는 service의 domain을 이 이름으로 작성해놨는지 확인합시다. 그래야 내부적으로 docker가 ip로 변환해줍니다.

### service 하위 설정들(image, container)

각 container의 default 설정: `-d`, `--rm`

-   `image`: background image(혹은 주소)
-   `volumes`: `-v` 이후에 작성할 것들
    -   anonymous volumes: `[container의 절대 경로]`만 입력합니다.
    -   named volumes: `[name]:[container의 절대 경로]`로 입력합니다. container 실행 시 volume의 이름은 `프로젝트 이름_name`으로 결정됩니다.
    -   bind mounts: `[프로젝트의 상대 경로]:[container 절대 경로]`를 입력하면, 자동으로 절대 경로 처리를 해줍니다. 이게 또다른 Docker Compose의 장점이죠!
-   `container_name`: service의 이름과 다르게 container name이 변경되는 것이 싫다면 여기서 직접 결정할 수 있습니다.
-   `environment`: `-e` 이후에 작성할 것들.
    -   `:` 혹은 `=`로 값을 정할 수 있습니다.
-   `env_file`: 이 것으로 `environment` 없이 `.env` file로 대체할 수도 있습니다. 상대경로를 입력합니다.
-   `networks`: 이건 굳이 입력할 필요는 없습니다. `docker-compose` 파일 내에서 선언된 container(image)는 자동으로 동일한 자체 network에 연결되기 때문입니다. 그래도 작성하면 default network 뿐만 아니라 우리가 선언한 자체 네트워크에도 연결됩니다. container 실행 시 network 이름은 `[프로젝트 이름]_[default 혹은 network 이름]`으로 결정됩니다.
-   `build`: 빌드할 `Dockerfile`을 찾도록 경로를 입력합니다.

    ```yaml
    # 빌드 파일의 이름이 Dockerfile인 경우 shortcut
    container 이름:
    	build: ./backend

    # 길게 작성: 빌드 파일의 이름이 다르거나, Dockerfile이 복사하기 위해 참조할 파일들이 Dockerfile의 상단에도 있을 경우
    container 이름:
    	build:
    		context: ./backend
    		dockerfile: Dockerfile-dev
    ```

-   `depends_on`: 실행 중인 다른 container에 의존해야 할 때, 리스트 형태로 해당 container name을 입력합니다. 의존하는 컨테이너가 실행되고 나서야 자신이 실행됩니다

-   `-it` 활성화
    ```yaml
    stdin_open: true
    tty: true
    ```

## 3) `volumes`

named volumes을 container에서 작성했을 경우에만 최상단에 다음과 같이 name을 적어주어야 합니다

```yaml
volumes:
	data:
	logs:
```
