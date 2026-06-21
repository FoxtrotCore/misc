from logging import (
    DEBUG,
    INFO,
    Formatter,
    Logger,
    StreamHandler,
    basicConfig,
    getLogger,
)

from . import APP_NAME


def get_logger(log_name: str = APP_NAME, verbose: bool = False) -> Logger:
    logger = getLogger(log_name)

    if getattr(logger, "_configured", False):
        return logger

    log_level = DEBUG if verbose else INFO
    logger.setLevel(log_level)
    logger.propagate = False

    handler = StreamHandler()
    handler.setLevel(log_level)

    formatter = Formatter(fmt="%(asctime)s %(levelname)s [%(name)s] %(message)s")
    handler.setFormatter(formatter)

    logger.addHandler(handler)
    logger._configured = True
    return logger
