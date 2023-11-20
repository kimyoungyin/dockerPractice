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
