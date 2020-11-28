#!/usr/bin/env python3
import re
import sys
import copy


def main(args):
    if(len(args) == 0):
        print('Need transcript file path!')

    file = open(args[0])
    content = file.read()
    file.close()
    clean_content = list(map(lambda x: x.strip().replace('\ufeff', ''), content.split('\n')))

    episode_slices = {}
    ep_num = 66
    last_line = 1

    for i, line in enumerate(clean_content):
        if(i != 1 and re.match('[0-9]+ - [a-zA-Z]*', line) is not None):
            episode_slices[str(ep_num)] = int(last_line), int(i - 1)
            last_line = i
            ep_num += 1
    episode_slices['95'] = (last_line, len(clean_content))

    for ep_num, slice in episode_slices.items():
        rev_list = copy.deepcopy(clean_content[slice[0]:slice[1]])
        rev_list.reverse()

        blank_count = 0
        for line in rev_list:
            if(line == ''):
                blank_count += 1
            else:
                break

        new_file_content = '\n'.join(clean_content[slice[0]:slice[1] - blank_count])

        filename = 'temp/{}_transcript.txt'.format(ep_num.rjust(3, '0'))
        print('Generating file: {} with {} lines'.format(filename, len(new_file_content)))
        file = open(filename, 'w+')
        file.write(new_file_content)
        file.close()


if __name__ == '__main__':
    main(sys.argv[1:])
