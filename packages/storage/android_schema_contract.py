"""Read-only validation contract for the Flutter SQLite v4 database.

This module does not activate a backup or migrate an installed database.
Keep the contract aligned with apps/mobile/lib/local_task_schema.dart,
apps/mobile/lib/plan_snapshot_store.dart, and main.dart's version=4.
"""
from .recovery_preflight import inspect_candidate

ANDROID_DB_USER_VERSION = 4
ANDROID_REQUIRED_COLUMNS = {
    "tasks": ("id", "title", "done", "minutes", "priority", "deadline_utc_ms"),
    "plan_snapshots": (
        "id", "created_utc_ms", "window_start_utc_ms", "window_end_utc_ms",
        "budget_minutes", "reserved_minutes",
    ),
    "plan_accept_requests": ("request_key", "snapshot_id", "payload_fingerprint"),
    "plan_snapshot_blocks": (
        "snapshot_id", "position", "task_id", "start_utc_ms", "end_utc_ms",
    ),
}


ANDROID_REQUIRED_PRIMARY_KEYS = {
    "tasks": ("id",),
    "plan_snapshots": ("id",),
    "plan_accept_requests": ("request_key",),
    "plan_snapshot_blocks": ("snapshot_id", "position"),
}


ANDROID_REQUIRED_NOT_NULL = {
    "tasks": ("title", "done", "priority"),
    "plan_snapshots": (
        "created_utc_ms", "window_start_utc_ms", "window_end_utc_ms",
        "budget_minutes", "reserved_minutes",
    ),
    "plan_snapshot_blocks": (
        "snapshot_id", "position", "task_id", "start_utc_ms", "end_utc_ms",
    ),
    "plan_accept_requests": ("request_key", "snapshot_id", "payload_fingerprint"),
}

ANDROID_REQUIRED_FOREIGN_KEYS = {
    "plan_snapshot_blocks": (("snapshot_id", "plan_snapshots", "id"),),
    "plan_accept_requests": (("snapshot_id", "plan_snapshots", "id"),),
}


def inspect_android_v4_candidate(path):
    """Reject mismatched or incomplete v4 backups without writing to them.

    The caller MUST enforce exclusive application-wide database access.
    This is not a restore operation and does not authorize activation.
    """
    return inspect_candidate(
        path,
        expected_user_version=ANDROID_DB_USER_VERSION,
        required_tables=tuple(ANDROID_REQUIRED_COLUMNS),
        required_columns=ANDROID_REQUIRED_COLUMNS,
        required_primary_keys=ANDROID_REQUIRED_PRIMARY_KEYS,
        required_not_null=ANDROID_REQUIRED_NOT_NULL,
        required_foreign_keys=ANDROID_REQUIRED_FOREIGN_KEYS,
    )
