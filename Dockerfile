ARG PROJECT_NAME=server
ARG CONTAINER_PORT=50051

FROM clux/muslrust as builder


ARG PROJECT_NAME
ARG VA_REGISTRY

WORKDIR /volume/src


COPY . .
#COPY  ${PROJECT_NAME}/sqlx-data.json ./sqlx-data.json





ENV CARGO_REGISTRIES_VA_REGISTRY_INDEX=$VA_REGISTRY

RUN rustup component add rustfmt
#RUN rustup target add x86_64-unknown-linux-musl
RUN cargo build --release --package helloworld-tonic --bin server

#RUN cargo install --target x86_64-unknown-linux-musl --path .



FROM alpine:3.15
ARG PROJECT_NAME
COPY --from=builder /volume/src/target/x86_64-unknown-linux-musl/release/${PROJECT_NAME} /usr/local/bin/${PROJECT_NAME}





#RUN apk add --update openssl
#RUN apk add --update libpq-dev
#RUN apk add gettext



# Install packages and add non-root user
RUN apk --no-cache add curl ca-certificates \
&& addgroup -S app && adduser -S -g app app
ENV USER=app

ARG PROJECT_NAME
ARG CONTAINER_PORT
ENV SERVICE_PATH="/usr/local/bin/${PROJECT_NAME}"



ARG PROJECT_NAME

WORKDIR /home/app
#COPY .env ./env
#COPY ./data-model/${MIGRATION_DIR} ./migrations
#COPY ./configuration  .
#COPY ${PROJECT_NAME}/config  ./config
#RUN mv ./config/nats-config   ./config/nats-conf


EXPOSE 8080


#COPY ./sqlx   /usr/local/bin/sqlx
#RUN  chmod +x /usr/local/bin/sqlx
#
#COPY ./handler.sh  ./handler
#COPY ./handler.sh  ./handler.sh
#COPY ./start_up.sh ./start_up.sh
#
#RUN chmod +x ./handler
#RUN chmod +x ./handler.sh
#RUN chmod +x ./start_up.sh

CMD  ["server"]