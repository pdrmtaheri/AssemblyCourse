FROM debian:stable-slim

ENV TERM xterm

RUN apt update && apt install -qy nasm gcc gdb vim

CMD tail -f /dev/null
