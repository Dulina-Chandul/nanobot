FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY pyproject.toml .
RUN pip install --no-cache-dir .

# Copy the nanobot code
COPY nanobot/ ./nanobot/

# Create startup script that creates config from env vars
COPY <<EOF /start.sh
#!/bin/sh
set -e

# Create config directory
mkdir -p /root/.nanobot

# Create config.json from environment variables
cat > /root/.nanobot/config.json <<EOF_CONFIG
{
  "providers": {
    "openrouter": {
      "apiKey": "${OPENROUTER_API_KEY}"
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "token": "${TELEGRAM_BOT_TOKEN}",
      "allowFrom": ["${TELEGRAM_USER_ID}"]
    }
  },
  "agents": {
    "defaults": {
      "model": "openrouter/deepseek/deepseek-r1",
      "provider": "openrouter"
    }
  }
}
EOF_CONFIG

# Start NanoBot gateway
exec nanobot gateway
EOF

# Make startup script executable
RUN chmod +x /start.sh

# Set the startup script as entry point
ENTRYPOINT ["/start.sh"]

# Expose the gateway port
EXPOSE 18790
