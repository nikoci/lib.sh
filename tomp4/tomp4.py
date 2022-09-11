import os
import moviepy.video.io.ImageSequenceClip
from PIL import Image
import PIL

def analyseImage(path):
    '''
    Pre-process pass over the image to determine the mode (full or additive).
    Necessary as assessing single frames isn't reliable. Need to know the mode
    before processing all frames.
    '''
    im = PIL.Image.open(path)
    results = {
        'size': im.size,
        'mode': 'full',
    }
    try:
        while True:
            if im.tile:
                tile = im.tile[0]
                update_region = tile[1]
                update_region_dimensions = update_region[2:]
                if update_region_dimensions != im.size:
                    results['mode'] = 'partial'
                    break
            im.seek(im.tell() + 1)
    except EOFError:
        pass
    return results


def processImage(path):
    '''
    Iterate the animated image extracting each frame.
    '''
    images = []
    mode = analyseImage(path)['mode']

    im = PIL.Image.open(path)

    i = 0
    p = im.getpalette()
    last_frame = im.convert('RGBA')

    try:
        while True:
            print("saving %s (%s) frame %d, %s %s" % (path, mode, i, im.size, im.tile))

            '''
            If the GIF uses local colour tables, each frame will have its own palette.
            If not, we need to apply the global palette to the new frame.
            '''
            if '.gif' in path:
                if not im.getpalette():
                    im.putpalette(p)

            new_frame = PIL.Image.new('RGBA', im.size)

            '''
            Is this file a "partial"-mode GIF where frames update a region of a different size to the entire image?
            If so, we need to construct the new frame by pasting it on top of the preceding frames.
            '''
            if mode == 'partial':
                new_frame.paste(last_frame)

            new_frame.paste(im, (0, 0), im.convert('RGBA'))
            nameoffile = path.split('/')[-1]
            output_folder = path.replace(nameoffile, '')

            name = '%s%s-%d.png' % (output_folder, ''.join(os.path.basename(path).split('.')[:-1]), i)
            print(name)
            new_frame.save(name, 'PNG')
            images.append(name)
            i += 1
            last_frame = new_frame
            im.seek(im.tell() + 1)
    except EOFError:
        pass
    return images



def webp_mp4(filename, outfile):
    try:
        images = processImage("%s" % filename)
        fps = 20
        if len(images) < 60:
            fps = 8
        clip = moviepy.video.io.ImageSequenceClip.ImageSequenceClip(images, fps=fps)
        
        clip.write_videofile(
            filename = outfile,
            codec = "mpeg4"
        )

        for image in images:
            os.remove(image)
        return [outfile]
    except:
        print("FAILED TO CONVERT "+filename)
        print("Oops!", sys.exc_info()[0], "occurred.")
        print("Next entry.")
        print()

import moviepy.editor as mp
def gif_mp4(filename, outfile):
    try:
        clip = mp.VideoFileClip(filename)
        clip.write_videofile(outfile)
    except:
        print("FAILED TO CONVERT "+filename)
        print("Oops!", sys.exc_info()[0], "occurred.")
        print("Next entry.")
        print()

import sys

dir = sys.argv[1]
os.mkdir(os.path.join(dir, "old_converted_gifs"))

import shutil

for file in os.listdir(dir):
    if file.endswith(".webp") or file.endswith(".gif") or file.endswith(".WEBP") or file.endswith(".GIF"):
        shutil.move(dir + "/" + file, dir + "/old_converted_gifs/" + file)
        filename = dir + "/old_converted_gifs/" + file
        outfile = dir + "/" + os.path.splitext(file)[0] + ".mp4"

    if file.endswith(".webp") or file.endswith(".WEBP"):
        webp_mp4(filename, outfile)
    elif file.endswith(".gif") or file.endswith(".GIF"):
        gif_mp4(filename, outfile)