import csv, random, textwrap
from PIL import Image, ImageDraw, ImageFont

random.seed(42)

# Blue-theme gradient palettes (dark navy -> accent blue/gold)
palettes = [
    ((5,10,25), (20,60,120)),
    ((8,14,30), (10,90,140)),
    ((3,8,20), (30,50,110)),
    ((6,12,28), (15,80,160)),
    ((4,9,22), (25,70,130)),
]

def get_font(size):
    paths = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
    ]
    for p in paths:
        try:
            return ImageFont.truetype(p, size)
        except Exception:
            continue
    return ImageFont.load_default()

def make_poster(title, genre, year, path, w=500, h=750):
    c1, c2 = random.choice(palettes)
    img = Image.new("RGB", (w, h), c1)
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        r = int(c1[0] + (c2[0]-c1[0]) * t)
        g = int(c1[1] + (c2[1]-c1[1]) * t)
        b = int(c1[2] + (c2[2]-c1[2]) * t)
        draw.line([(0,y),(w,y)], fill=(r,g,b))

    # subtle diagonal vignette lines for cinematic feel
    for i in range(0, w+h, 40):
        draw.line([(i,0),(0,i)], fill=(255,255,255,10))

    # gold accent bar
    draw.rectangle([0, h-140, w, h], fill=(10,10,15))
    draw.rectangle([0, h-142, w, h-138], fill=(198,166,100))

    font_title = get_font(38)
    font_sub = get_font(24)

    wrapped = textwrap.wrap(title, width=16)
    ty = h - 128
    for line in wrapped[:3]:
        draw.text((25, ty), line, font=font_title, fill=(240,240,245))
        ty += 42

    draw.text((25, h-38), f"{genre.upper()} • {year}", font=font_sub, fill=(198,166,100))

    # top-left small CINEMORA mark
    font_mark = get_font(20)
    draw.text((20, 20), "CINEMORA", font=font_mark, fill=(255,255,255))

    img.save(path, quality=88)

with open("/home/claude/cinemora/movies.csv", newline="", encoding="utf-8") as f:
    reader = csv.DictReader(f)
    rows = list(reader)

for row in rows:
    path = f"/home/claude/cinemora/www/posters/{row['Image']}"
    make_poster(row["Title"], row["Genre"], row["Release_Year"], path)

print(f"Generated {len(rows)} posters")
