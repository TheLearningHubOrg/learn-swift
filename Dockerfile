# Multi-stage Dockerfile for Swift Application
FROM swift:6.0-jammy AS builder

WORKDIR /build
COPY Package.swift ./
COPY Sources ./Sources
COPY Tests ./Tests

RUN swift build -c release
RUN swift test

FROM swift:6.0-jammy-slim AS runner
WORKDIR /app

COPY --from=builder /build/.build/release/LearnSwift .

ENTRYPOINT ["./LearnSwift"]
