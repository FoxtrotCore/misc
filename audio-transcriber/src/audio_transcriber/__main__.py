from . import APP_NAME, APP_DESCRIPTION
from argparse import ArgumentParser
from pathlib import Path
from whisperx import load_audio, load_model, SubtitlesProcessor
from json import dump


def transcribe(
    input_file_path: str,
    output_file_path: str,
    device: str,
    model: str,
    language: str,
    batch_size: int,
    compute_type: str,
    diarize: bool,
    min_speakers: int,
    max_speakers: int,
):
    # Load audio file
    audio = load_audio(input_file_path)

    # Load ASR model
    asr_model = load_model(model, device=device, compute_type=compute_type, language=language)

    raw_transcript = asr_model.transcribe(audio, language=language)
    with open(f"{output_file_path}.json", "w+") as file:
        dump(
            raw_transcript,
            file,
            ensure_ascii=False,
            indent=4,
            sort_keys=True,
            check_circular=True,
        )


def main():
    parser = ArgumentParser(prog=APP_NAME, description=APP_DESCRIPTION)
    parser.add_argument(
        "--audio-dir",
        "-a",
        type=str,
        default="./audio",
        help="Path to the directory of audio files. (Default: %(default)s)",
    )
    parser.add_argument(
        "--transcripts-dir",
        "-t",
        type=str,
        default="./transcripts",
        help="Path to the directory of transcript files. (Default: %(default)s)",
    )
    parser.add_argument(
        "--device",
        "-d",
        default="cpu",
        choices=["cuda", "cpu"],
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

    args = parser.parse_args()

    audio_dir = Path(args.audio_dir)
    audio_dir.mkdir(parents=True, exist_ok=True)

    transcript_dir = Path(args.transcripts_dir)
    transcript_dir.mkdir(parents=True, exist_ok=True)

    for p in audio_dir.iterdir():
        input_file = p.absolute()
        output_file = Path(
            f'{transcript_dir.joinpath(input_file.name.split(".")[0])}.txt'
        ).absolute()

        transcribe(
            input_file_path=input_file,
            output_file_path=output_file,
            device=args.device,
            model=args.model,
            language=args.language,
            batch_size=args.batch_size,
            compute_type=args.compute_type,
            diarize=args.diarize,
            min_speakers=args.min_speakers,
            max_speakers=args.max_speakers,
        )


if __name__ == "__main__":
    main()
