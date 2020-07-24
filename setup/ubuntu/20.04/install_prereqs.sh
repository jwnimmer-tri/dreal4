#!/bin/bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo 'This script must be run as root' >&2
  exit 1
fi
apt-get update
apt-get install -y --no-install-recommends software-properties-common
add-apt-repository ppa:dreal/dreal -y  # For libibex-dev
apt-get update
apt-get install -y --no-install-recommends $(tr '\n' ' ' <<EOF
bison
coinor-libclp-dev
g++
libfl-dev
libgmp-dev
libibex-dev
libnlopt-cxx-dev
libpython3-dev
pkg-config
python3-distutils
python3-minimal
zlib1g-dev
EOF
)

# Install bazel
BAZEL_VERSION=3.4.1
BAZEL_DEBNAME=bazel_${BAZEL_VERSION}-linux-x86_64.deb
BAZEL_URL=https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/${BAZEL_DEBNAME}
BAZEL_SHA256=dc8f51b7ed039d57bb990a1eebddcbb0014fe267a88df8972f4609ded1f11c90
apt-get install -y --no-install-recommends wget
wget "${BAZEL_URL}"
if echo "${BAZEL_SHA256}  ${BAZEL_DEBNAME}" | sha256sum -c; then
    dpkg --install --skip-same-version ./"${BAZEL_DEBNAME}" || apt-get -f install -y
    rm "${BAZEL_DEBNAME}"
else
    echo "SHA256 does not match ${BAZEL_DEBNAME}:"
    echo "    expected: ${BAZEL_SHA256}"
    echo "    actual  : $(sha256sum "${BAZEL_DEBNAME}")"
    exit 1
fi
