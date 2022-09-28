FROM registry.fedoraproject.org/fedora:latest

RUN dnf -y update && \
    rpm --setcaps shadow-utils 2>/dev/null && \
    dnf -y install make skopeo fuse-overlayfs \
        --exclude container-selinux && \
    dnf clean all && \
    rm -rf /var/cache /var/log/dnf* /var/log/yum.*

RUN useradd skopeo && \
    echo skopeo:100000:65536 > /etc/subuid && \
    echo skopeo:100000:65536 > /etc/subgid

RUN sed -e 's|^#mount_program|mount_program|g' \
        -e '/additionalimage.*/a "/var/lib/shared",' \
        -e 's|^mountopt[[:space:]]*=.*$|mountopt = "nodev,fsync=0"|g' \
        /usr/share/containers/storage.conf \
        > /etc/containers/storage.conf

RUN mkdir -p /var/lib/shared/overlay-images \
             /var/lib/shared/overlay-layers && \
    touch /var/lib/shared/overlay-images/images.lock && \
    touch /var/lib/shared/overlay-layers/layers.lock

ENV REGISTRY_AUTH_FILE=/tmp/auth.json