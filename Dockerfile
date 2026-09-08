FROM python:3.11-slim

RUN apt-get update && apt-get upgrade -y && \
    pip install --upgrade "jaraco.context>=6.1.0" "wheel>=0.46.2" && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m myuser

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY main.py .

RUN chown -R myuser:myuser /app

USER myuser

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]