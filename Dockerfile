# Swift server (Hummingbird 2) built in release mode.
# The binary links the Swift runtime and Foundation statically, so the runtime
# image is plain Ubuntu with no Swift toolchain in it.

# ---- build: resolve dependencies first so that layer caches --------------------
FROM swift:6.3-noble AS build
WORKDIR /src
COPY Package.swift Package.resolved ./
RUN swift package resolve
COPY Sources ./Sources
COPY Tests ./Tests
RUN swift build -c release --static-swift-stdlib --product todo-server \
 && cp "$(swift build -c release --show-bin-path)/todo-server" /src/todo-server

# ---- runtime ----------------------------------------------------------------
FROM ubuntu:noble AS runtime
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates tzdata \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --uid 10001 --no-create-home --shell /usr/sbin/nologin app
COPY --from=build /src/todo-server /usr/local/bin/todo-server
ENV PORT=8080
EXPOSE 8080
USER app
# No curl in the image: bash's /dev/tcp checks that the port accepts connections.
HEALTHCHECK --interval=30s --timeout=3s CMD ["/bin/bash", "-c", "exec 3<>/dev/tcp/127.0.0.1/${PORT}"]
CMD ["todo-server"]
