# Multi-stage Dockerfile for LeafWise React Native Application
# Supports development, staging, and production builds
# Optimized for CI/CD pipelines and containerized deployments

# Base Node.js image
FROM node:18-alpine AS base

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apk add --no-cache \
    git \
    python3 \
    make \
    g++ \
    && rm -rf /var/cache/apk/*

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && npm cache clean --force

# Development stage
FROM base AS development

# Install all dependencies (including dev dependencies)
RUN npm ci

# Install Expo CLI globally
RUN npm install -g @expo/cli

# Copy source code
COPY . .

# Expose development server port
EXPOSE 19000 19001 19002

# Set environment
ENV NODE_ENV=development
ENV EXPO_PUBLIC_ENV=development

# Start development server
CMD ["npm", "start"]

# Build stage
FROM base AS builder

# Install all dependencies for building
RUN npm ci

# Install Expo CLI globally
RUN npm install -g @expo/cli

# Copy source code
COPY . .

# Build argument for environment
ARG BUILD_ENV=production
ENV EXPO_PUBLIC_ENV=${BUILD_ENV}

# Run quality checks
RUN npm run type-check
RUN npm run lint
RUN npm test -- --passWithNoTests

# Build the application
RUN npm run build:${BUILD_ENV}

# Production stage
FROM nginx:alpine AS production

# Install Node.js for serving
RUN apk add --no-cache nodejs npm

# Copy built application
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration
COPY config/nginx.conf /etc/nginx/nginx.conf

# Create nginx user and set permissions
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
RUN chown -R nextjs:nodejs /usr/share/nginx/html
RUN chown -R nextjs:nodejs /var/cache/nginx
RUN chown -R nextjs:nodejs /var/log/nginx
RUN chown -R nextjs:nodejs /etc/nginx/conf.d
RUN touch /var/run/nginx.pid
RUN chown -R nextjs:nodejs /var/run/nginx.pid

# Switch to non-root user
USER nextjs

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]

# CI/CD stage for testing and building
FROM base AS ci

# Install all dependencies
RUN npm ci

# Install additional CI tools
RUN npm install -g @expo/cli
RUN apk add --no-cache curl

# Copy source code
COPY . .

# Set CI environment
ENV CI=true
ENV NODE_ENV=test

# Default command for CI
CMD ["npm", "run", "ci"]