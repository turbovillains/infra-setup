ARG DOCKER_HUB
ARG GATSBY_BASE

FROM ${DOCKER_HUB}/${GATSBY_BASE}

LABEL org.opencontainers.image.authors="Noroutine GmbH <info@noroutine.me>"

COPY nginx-boot.sh /sbin/nginx-boot
RUN chmod +x /sbin/nginx-boot

RUN apk --update add nginx bash && \
    rm -fR /var/cache/apk/*

CMD [ "/sbin/nginx-boot" ]
EXPOSE 80