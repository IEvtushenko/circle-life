FROM golang:alpine

ENV APP_NAME testproject
ENV PORT 9081

COPY main.go /src/
WORKDIR /src

RUN go build -o ${APP_NAME}

CMD ./${APP_NAME}

EXPOSE ${PORT}