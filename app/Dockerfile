FROM python:3.8-slim-buster
COPY requirements.txt /app/
WORKDIR /app/
RUN pip install -r requirements.txt
COPY config.json /app/
COPY app.py /app/
EXPOSE 8080
CMD ["python", "app.py"]
