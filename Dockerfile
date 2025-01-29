FROM hugomods/hugo:latest

WORKDIR /app
COPY . /app
EXPOSE 2000

CMD ["server", "--bind", "0.0.0.0", "--port", "2000", "--watch"]
