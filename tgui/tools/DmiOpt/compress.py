from glob import glob
import os
from PIL import Image, PngImagePlugin
import logging
import subprocess
from itertools import chain
import sys

# Set the max to something large, so we are sure that it's all getting read.
PngImagePlugin.MAX_TEXT_CHUNK = 1000000000

def main():
    # Setup logging configuration.
    logging.basicConfig(
        level=logging.DEBUG,
        format='[%(asctime)s] %(message)s'
    )

    lookIn = '.'
    if len(sys.argv) > 1:
        lookIn = sys.argv[1]

    # Walk down trough the local directory for dmi files.
    dmiFiles = (chain.from_iterable(glob(os.path.join(x[0], '*.dmi')) for x in os.walk(lookIn)))

    for x in dmiFiles:
        logging.info("Optimizing {0}".format(x))

        # Open the .dmi file so we can read the headers.
        try:
            #imageFile = Image.open(x, "r")

            # Create meta object to store info in.
            #meta = PngImagePlugin.PngInfo()

            # Store metadata
            #for k, v in imageFile.info.iteritems():
            #    meta.add_text(str(k), str(v), 0)

            # Close the image
            #imageFile.close()

            # Create new process
            subprocess.call(["optipng", "-quiet", x])

            # Merge headers with produced DMI
            #Image.open(x, "r").save(x, "PNG", pnginfo=meta, optimize=True)

            # Remove .png file
            #os.remove("{0}-fs8.png".format(x))
        except:
            logging.warning("Unable to read {0}".format(x))

if __name__ == "__main__":
    main()
