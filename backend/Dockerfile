# STEP 1: Build the binary
FROM golang:1.21-alpine AS builder

# Install git and certificates (needed for some Go modules)
RUN apk add --no-cache git ca-certificates

WORKDIR /app

# Copy dependency files first for better caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the application
# We use CGO_ENABLED=0 to create a static binary that runs anywhere
RUN CGO_ENABLED=0 GOOS=linux go build -o main ./cmd/api/main.go

# STEP 2: Create the small run-time image
FROM alpine:latest
RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from the builder stage
COPY --from=builder /app/main .

# Expose the port your app runs on
EXPOSE 8080

# Command to run the application
CMD ["./main"]