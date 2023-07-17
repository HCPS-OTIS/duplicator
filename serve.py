#!/usr/bin/env python3

import pywebio as io

def main():
    # show progressbar for information gathering
    io.output.put_progressbar('info', label='Gathering information')

    # show and select drives (checkboxes)
    # show image options (radio)
    # for staff, show driver packs (checkboxes)
    # for ventoy, show ISOs (checkboxes)
    drives = io.input.checkbox(label='Please select drives to image',
                               options=['sda', 'sdb', 'sdc', 'sdd'], inline=False)
    io.output.set_progressbar('info', value=.1)
    io.output.put_info('Selected drives: ' + str(drives))

io.start_server(main, port=8080)
