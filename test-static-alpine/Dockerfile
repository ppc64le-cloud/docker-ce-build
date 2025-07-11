FROM public.ecr.aws/docker/library/golang:1.24.3-alpine3.21

WORKDIR /workspace
ENV WORKSPACE=/workspace \
    TERM=xterm

# https://github.com/docker/docker/blob/master/project/PACKAGERS.md#runtime-dependencies
RUN set -eux; \
	apk add --no-cache \
		bash \
                libc6-compat \
                make \
                musl-dev \
                openssh-client \
		btrfs-progs \
		e2fsprogs \
		e2fsprogs-extra \
                gcc \
		ip6tables \
		iptables \
		openssl \
		shadow-uidmap \
		xfsprogs \
		xz \
		pigz \
	; \
# only install zfs if it's available for the current architecture
# https://git.alpinelinux.org/cgit/aports/tree/main/zfs/APKBUILD?h=3.6-stable#n9 ("all !armhf !ppc64le" as of 2017-11-01)
# "apk info XYZ" exits with a zero exit code but no output when the package exists but not for this arch
	if zfs="$(apk info --no-cache --quiet zfs)" && [ -n "$zfs" ]; then \
		apk add --no-cache zfs; \
	fi

COPY docker-ppc64le.tgz /workspace
COPY test-launch.sh /usr/local/bin/test-launch.sh

RUN set -eux; \
	tar --extract \
		--file docker-ppc64le.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker-ppc64le.tgz; \
	\
	dockerd --version; \
	docker --version

# set up subuid/subgid so that "--userns-remap=default" works out-of-the-box
RUN set -eux; \
	addgroup -S dockremap; \
	adduser -S -G dockremap dockremap; \
	echo 'dockremap:165536:65536' >> /etc/subuid; \
	echo 'dockremap:165536:65536' >> /etc/subgid

ENV MODPROBE_COMMIT 387e351394bfad74bceebf8303c6c8e39c3d4ed4
# https://github.com/docker/docker/tree/master/hack/dind
ENV DIND_COMMIT 8d9e3502aba39127e4d12196dae16d306f76993d
# ENV DIND_COMMIT 8d9e3502aba39127e4d12196dae16d306f76993d
ENV DOCKERD_COMMIT 52c8bfa9869c9c5605c6c03dc9a82cfe426ace77
# ENV DOCKERD_COMMIT 52c8bfa9869c9c5605c6c03dc9a82cfe426ace77

RUN set -eux; \
	wget -O /usr/local/bin/modprobe "https://raw.githubusercontent.com/docker-library/docker/${MODPROBE_COMMIT}/20.10/modprobe.sh"; \
        wget -O /usr/local/bin/dind "https://raw.githubusercontent.com/docker/docker/${DIND_COMMIT}/hack/dind"; \
        wget -O /usr/local/bin/dockerd-entrypoint.sh "https://raw.githubusercontent.com/docker-library/docker/${DOCKERD_COMMIT}/28/dind/dockerd-entrypoint.sh"; \
	chmod +x /usr/local/bin/dind; \
        chmod +x /usr/local/bin/dockerd-entrypoint.sh; \
	chmod +x /usr/local/bin/test-launch.sh;

# https://github.com/docker-library/docker/pull/166
#   dockerd-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-generating TLS certificates
#   docker-entrypoint.sh uses DOCKER_TLS_CERTDIR for auto-setting DOCKER_TLS_VERIFY and DOCKER_CERT_PATH
# (For this to work, at least the "client" subdirectory of this path needs to be shared between the client and server containers via a volume, "docker cp", or other means of data sharing.)
ENV DOCKER_TLS_CERTDIR=/certs
# also, ensure the directory pre-exists and has wide enough permissions for "dockerd-entrypoint.sh" to create subdirectories, even when run in "rootless" mode
RUN mkdir /certs /certs/client && chmod 1777 /certs /certs/client
# (doing both /certs and /certs/client so that if Docker does a "copy-up" into a volume defined on /certs/client, it will "do the right thing" by default in a way that still works for rootless users)

VOLUME /var/lib/docker
EXPOSE 2375 2376

ENTRYPOINT ["/usr/local/bin/test-launch.sh"]
CMD []