from datetime import date
from datetime import datetime
from datetime import timezone

def datetime_to_string(data: datetime):
    return data.strftime("%A, %B %d, %Y at %I:%M:%S %p UTC")

def string_to_datetime(date_string: str):
    date = datetime.strptime(date_string, "%A, %B %d, %Y at %I:%M:%S %p UTC")
    return date.replace(tzinfo=timezone.utc)