import random
from datetime import datetime

# Generate a synthetic IoT message with deliberately inconsistent formats


def generate_raw_message():
    """
    Create a messy IoT payload that simulates schema drift and varied data types.
    Useful for testing normalisation, validation, and ingestion robustness.
    """
    return {
        # Random sensor identifier across temperature, humidity, and pressure sensors
        "sensorId": random.choice([
            "T-001", "T-002", "T-003",
            "H-009", "H-010", "H-011",
            "P-221", "P-222"
        ]),
        # Device status in inconsistent formats to test cleaning logic
        "device_status": random.choice([
            "OK", "ok", "Ok", "OK!", "Good", "GOOD", "Healthy", "Available",
            "ERROR",
            "WARNING"
        ]),
        # Temperature values represented as strings with varying precision
        "temp": random.choice([
            str(round(random.uniform(5.0, 40.0), 2)),
            str(round(random.uniform(10.0, 35.0), 1)),
            str(round(random.uniform(0.0, 50.0), 0)),
        ]),
        # Humidity sometimes numeric, sometimes string, sometimes missing
        "humidity": random.choice([
            "40", "42", "44", "45", "50",
            44, 46, 48,
            None
        ]),
        # Pressure sometimes provided, sometimes missing
        "pressure": random.choice([
            str(random.randint(850, 1150)),
            None
        ]),
        "battery": random.choice([
            "low", "LOW", "Low",
            "med", "MED", "medium",
            "HIGH", "high"
        ]),
        # Timestamp in a non ISO format to test parsing flexibility
        "ts": datetime.utcnow().strftime("%Y/%m/%d %H:%M:%S"),
        # Random device location with occasional missing values
        "location": random.choice([
            "BRAD-1", "BRAD-2", "BRAD-3",
            "LDS-01", "LDS-02", "LDS-03",
            "MAN-01", "MAN-02", "MAN-03",
            None
        ]),
        # Signal strength with mixed numeric and string formats
        "signal": random.choice([
            "55", "60", "65", "70", "75", "80", "90",
            65, 75
        ])
    }
