# Build stage
FROM golang:1.25-alpine AS builder

WORKDIR /app

# Copy go mod files first for better caching
COPY go.mod go.sum* ./
RUN go mod download

# Copy source code and build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /gokabot-api ./cmd/gokabot

# Runtime stage
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /gokabot-api /gokabot-api

EXPOSE 8081

ENTRYPOINT ["/gokabot-api"]
