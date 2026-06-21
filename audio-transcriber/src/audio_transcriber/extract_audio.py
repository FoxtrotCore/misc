from pathlib import Path
from typing import Optional

from ffmpeg.ffmpeg import export
from ffmpeg.inputs import VideoFile
from ffmpeg.output import OutFile

from . import APP_NAME
from .utils import get_logger


def extract_audio_from_video(video_path: Path, audio_dir: Path) -> Optional[Path]:
    LOG = get_logger()

    video = VideoFile(video_path)
    parent_dir = Path(video.filepath).parent.name
    if not parent_dir.startswith("season"):
        LOG.error("Cannot infer season from path!")
        return None
    season = parent_dir.split("-")[-1]
    episode = video_path.name.split(".")[0]
    audio_path: Path = audio_dir.joinpath(f"S{season}-E{episode}.mka").absolute()
    if audio_path.exists():
        LOG.warning(
            "Audio file already exists! Skipping extraction! Loading from: %s",
            audio_path,
        )
        return audio_path

    LOG.debug("Extracting audio from %s to %s", video_path, audio_path)
    export(video.audio, path=audio_path).run()
    return audio_path
