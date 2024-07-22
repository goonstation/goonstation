#!/usr/bin/env python3

'''
Opens a folder, and recursively feeds all OGG files in it to
optivorbis.exe
for recompression and reducing file size.

optivorbis.exe is available from https://github.com/OptiVorbis/OptiVorbis/

WARNING:
Source files are replaced! No backup, no mercy!

'''

__author__ = "Ilya Razmanov"
__copyright__ = "(c) 2024 Ilya Razmanov"
__credits__ = "Ilya Razmanov"
__license__ = "unlicense"
__version__ = "2024.07.11"
__maintainer__ = "Ilya Razmanov"
__email__ = "ilyarazmanov@gmail.com"
__status__ = "Production"

from tkinter import Tk, filedialog, Button, Label, X, BOTH, TOP, BOTTOM
from tkinter.ttk import Progressbar
from tkinter.scrolledtext import ScrolledText

from pathlib import Path

import subprocess
import os

# Creating dialog
sortir = Tk()
sortir.title('Recompressing .OGG...')
sortir.geometry('+100+100')
sortir.maxsize(800, 600)
zanyato = Label(sortir, wraplength=800, text='Starting...', font=('arial', 12), padx=16, pady=10, justify='center')
zanyato.pack()

progressbar =  Progressbar(sortir, orient='horizontal', mode='indeterminate')
progressbar.pack(fill=X, side=TOP, expand=True)

pogovorit = ScrolledText(sortir, height=26, wrap='word', state='normal')
pogovorit.pack(fill=BOTH, expand=True)

butt = Button(
    sortir,
    text='Busy...',
    font=('arial', 14),
    cursor='hand2',
    justify='center',
    state='disabled',
    command=sortir.destroy
)
butt.pack(fill=X, side=BOTTOM, expand=True)

pogovorit.insert('1.0', 'Allons-y!\n')

sortir.withdraw()   # Main dialog created and hidden

# Open source dir
sourcedir = filedialog.askdirectory(title='Open DIR to compress OGG files')
if (sourcedir == ''):
    sortir.destroy()
    quit()

path=Path(sourcedir)

# Updating dialog
sortir.deiconify()
zanyato.config(text='Allons-y!')
pogovorit.focus()
sortir.update()
sortir.update_idletasks()

startupinfo = subprocess.STARTUPINFO()
startupinfo.dwFlags |= subprocess.STARTF_USESHOWWINDOW

env = os.environ.copy()
env['SOURCE_DATE_EPOCH'] = '1585724400'

# Process file list
for filename in path.rglob('*.ogg'):  # cycle through OGG files in subfolders

    zanyato.config(text=f'Processing {filename}...')    # Updating UI, showing processed file name
    progressbar.start(50)
    pogovorit.insert('end -1 chars', f' Starting {filename}...  ')
    pogovorit.see('end')
    sortir.update()
    sortir.update_idletasks()

    currentfile = Path(filename).resolve()        # file to be processed
    tempfile = Path(filename.resolve().parent / 'hujwam.ogg')    # temp file hujwam.ogg
    currentfile.replace(tempfile)       # move file to temp

    # Note: output in quotes below for paths with spaces
    subprocess.run(f'optivorbis.exe --quiet --vendor_string_action empty --remuxer_option randomize_stream_serials=false "{tempfile}" "{filename}"',
		startupinfo=startupinfo,
		env=env
	)
    # optivorbis.exe writes result from temp back to source location

    progressbar.start(50)
    pogovorit.insert('end -1 chars', ' Done\n')
    sortir.update()
    sortir.update_idletasks()

    tempfile.unlink(missing_ok=True)        # removing temp file

zanyato.config(text=f'Finished {sourcedir}')
progressbar.stop()
butt.config(text='Dismissed!', state='normal')

sortir.mainloop()
