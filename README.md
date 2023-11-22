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

`EXPOSE`를 사용했던 경우, -p 태그를 추가하여 host port와 대응되어 열어줄 container port를 작성해야 함

```bash
docker run -p [HOST포트:Container포트] [image 이름]
```

# 2. Image, Container의 여러 옵션과 명령어들

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

# 3. 이미지 공유하기

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

# 4. 데이터 관리 및 볼륨(volume)

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

-   Anonymous volumes: 우리가 모르는 어떤 HOST 경로에 container 경로가 매핑됩니다. 해당 HOST 경로를 정학히 알 수 없으며, container가 shut down 되면 사라집니다. 이 경우에는 `Dockerfile`에 미리 작성합니다. 물론 container를 실행할 때도 작성할 수 있습니다.

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
