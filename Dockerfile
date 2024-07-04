FROM node:20 as builder

LABEL version="1.0.0"
LABEL description="Consumet API (fastify) Docker Image"

# Update packages, install curl for health checks, and reduce the risk of vulnerabilities
RUN apt-get update && \
    apt-get install -y curl && \
    apt-get upgrade -y && \
    apt-get autoclean -y && \
    apt-get autoremove -y

# Set a non-privileged user to use when running this image
RUN groupadd -r nodejs && \
    useradd -g nodejs -s /bin/bash -d /home/nodejs -m nodejs && \
    mkdir -p /home/nodejs/app/node_modules && \
    chown -R nodejs:nodejs /home/nodejs/app

USER nodejs
WORKDIR /home/nodejs/app

# Set default node environment
ARG NODE_ENV=PROD
ARG PORT=3000
ENV NODE_ENV=${NODE_ENV}
ENV PORT=${PORT}
ENV REDIS_HOST=${REDIS_HOST}
ENV REDIS_PORT=${REDIS_PORT}
ENV REDIS_PASSWORD=${REDIS_PASSWORD}
ENV NPM_CONFIG_LOGLEVEL=warn

# Copy project definition/dependencies files, for better reuse of layers
COPY --chown=nodejs:nodejs package*.json ./

# Install dependencies here, for better reuse of layers
RUN npm install && npm update && npm cache clean --force

# Copy all sources in the container (exclusions in .dockerignore file)
COPY --chown=nodejs:nodejs . .

# Exposed ports
EXPOSE 3000

# Add an healthcheck
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s \
    CMD curl --fail http://localhost:${PORT}/health || exit 1

# Define the command to run your app
CMD ["npm", "start"]

# End of Dockerfile
