#!/usr/bin/env python3

import json
from pywebio import input, output, start_server
import subprocess

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

def main():
    # show progressbar for information gathering
    output.put_markdown('# Drive creator')

    # show and select drives (checkboxes)
    drives_all = get_drives()
    labels_all = [f"{d['size']}: {d['vendor']} {d['model']} ({d['name']})" for d in drives_all]

    drives_selected = input.checkbox(options=zip(labels_all, drives_all))

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

start_server(main, port=80)
