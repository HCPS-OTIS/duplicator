#!/usr/bin/env python3

import json
from pywebio import input, output, start_server, config
import subprocess, os

# run script from scripts folder and output stdout/stderr to output
def run_script(args: list[str], display_output=True, display_errors=True):
    args[0] = os.path.dirname(os.path.realpath(__file__)) + '/scripts/' + args[0]
    out = subprocess.run(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if display_output and out.stdout != b'':
        output.put_code(str(out.stdout, 'UTF-8'))
    if display_errors and out.stderr != b'':
        output.put_error(str(out.stderr, 'UTF-8'))
    return out

def get_drives():
    # Json, Drives, complete Path (/dev/sd?), Output columns
    ps_drives = subprocess.run(['lsblk', '-Jdpo', 'HOTPLUG,TYPE,SIZE,VENDOR,MODEL,NAME'],
                               stdout=subprocess.PIPE)
    all_drives = json.loads(ps_drives.stdout)['blockdevices']
    drives = [drive for drive in all_drives if drive['hotplug'] and drive['type'] == 'disk']
    for drive in drives:
        drive['vendor'] = drive['vendor'].strip()
        del drive['hotplug']
        del drive['type']
    return drives

def create_clonezilla(drives: list[str]):
    # unmount drives
    run_script(['umount.sh'] + [d+'?*' for d in drives], display_errors=False)
    output.put_text('Drives unmounted')

    # create partitions
    run_script(['partition_dual.sh', '2000'] + drives)
    run_script(['ntfs.sh'] + [d+'2' for d in drives])

    output.put_text('Partitions and NTFS filesystems created')

def main():
    # show progressbar for information gathering
    output.put_markdown('# Drive Creator')

    # show and select drives (checkboxes)
    drives_all = get_drives()
    labels_all = [f"{d['size']}: {d['vendor']} {d['model']} ({d['name']})" for d in drives_all]

    drives_selected = input.checkbox(options=zip(labels_all, drives_all, [True]*len(drives_all)))

    output.put_info('Selected drives: ' + ', '.join([d['name'] for d in drives_selected]))

    # show image options (radio)
    modes_all = [
        ['Student drive', 'student'],
        ['Student drive (Clonezilla)', 'clonezilla'],
        ['Staff drive (Image Assist)', 'staff'],
        ['Boxlight firmware upgrade', 'boxlight'],
        ['Ventoy (Boots ISOs, etc)', 'ventoy']
    ]

    mode = input.radio(options=modes_all)

    output.put_info('Selected mode: ' + mode)

    # for staff, show driver packs (checkboxes)
    # for ventoy, show ISOs (checkboxes)

    match mode:
        case 'clonezilla':
            create_clonezilla([d['name'] for d in drives_selected])

config(css_style=open('style.css').read())
start_server(main, port=80)
