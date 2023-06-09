FROM public.ecr.aws/lambda/provided:al2 AS build

ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Get rid of the extension warning
RUN mkdir -p /opt/extensions
RUN yum -y install golang
RUN go env -w GOPROXY=direct

# Clone git, copying go.mod, go.sum, main.go
WORKDIR /var/task/
RUN yum install git -y
RUN git clone https://github.com/seedspirit/lambda-cicd-go.git
RUN cp lambda-cicd-go/main.go /var/task/
RUN cp lambda-cicd-go/go.mod /var/task/
RUN cp lambda-cicd-go/go.sum /var/task/

# cache dependencies
RUN go mod download
RUN go build -o main .

FROM public.ecr.aws/lambda/provided:al2
COPY --from=build /var/task/main /var/task/main
ENTRYPOINT ["/var/task/main"]