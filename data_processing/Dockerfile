# Use official lightweight Python 3.11 image as the base
FROM python:3.11-slim

# Set working directory inside the container
WORKDIR /app

# Copy dependency list first to leverage Docker layer caching
COPY requirements.txt .

# Install Python dependencies without caching to keep image slim
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code and required resources into the image
COPY app.py .
COPY words.txt .

# Run the application with unbuffered output for real-time logs
CMD ["python3", "-u", "app.py"]