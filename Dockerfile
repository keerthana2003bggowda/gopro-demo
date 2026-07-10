FROM golang:1.26.4 AS build
WORKDIR /app
COPY . .
RUN go build -o main .

FROM alpine:latest
COPY --from=build /app/main .
CMD ["./main"] 