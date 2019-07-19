FROM debian:stable-slim

ENV TERM xterm

RUN dpkg --add-architecture i386 && apt update && apt install -qy nasm gcc gdb vim

CMD tail -f /dev/null
