import math
from PIL import Image

SIZE = 96

SQUARE_SIZE = 32

def sdf_square(x, y, cx, cy, size):
    rad = size / 2
    dx = abs(x - cx)
    dy = abs(y - cy)
    if dx > rad and dy > rad: # corner
        return math.sqrt((dx - rad) ** 2 + (dy - rad) ** 2)
    if dx > rad or dy > rad:
        return max(dx - rad, dy - rad)
    else:
        return -max(rad - dx, rad - dy)

def main():
    a = 42
    b = -42
    out_img = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 255))

    for x in range(SIZE):
        for y in range(SIZE):
            square_dist = sdf_square(x, y, SIZE / 2, SIZE / 2, SQUARE_SIZE)
            if square_dist <= 0:
                out_img.putpixel((x, y), (255, 255, 255, 255))
                continue
            normalized_dist = square_dist / ((SIZE - SQUARE_SIZE) / 2)
            add = 4
            val = 1 / (normalized_dist + add) ** 2
            min_val = 1 / (1 + add) ** 2
            max_val = 1 / (0 + add) ** 2
            val = (val - min_val) / (max_val - min_val)
            col = int(255 * val)
            a = min(a, col)
            b = max(b, col)
            out_img.putpixel((x, y), (255, 255, 255, col))

    out_img.save('light_overlay.png')

    print(a, b)

if __name__ == '__main__':
    main()
