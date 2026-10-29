
"""
Cyclistic Bike-Share Analysis
Purpose: Combine monthly ride data, clean duplicate records,
calculate ride duration, create analysis columns, and export
the cleaned dataset.
"""

from pathlib import Path
import pandas as pd


# --------------------------------------------------
# 1. Set the project folders
# --------------------------------------------------

# Find the project folder
script_folder = Path(__file__).resolve().parent

# Support running from either the main folder or Python folder
if (script_folder / "01_Raw_Data").exists():
    project_folder = script_folder
else:
    project_folder = script_folder.parent

raw_folder = project_folder / "01_Raw_Data"
clean_folder = project_folder / "02_Cleaned_Data"

# Create the cleaned-data folder if it does not exist.
clean_folder.mkdir(parents=True, exist_ok=True)


# --------------------------------------------------
# 2. Find the monthly CSV files
# --------------------------------------------------

csv_files = sorted(raw_folder.glob("*.csv"))

if not csv_files:
    raise FileNotFoundError(
        f"No CSV files found in: {raw_folder}"
    )

print("Monthly CSV files found:", len(csv_files))


# --------------------------------------------------
# 3. Read and combine all monthly files
# --------------------------------------------------

frames = []

for file in csv_files:
    df = pd.read_csv(file)
    frames.append(df)

    print(f"Loaded: {file.name} - {len(df):,} rows")

data = pd.concat(frames, ignore_index=True)

print("\nOriginal total rows:", f"{len(data):,}")


# --------------------------------------------------
# 4. Check the required columns
# --------------------------------------------------

required_columns = [
    "ride_id",
    "started_at",
    "ended_at",
    "member_casual",
]

missing_columns = [
    column
    for column in required_columns
    if column not in data.columns
]

if missing_columns:
    raise ValueError(
        f"Required columns are missing: {missing_columns}"
    )


# --------------------------------------------------
# 5. Remove duplicate ride IDs
# --------------------------------------------------

rows_before = len(data)

data = data.drop_duplicates(
    subset="ride_id",
    keep="first"
).copy()

duplicates_removed = rows_before - len(data)

print("Duplicate rows removed:", f"{duplicates_removed:,}")
print("Rows after duplicate removal:", f"{len(data):,}")


# --------------------------------------------------
# 6. Convert start and end times to datetime
# --------------------------------------------------

data["started_at"] = pd.to_datetime(data["started_at"])
data["ended_at"] = pd.to_datetime(data["ended_at"])


# --------------------------------------------------
# 7. Calculate ride duration in minutes
# --------------------------------------------------

data["ride_length"] = (
    data["ended_at"] - data["started_at"]
).dt.total_seconds() / 60


# --------------------------------------------------
# 8. Remove zero or negative ride durations
# --------------------------------------------------

rows_before = len(data)

data = data[data["ride_length"] > 0].copy()

invalid_durations_removed = rows_before - len(data)

print(
    "Zero or negative duration rows removed:",
    f"{invalid_durations_removed:,}"
)
print("Rows after duration cleaning:", f"{len(data):,}")


# --------------------------------------------------
# 9. Create columns for analysis
# --------------------------------------------------

# Day of the week when the ride started
data["day_of_week"] = data["started_at"].dt.day_name()

# Hour when the ride started (0 to 23)
data["start_hour"] = data["started_at"].dt.hour

# Month when the ride started
data["month"] = data["started_at"].dt.month_name()

# Classify each ride as a weekday or weekend
data["day_type"] = data["day_of_week"].apply(
    lambda day: "Weekend"
    if day in ["Saturday", "Sunday"]
    else "Weekday"
)


# --------------------------------------------------
# 10. Export the cleaned dataset
# --------------------------------------------------

output_file = clean_folder / "cyclistic_cleaned.csv"

data.to_csv(output_file, index=False)

print("\nCleaning completed successfully!")
print("Final cleaned rows:", f"{len(data):,}")
print("Total columns:", len(data.columns))
print("Saved file:", output_file)


# --------------------------------------------------
# 11. Display a small preview
# --------------------------------------------------

print("\nFirst five rows of the cleaned data:")
print(data.head())
