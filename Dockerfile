FROM hugomods/hugo:latest

WORKDIR /app

COPY . /app

RUN git clone https://github.com/vaga/hugo-theme-m10c.git themes/hugo-theme-m10c

EXPOSE 2000

CMD ["hugo", "server", "--bind", "0.0.0.0", "--port", "2000", "--watch", "--disableFastRender", "--navigateToChanged"]
