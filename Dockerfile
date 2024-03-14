FROM ubuntu:focal-20240216

ENV NODE_ENV=production
ENV VSCODE_REH_WEB_PORT=8080
ENV VSCODE_REH_WEB_HOST=0.0.0.0

RUN apt-get update \
    && apt-get -qq install -y --no-install-recommends \
    ca-certificates tini git \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node \
    && mkdir /app \
    && chown -R node:node /app

COPY vscode-reh-web-linux-x64.tar.gz /tmp/vscode-reh-web-linux-x64.tar.gz
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN tar -xzf /tmp/vscode-reh-web-linux-x64.tar.gz -C /app \
	&& rm /tmp/vscode-reh-web-linux-x64.tar.gz \
	&& chown -R node:node /app/vscode-reh-web-linux-x64 \
	&& chmod +x /app/vscode-reh-web-linux-x64/bin/code-server-oss \
	&& chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /app/vscode-reh-web-linux-x64

# Add extensionsGallery settings to product.json using jq command
RUN apt-get update \
    && apt-get -qq install -y --no-install-recommends jq \
    && jq '. + {"extensionsGallery": {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery", "itemUrl": "https://marketplace.visualstudio.com/items", "cacheUrl": "https://vscode.blob.core.windows.net/gallery/index", "recommendationsUrl": "https://marketplace.visualstudio.com/_apis/public/recommendations", "recommenderUrl": "https://marketplace.visualstudio.com/_apis/public/recommender"}}' product.json > tmp.json \
    && mv tmp.json product.json \
    && apt-get remove -y jq \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

USER node

EXPOSE $VSCODE_REH_WEB_PORT

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
