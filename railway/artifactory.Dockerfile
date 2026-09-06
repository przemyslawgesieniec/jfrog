# Artifactory OSS dla Railway.
#
# Railway buduje z kontekstem = korzeń repozytorium, a ten plik wskazujesz
# zmienną serwisu:
#
#     RAILWAY_DOCKERFILE_PATH=railway/artifactory.Dockerfile
#
# Wersja jest przypięta świadomie. `latest` potrafi z dnia na dzień zmienić
# wymagania (tak zniknęło wsparcie dla bazy Derby), a wtedy deploy pada bez
# ostrzeżenia. 7.161.20 to wersja zweryfikowana lokalnie z PostgreSQL.
FROM releases-docker.jfrog.io/jfrog/artifactory-oss:7.161.20

USER root

# Railway's HTTP edge reliably targets $PORT/8080 for CLI-uploaded services.
# Keep Artifactory on its normal router port and expose a tiny TCP forwarder.
RUN apt-get update \
    && apt-get install -y --no-install-recommends socat \
    && rm -rf /var/lib/apt/lists/*

COPY railway/artifactory-entrypoint.sh /usr/local/bin/artifactory-entrypoint.sh
RUN chmod +x /usr/local/bin/artifactory-entrypoint.sh

# Railway routes public HTTP to $PORT/8080; the wrapper forwards that traffic
# to the normal JFrog router port 8082.
EXPOSE 8080
EXPOSE 8082

ENTRYPOINT ["/usr/local/bin/artifactory-entrypoint.sh"]
