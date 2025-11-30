import random
from datetime import datetime

def generate_raw_message():
    """
    Generate a deliberately messy IoT payload.
    Mimics real-world schema drift and inconsistent formats.
    """
    return {
        "sensorId": random.choice([
            "T-001", "T-002", "T-003",
            "H-009", "H-010", "H-011",
            "P-221", "P-222"
        ]),
        "device_status": random.choice([
            "OK", "ok", "Ok", "OK!", "Good", "GOOD", "Healthy", "Available",
            "ERROR",
            "WARNING"
        ]),
        "temp": random.choice([
            str(round(random.uniform(5.0, 40.0), 2)),
            str(round(random.uniform(10.0, 35.0), 1)),
            str(round(random.uniform(0.0, 50.0), 0)),
        ]),

        "humidity": random.choice([
            "40", "42", "44", "45", "50",
            44, 46, 48,
            None
        ]),
        "pressure": random.choice([
            str(random.randint(850, 1150)),
            None
        ]),
        "battery": random.choice([
            "low", "LOW", "Low",
            "med", "MED", "medium",
            "HIGH", "high"
        ]),
        "ts": datetime.utcnow().strftime("%Y/%m/%d %H:%M:%S"),
        "location": random.choice([
            "BRAD-1", "BRAD-2", "BRAD-3",
            "LDS-01", "LDS-02", "LDS-03",
            "MAN-01", "MAN-02", "MAN-03",
            None
        ]),
        "signal": random.choice([
            "55", "60", "65", "70", "75", "80", "90",
            65, 75
        ])
    }
