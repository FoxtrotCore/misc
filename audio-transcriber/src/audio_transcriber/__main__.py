from argparse import ArgumentParser
from pathlib import Path

from . import APP_DESCRIPTION, APP_NAME
from .extract_audio import extract_audio_from_video
from .subtitle import build_ass_subtitle
from .transcribe import dump_raw_transcript, transcribe
from .utils import get_logger


def build_parser() -> ArgumentParser:
    parser = ArgumentParser(prog=APP_NAME, description=APP_DESCRIPTION)
    parser.add_argument(
        "--audio-dir",
        "-a",
        type=str,
        default="./audio",
        help="Output directory of audio file(s). (Default: %(default)s)",
    )
    parser.add_argument(
        "--transcripts-dir",
        "-t",
        type=str,
        default="./transcripts",
        help="Output directory of transcript file(s). (Default: %(default)s)",
    )
    parser.add_argument(
        "--device",
        "-d",
        default="cpu",
        choices=["cpu", "cuda", "rocm"],
        help="Device type to use for PyTorch inference. (Default: %(default)s)",
    )
    parser.add_argument(
        "--model",
        "-m",
        type=str,
        choices=[
            "tiny.en",
            "tiny",
            "base.en",
            "base",
            "small.en",
            "small",
            "medium.en",
            "medium",
            "large-v1",
            "large-v2",
            "large-v3",
            "large",
            "distil-large-v2",
            "distil-medium.en",
            "distil-small.en",
            "distil-large-v3",
            "distil-large-v3.5",
            "large-v3-turbo",
            "turbo",
        ],
        default="tiny",
        help="Name of the Whisper model to use. (Default: %(default)s)",
    )
    parser.add_argument(
        "--language",
        default="en",
        choices=["en", "fr"],
        help="Audio language code. (Default: %(default)s)",
    )
    parser.add_argument(
        "--batch-size",
        "-bs",
        type=int,
        default=8,
        help="Preferred batch size for inference. (Default: %(default)s)",
    )
    parser.add_argument(
        "--compute-type",
        type=str,
        choices=["default", "float16", "float32", "int8"],
        default="default",
        help="Compute type for computation, 'default' uses float16 on GPU, float32 on CPU. (Default: %(default)s)",
    )
    parser.add_argument(
        "--diarize",
        "-D",
        default=False,
        action="store_true",
        help="Enable diarization to assign speaker labels to each segment/word.",
    )
    parser.add_argument(
        "--min-speakers",
        type=int,
        default=1,
        help="Minimum number of speakers to in audio file. (Default: %(default)s)",
    )
    parser.add_argument(
        "--max-speakers",
        type=int,
        default=10,
        help="Maximum number of speakers to in audio file. (Default: %(default)s)",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        default=False,
        help="Enable verbose logging.",
    )
    parser.add_argument(
        "video_path",
        type=str,
        help="Path to the video file fo transcribe.",
    )
    return parser


def main():
    # Build and parse CLI args
    parser = build_parser()
    args = parser.parse_args()

    # Configure the logger
    LOG = get_logger(verbose=args.verbose)

    # Fetch the video path
    video_path = Path(args.video_path)
    if not video_path.exists() or not video_path.is_file():
        LOG.error("Video file is not valid: %s", args.video_path)
        return -1

    # Create the audio path
    audio_dir = Path(args.audio_dir)
    audio_dir.mkdir(parents=True, exist_ok=True)

    # Create the transcripts path
    transcript_dir = Path(args.transcripts_dir)
    transcript_dir.mkdir(parents=True, exist_ok=True)

    # Extract the audio
    audio_path: Path = extract_audio_from_video(video_path, audio_dir)

    # Transcribe the audio and save the raw transcription
    raw_transcript: dict = transcribe(
        audio_path=audio_path,
        transcript_dir=transcript_dir,
        device=args.device,
        model=args.model,
        language=args.language,
        batch_size=args.batch_size,
        compute_type=args.compute_type,
        diarize=args.diarize,
        min_speakers=args.min_speakers,
        max_speakers=args.max_speakers,
    )
    transcript_path: Path = dump_raw_transcript(
        audio_path, transcript_dir, raw_transcript
    )

    # Format and save the transcript into ASS
    subtitle_path: Path = build_ass_subtitle(transcript_path, raw_transcript)


if __name__ == "__main__":
    main()
