FROM golang

# Install beego bee tool
RUN go get -u github.com/beego/bee

# Enable module management
ENV GO111MODULE=on
ENV GOFLAGS=-mod=vendor

# IDs should match the user's
ARG GROUP_ID
ARG USER_ID

# Create matching user in container
RUN groupadd --gid $GROUP_ID app
RUN useradd --uid $USER_ID --gid $GROUP_ID app
RUN mkdir -p /home/app
RUN mkdir -p /go/src/mathapp
RUN chown -R app:app /home/app
RUN chown -R app:app /go

USER app
WORKDIR /go/src/mathapp

EXPOSE 8010

CMD ["bee", "run"]