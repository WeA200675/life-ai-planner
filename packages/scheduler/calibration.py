"""Deterministic buffer calibration from completed days; no biometric inference."""
from dataclasses import dataclass
from datetime import date
from math import isfinite
from statistics import mean

@dataclass(frozen=True)
class DayObservation:
    day: date
    available_minutes: int
    interruption_minutes: int
    incident_count: int = 0

@dataclass(frozen=True)
class Calibration:
    ratio: float
    observed_ratio: float | None
    sample_days: int
    changed: bool
    reason: str

def calibrate(observations: list[DayObservation], current_ratio: float = 0.30,
              *, lookback_days: int = 14, minimum_days: int = 7,
              step: float = 0.05, lower: float = 0.15,
              upper: float = 0.50) -> Calibration:
    """Adjust buffer at most one step, using only distinct valid days in a 14-day window.

    Missing observations do not count as zero-interruption days. Days with no
    usable capacity are excluded; repeated imports of one day cannot bias results.
    """
    if not (isfinite(current_ratio) and isfinite(step) and
            isfinite(lower) and isfinite(upper) and
            0 <= lower <= current_ratio <= upper < 1 and step > 0):
        raise ValueError("invalid calibration parameters")
    if lookback_days < minimum_days or minimum_days < 1:
        raise ValueError("invalid lookback")
    by_day = {}
    for o in observations:
        if not isinstance(o.day, date) or isinstance(o.day, __import__("datetime").datetime):
            raise ValueError("invalid observation date")
        if o.available_minutes < 0 or o.interruption_minutes < 0 or o.incident_count < 0:
            raise ValueError("negative observation")
        if o.interruption_minutes > o.available_minutes:
            raise ValueError("interruptions exceed capacity")
        if o.day in by_day and by_day[o.day] != o:
            raise ValueError("conflicting duplicate day")
        by_day[o.day] = o
    if not by_day:
        return Calibration(current_ratio, None, 0, False, "insufficient data")
    newest = max(by_day)
    cutoff = newest.toordinal() - lookback_days + 1
    samples = [o for o in by_day.values()
               if o.day.toordinal() >= cutoff and o.available_minutes > 0]
    if len(samples) < minimum_days:
        return Calibration(current_ratio, None, len(samples), False, "insufficient data")
    observed = mean(o.interruption_minutes / o.available_minutes for o in samples)
    if observed > current_ratio + step / 2:
        updated = min(upper, round(current_ratio + step, 10))
    elif observed < current_ratio - step / 2:
        updated = max(lower, round(current_ratio - step, 10))
    else:
        updated = current_ratio
    return Calibration(updated, observed, len(samples), updated != current_ratio,
                       "adjusted" if updated != current_ratio else "within tolerance")
