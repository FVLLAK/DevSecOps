# syntax=docker/dockerfile:1
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
COPY wheels/ /wheels/                          # <-- ajouté
RUN pip install --no-index --find-links=/wheels -r requirements.txt

COPY . .
CMD ["python", "app.py"]
