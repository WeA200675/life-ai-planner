"""Process-exclusive advisory lock for isolated restore journal operations.

POSIX only; unsupported platforms fail closed. Lock files are intentionally retained
to avoid inode replacement races. All participants must use the same lock path.
"""
from contextlib import contextmanager
import os
from pathlib import Path
import stat

from packages.storage.recovery_phase import RecoveryPhaseError, advance_phase

try:
    import fcntl
except ImportError:
    fcntl = None


@contextmanager
def recovery_lock(path):
    """Acquire nonblocking process lock; never remove the lock file."""
    if fcntl is None:
        raise RecoveryPhaseError("restore locking unsupported on this platform")
    path = Path(os.path.abspath(path))
    for part in (path, *path.parents):
        try:
            mode = part.lstat().st_mode
        except FileNotFoundError:
            if part != path:
                raise RecoveryPhaseError("lock parent missing")
            continue
        if stat.S_ISLNK(mode):
            raise RecoveryPhaseError("symlink in lock path")
    if not path.parent.is_dir():
        raise RecoveryPhaseError("lock parent missing")
    flags = os.O_RDWR | os.O_CREAT | os.O_CLOEXEC
    if hasattr(os, "O_NOFOLLOW"):
        flags |= os.O_NOFOLLOW
    fd = os.open(path, flags, 0o600)
    locked = False
    try:
        metadata = os.fstat(fd)
        if not stat.S_ISREG(metadata.st_mode) or metadata.st_nlink != 1:
            raise RecoveryPhaseError("unsafe lock file")
        if os.stat(path, follow_symlinks=False).st_ino != metadata.st_ino:
            raise RecoveryPhaseError("lock file replaced")
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            locked = True
        except BlockingIOError as exc:
            raise RecoveryPhaseError("restore already locked") from exc
        yield
    finally:
        if locked:
            fcntl.flock(fd, fcntl.LOCK_UN)
        os.close(fd)


def advance_phase_locked(journal_path, lock_path, restore_id, expected, next_phase):
    """Advance journal only while holding a cross-process lock.

    Does not activate databases or coordinate SQLite handles.
    """
    with recovery_lock(lock_path):
        return advance_phase(journal_path, restore_id, expected, next_phase)
