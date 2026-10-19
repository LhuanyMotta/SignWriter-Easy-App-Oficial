from pathlib import Path
from PIL import Image, ImageDraw

root = Path(__file__).resolve().parents[1]
web_dir = root / 'web'
icons_dir = web_dir / 'icons'
icons_dir.mkdir(exist_ok=True)


def make_icon(size: int, output: Path) -> None:
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    pad = int(size * 0.08)
    radius = int(size * 0.26)

    for i in range(12):
        alpha = 255 - i * 14
        color = (18 + i * 5, 90 + i * 12, 165 + i * 9, alpha)
        draw.rounded_rectangle(
            (pad - i, pad - i, size - pad + i, size - pad + i),
            radius=radius,
            fill=color,
        )

    draw.rounded_rectangle(
        (pad, pad, size - pad, size - pad),
        radius=radius,
        fill=(45, 120, 190, 255),
    )

    glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.rounded_rectangle(
        (int(size * 0.15), int(size * 0.15), int(size * 0.85), int(size * 0.85)),
        radius=int(size * 0.22),
        fill=(255, 255, 255, 40),
    )
    img = Image.alpha_composite(img, glow)
    draw = ImageDraw.Draw(img)

    cx = size / 2
    cy = size / 2
    r = size * 0.28

    draw.arc(
        (cx - r, cy - r, cx + r, cy + r),
        start=200,
        end=470,
        fill=(255, 255, 255, 255),
        width=max(7, size // 18),
    )
    draw.arc(
        (cx - r * 0.78, cy - r * 0.78, cx + r * 0.78, cy + r * 0.78),
        start=245,
        end=430,
        fill=(255, 255, 255, 255),
        width=max(7, size // 20),
    )

    for x, y in [
        (size * 0.38, size * 0.26),
        (size * 0.67, size * 0.29),
        (size * 0.66, size * 0.68),
        (size * 0.35, size * 0.72),
    ]:
        draw.ellipse((x - 6, y - 6, x + 6, y + 6), fill=(218, 241, 255, 255))

    img.save(output)


for file_name, size in {
    'favicon.png': 64,
    'icons/Icon-192.png': 192,
    'icons/Icon-512.png': 512,
    'icons/Icon-maskable-192.png': 192,
    'icons/Icon-maskable-512.png': 512,
}.items():
    make_icon(size, web_dir / file_name)

print('Generated web branding icons in:', web_dir)
