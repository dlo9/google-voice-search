FROM alpine:20200917
RUN apk --no-cache add curl coreutils parallel jq
COPY scripts/ /scripts/
WORKDIR /scripts
ENTRYPOINT ./voice-search.sh
