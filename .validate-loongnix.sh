#!/usr/bin/env bash
set -Eeuo pipefail

dockerImage="$(./.docker-image.sh)"
dockerImage+='-loongnix'
SUITE=DaoXiangHu-stable
{
	cat Dockerfile - <<-'EODF'
		RUN set -eux; \
# https://bugs.debian.org/929165 :(
			wget -O debian-keyring.deb 'http://pkg.loongnix.cn/loongnix/pool/main/d/debian-keyring/debian-keyring_2019.02.25+nmu1_all.deb'; \
			echo 'dd9b71964a1e7d39ef0db6c24b15ffd18f097827 *debian-keyring.deb' | sha1sum --strict --check -; \
			apt-get install -y --no-install-recommends ./debian-keyring.deb; \
			rm debian-keyring.deb
	EODF
} | docker build --pull --tag "$dockerImage" --file Dockerfile.loong64 .

mkdir -p validate

set -x

./scripts/debuerreotype-version
./docker-run.sh --image="$dockerImage" --no-build ./examples/loongnix.sh validate "$SUITE"