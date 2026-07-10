FROM golang:1.26.4
WORKDIR /app
COPY . .
RUN go build -o main .
EXPOSE 3001
CMD ["./main"]