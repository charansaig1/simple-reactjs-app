# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/go/dockerfile-reference/

# Want to help us make this template better? Share your feedback here: https://forms.gle/ybq9Krt8jtBL3iCk7

ARG NODE_VERSION=22.13.0

################################################################################
# Use node image for base image for all stages.
FROM node:16


# Set working directory for all build stages.
WORKDIR /usr/src/app


# Copy package.json and package-lock.json first for caching
COPY package*.json ./

################################################################################



# Download additional development dependencies before building, as some projects require
# "devDependencies" to be installed to build. If you don't need this, remove this step.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci

# Copy the rest of the source files into the image.
COPY . .
# Run the build script.
RUN npm install

RUN npm run build

################################################################################
# # Create a new stage to run the application with minimal runtime dependencies
# # where the necessary files are copied from the build stage.
# FROM base as final

# # Run the application as a non-root user.
# USER node




# Copy the .env file
COPY .env .env

# Set environment variable for the port from .env file
RUN export $(cat .env | grep APP_PORT) && echo "Using port $APP_PORT"

# Set the port for the application.
ENV NODE_OPTIONS=--openssl-legacy-provider

EXPOSE $APP_PORT

# Run the application.
CMD npm start
