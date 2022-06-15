# Hands-on Docker-11 : Build images with ENV and ARG instructions

Purpose of the this hands-on training is to give the students understanding to ENV and ARG instructions in Dockerfile

## Learning Outcomes

- At the end of the this hands-on training, students will be able to;

- Learn `ENV` form and `ARG` instruction. 

- Build images with ENV` form and `ARG` instruction.

## Outline

- Part 1 - Create an image for publishing a web page from nginx image

- Part 2 - Create an image with `ENV` instructions for publishing a web page from nginx image

- Part 3 - Create an image with `ARG` instructions for publishing a web page from nginx image

## Part 1 - Create an image for publishing a web page from nginx image

- Create a folder and name it clarusweb.

```bash
mkdir clarusweb && cd clarusweb
```

- In clarusweb folder, create another folder named clarusweb-nginx.

```bash
mkdir clarusweb-nginx && cd clarusweb-nginx
```

- Create an index.html file.

```bash
echo "<h1>Welcome to Clarusway<h1>" > index.html
```

- Create a Dockerfile and input following statements.

```txt
FROM nginx:alpine
COPY . /usr/share/nginx/html
```

- Build an image from this Dockerfile.

```bash
docker build -t <userName>/clarusweb:nginx .
```

- Run this image and check the result in your browser.

```bash
docker run --name clarusweb -dp 80:80 <userName>/clarusweb:nginx
```

- Remove container

```bash
docker container rm -f clarusweb
```

## Part 2 - Create an image with `ENV` instruction for publishing a web page from nginx image

- In clarusweb folder, create another folder named clarusweb-env.

```bash
cd ..
mkdir clarusweb-env && cd clarusweb-env
```

- Create an clarusweb.html file and input following statements. Pay attention to `COLOR` statement. We will change background color with `env`.

```txt
<html>
<head>
<title>clarusweb</title>
</head>
<body style="background-color:COLOR;">
<h1>Welcome to Clarusway<h1>
</body>
</html>
```

- Create a Dockerfile and input following statements.

```txt
FROM nginx:latest
ENV COLOR="red"
RUN apt-get update ; apt-get install curl -y
WORKDIR /usr/share/nginx/html
COPY . /usr/share/nginx/html
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost/ || exit 1
CMD sed -e s/COLOR/"$COLOR"/ clarusweb.html > index.html ; rm clarusweb.html ; nginx -g 'daemon off;'
```

- Build an image from this Dockerfile.

```bash
docker build -t <userName>/clarusweb:env .
```

- Run this image without environment variable and see in browser that the background is red.

```bash
docker run --name clarusweb-env -dp 80:80 <userName>/clarusweb:env
```

- Run same image with the environment variable (for example blue) and see in browser that the background is blue.

```bash
docker run --name clarusweb-blue --env COLOR=blue -dp 81:80 <userName>/clarusweb:env
```

- Remove all containers.

```bash
docker rm -f $(docker ps -aq)
```

## Part 3 - Create an image with `ARG` instruction for publishing a web page from nginx image

- In clarusweb folder, create another folder named clarusweb-arg.

```bash
cd ..
mkdir clarusweb-arg && cd clarusweb-arg
```

- Create an clarusweb.html file and input following statements. Pay attention to `COLOR` statement. We will change background color with `ARG` instructions during the build phase.

```txt
<html>
<head>
<title>clarusweb</title>
</head>
<body style="background-color:COLOR;">
<h1>Welcome to Clarusway<h1>
</body>
</html>
```

- Create a Dockerfile and input following statements.

```txt
FROM nginx:latest
ARG COLOR="pink"
RUN apt-get update ; apt-get install curl -y
WORKDIR /usr/share/nginx/html
COPY . /usr/share/nginx/html
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 CMD curl -f http://localhost/ || exit 1
RUN sed -e s/COLOR/"$COLOR"/ clarusweb.html > index.html ; rm clarusweb.html
CMD  nginx -g 'daemon off;'
```

- Build an image from this Dockerfile.

```bash
docker build -t <userName>/clarusweb:arg .
```

- Run this image and see in browser that the background is pink.

```bash
docker run --name clarusweb-arg -dp 80:80 <userName>/clarusweb:arg
```

- Build an image from this Dockerfile with `build-arg` variable.

```bash
docker build -t <userName>/clarusweb:arg-gray --build-arg COLOR=gray .
```

- Run this image and see in browser that the background is gray.

```bash
docker run --name clarusweb-arg-gray -dp 81:80 <userName>/clarusweb:arg-gray
```

- Remove all containers.

```bash
docker rm -f $(docker ps -aq)
```