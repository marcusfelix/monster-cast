FROM ghcr.io/cirruslabs/flutter as flutter

WORKDIR /app

ARG SERVER_URL="http://localhost:8090"

ENV ENV_SERVER_URL $SERVER_URL

ARG ENVIRONMENT="development"

ENV ENV_ENVIRONMENT $ENVIRONMENT

COPY /app ./

RUN flutter pub get

RUN flutter pub run icons_launcher:create

RUN flutter build web --release --dart-define=SERVER_URL=$ENV_SERVER_URL --dart-define=ENVIRONMENT=$ENVIRONMENT --no-tree-shake-icons

# --

FROM golang:1.18-alpine as builder

RUN apk add git

WORKDIR /app

COPY . .

COPY --from=flutter /app/build/web ./app/build/web

COPY go.mod go.sum ./

RUN go mod download

RUN CGO_ENABLED=0 GOOS=linux go build -buildvcs=false -a -installsuffix cgo -o main .

# --

FROM alpine:latest

RUN apk --no-cache add ca-certificates curl

WORKDIR /app

COPY --from=builder /app/main ./

VOLUME /app/pb_data

EXPOSE 8090

CMD ["./main", "serve", "--http=0.0.0.0:8090"]