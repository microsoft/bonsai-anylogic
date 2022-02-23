#from JRE
FROM openjdk:8-jre-alpine

# required for fonts in AL models
RUN apk --update add fontconfig ttf-dejavu

COPY ./exported.zip .
RUN unzip -q exported.zip

CMD find -name '*_linux.sh' -exec sh {} \;
