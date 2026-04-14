FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    socat \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY mitmsqlproxy.py .

RUN chmod +x mitmsqlproxy.py

EXPOSE 1433 212

CMD ["sh", "-c", "LOGFILE=/logs/mitmsqlproxy_$(date +%Y%m%d_%H%M%S).log && \
      python mitmsqlproxy.py 10.200.22.210 -port 1433 -lport 1433 --log $LOGFILE -d --skip-server-check -r '(?i)SELECT' & \
      socat TCP-LISTEN:212,fork,reuseaddr TCP:10.200.22.210:212 & \
      tail -f /dev/null"]
