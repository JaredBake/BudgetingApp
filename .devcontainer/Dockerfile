FROM mcr.microsoft.com/devcontainers/dotnet:1-9.0-bookworm

# Enable noninteractive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_SDK_ROOT=/usr/lib/flutter
ENV FLUTTER_SDK_VERSION=3.38.1-stable
ENV PATH="${PATH}:${FLUTTER_SDK_ROOT}/bin"
# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends  curl git unzip xz-utils zip libglu1-mesa

# Add flutter to safe directory in git
RUN git config --global --add safe.directory /usr/lib/flutter

# Insall Flutter SDK
RUN mkdir -p ${FLUTTER_SDK_ROOT} && \
    cd ${FLUTTER_SDK_ROOT} && \
    curl -OL https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_SDK_VERSION}.tar.xz && \
    tar -xf flutter_linux_${FLUTTER_SDK_VERSION}.tar.xz -C /usr/lib/ && \
    rm -rf flutter_linux_${FLUTTER_SDK_VERSION}.tar.xz

# Disable Flutter telemetry
#RUN flutter --disable-analytics
# [Optional] Uncomment this line to install global node packages.
# RUN su vscode -c "source /usr/local/share/nvm/nvm.sh && npm install -g <your-package-here>" 2>&1