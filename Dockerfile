FROM alpine

RUN apk --no-cache add \
        curl \
        bash

ADD upload.sh /bin/
RUN chmod +x /bin/upload.sh

ENTRYPOINT /bin/upload.sh
