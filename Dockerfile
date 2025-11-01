FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt .
# on copie les wheels téléchargés par le stage Jenkins
COPY wheels/ /wheels/
RUN pip install --no-index --find-links=/wheels -r requirements.txt

COPY . .
CMD ["python", "app.py"]
