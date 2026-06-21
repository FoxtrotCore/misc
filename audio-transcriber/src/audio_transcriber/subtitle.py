from pathlib import Path

from ass import Document, Dialogue, EventsSection, Sound

from .utils import get_logger


def build_ass_subtitle(transcript_path: Path, raw_transcript: dict) -> Path:
    LOG = get_logger()

    # Build subtitle name
    subtitle_name = f'{transcript_path.name.split(".")[0]}.ass'
    subtitle_path = transcript_path.parent.joinpath(subtitle_name)

    # Construct the formatted subtitle
    subtitle = Document()
    for segment in raw_transcript.get('segments'):
        line = Dialogue(
            layer=0,
            start=int(segment.get('start')),
            end=int(segment.get('end')),
            style='ACTOR_STYLE',
            name='ACTOR',
            margin_l=0,
            margin_r=0,
            margin_v=0,
            effect='',
            text=segment.get('text')
        )
        subtitle.events.append(line)
    intro_music = Sound(
        start=0,
        end=10,
        text='Intro Theme Song!',
        name='intro-music'
    )
    subtitle.events.append(intro_music)

    # Write to file
    with open(subtitle_path, "w+") as file:
        subtitle.dump_file(file)

    LOG.debug("Saved formatted transcript to file: %s", subtitle_path)
