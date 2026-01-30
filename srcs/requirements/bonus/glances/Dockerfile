FROM debian:bullseye

RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Install Glances AND the new required web libraries
RUN pip3 install --no-cache-dir glances fastapi uvicorn

EXPOSE 61208

CMD ["glances", "-w"]
