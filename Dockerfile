FROM hugomods/hugo:latest

WORKDIR /app
COPY . /app
EXPOSE 1313

CMD ["server", "--bind", "0.0.0.0", "--port", "1313", "--watch"]
