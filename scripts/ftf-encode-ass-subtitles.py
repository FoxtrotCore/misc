#!/usr/bin/env python3
import os
import ass
import json

# The default season ranges
SEASONS = {
    0: (0, 0),
    1: (1, 26),
    2: (27, 52),
    3: (53, 65),
    4: (66, 95)
}


# A quick n dirty function for converting raw episode number to production code
#   Encoded as SEE where S is a since digit season number and EE is a 2 digit
#       episode number
def ep_to_prod(ep_num: int) -> str:
    season = -1
    episode = -1

    for s, range in SEASONS.items():
        if(ep_num >= range[0] and ep_num <= range[1]):
            season = s
            episode = ep_num - range[0] + 1 if season != 0 else 0
            break

    return str(season * 100 + episode).ljust(3, '0')

# Overwrite all subtitles with these values
DEFAULT_FIELDS = {
    'PlayResX': 1800,
    'PlayResY': 1440,
    'Original Translation': 'English',
    'Script Updated By': 'the_ivo_robotnic'
}

# Path to the new scrips
DEST_DIR = os.path.abspath('./tmp')

# Get all the scripts in the directory, exclude extra files
files = os.listdir('.')
files.remove('fix.py')
files.remove('tmp')
files.remove('eng_miguzi_bumper.ass')
files.remove('episode_names.json')

# Load the episode metadata json
with open('episode_names.json', 'r') as file:
    ep_data = json.load(file)

# Reorganize the JSON from a list ot a dict
__ep_data = {}
for ep in ep_data:
    __ep_data[ep['number']] = ep
ep_data = __ep_data

# Do a first pass-through to scrub all of the episodes for styling metadata
styles_table = {}
for file in sorted(files):
    with open(file, encoding='utf-8-sig') as f:
        doc = ass.parse(f)

    for style in doc.styles:
        if(styles_table.get(style.name) is None):
            print(f'No style found for {style.name} adding stlye found in {file}')
            styles_table[style.name] = style
print(f'Found {len(styles_table)} styles total.')

# Do a second passthrough to overwite the default metadata per script and
#   overwrite the script styling with the agregated style table.
#   Then write all of the overwritten scripts to the `./tmp` dir
for file in sorted(files):
    ep_num = int(file[4:7].lstrip('0')) if file[4:7].lstrip('0') != '' else 0
    prod_code = ep_to_prod(ep_num)
    dest_path = f'{DEST_DIR}/eng-{prod_code}-Code-Lyoko.ass'
    print(f'Writing to file {dest_path}')

    with open(file, encoding='utf-8-sig') as f:
        src = ass.parse(f)
    for name, value in DEFAULT_FIELDS.items():
        src.fields.add_line(name, value)
    src.fields.add_line('Title', ep_data[ep_num]['eng_name'])
    src.fields.add_line('Original Script', prod_code)
    src.fields.add_line('Update Details', ep_data[ep_num]['description'])

    # Custom addons
    src.fields.add_line('US Airdate', ep_data[ep_num]['us_airdate'])
    src.fields.add_line('FR Airdate', ep_data[ep_num]['fr_airdate'])
    src.fields.add_line('ENG Name', ep_data[ep_num]['eng_name'])
    src.fields.add_line('FRE Name', ep_data[ep_num].get('fre_name'))

    src.styles.clear()
    for s in styles_table.values():
        src.styles.add_line('Style', s.dump())

    with open(dest_path, 'w+', encoding='utf-8-sig') as f:
        src.dump_file(f)
