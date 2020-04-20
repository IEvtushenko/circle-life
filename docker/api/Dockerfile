FROM golang:latest as builder

ENV PORT 9081

WORKDIR /src
COPY /api /src/

RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

######## Start a new stage #######
FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /src/
COPY --from=builder /src/main .
EXPOSE ${PORT}
CMD ["./main"]