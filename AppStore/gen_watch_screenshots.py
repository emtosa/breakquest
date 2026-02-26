from PIL import Image, ImageDraw, ImageFont
import os

# Watch sizes
SIZES = [
    (312, 390),  # Series 3
    (368, 448),  # Series 4 / Series 6
    (396, 484),  # Series 7 / Series 9
    (416, 496),  # Series 10 / Series 11
    (410, 502),  # Ultra
    (422, 514),  # Ultra 3
]

# Try to load Apple Color Emoji font for emoji support
EMOJI_FONT_PATH = "/System/Library/Fonts/Apple Color Emoji.ttc"
SF_FONT_PATH = "/System/Library/Fonts/SFNS.ttf"
SYSTEM_FONT_PATH = "/System/Library/Fonts/Helvetica.ttc"

def get_font(size):
    for path in [SF_FONT_PATH, SYSTEM_FONT_PATH]:
        try:
            return ImageFont.truetype(path, size)
        except:
            pass
    return ImageFont.load_default()

def get_emoji_font(size):
    try:
        return ImageFont.truetype(EMOJI_FONT_PATH, size)
    except:
        return get_font(size)

def draw_rounded_rect(draw, xy, radius, fill):
    x0, y0, x1, y1 = xy
    draw.rectangle([x0+radius, y0, x1-radius, y1], fill=fill)
    draw.rectangle([x0, y0+radius, x1, y1-radius], fill=fill)
    draw.ellipse([x0, y0, x0+2*radius, y0+2*radius], fill=fill)
    draw.ellipse([x1-2*radius, y0, x1, y0+2*radius], fill=fill)
    draw.ellipse([x0, y1-2*radius, x0+2*radius, y1], fill=fill)
    draw.ellipse([x1-2*radius, y1-2*radius, x1, y1], fill=fill)

def make_screen(w, h, bg_color, emoji, title, subtitle, accent_color=(100, 220, 130)):
    img = Image.new("RGB", (w, h), bg_color)
    draw = ImageDraw.Draw(img)

    # Emoji (large)
    emoji_size = int(h * 0.18)
    ef = get_emoji_font(emoji_size)
    ew, eh = draw.textbbox((0,0), emoji, font=ef)[2:4]
    draw.text(((w - ew) // 2, int(h * 0.10)), emoji, font=ef, embedded_color=True)

    # Title
    title_size = int(h * 0.075)
    tf = get_font(title_size)
    tw, th = draw.textbbox((0,0), title, font=tf)[2:4]
    ty = int(h * 0.37)
    draw.text(((w - tw) // 2, ty), title, font=tf, fill=(255, 255, 255))

    # Subtitle
    sub_size = int(h * 0.056)
    sf = get_font(sub_size)
    sw, sh = draw.textbbox((0,0), subtitle, font=sf)[2:4]
    sy = ty + th + int(h * 0.035)
    draw.text(((w - sw) // 2, sy), subtitle, font=sf, fill=(200, 200, 200))

    # Accent bar at bottom
    bar_y = h - int(h * 0.07)
    bar_h = int(h * 0.012)
    bw = int(w * 0.65)
    bx = (w - bw) // 2
    draw.rectangle([bx, bar_y, bx+bw, bar_y+bar_h], fill=accent_color)

    return img

def make_detail_screen(w, h, bg_color, metric_emoji, metric_text, detail, accent_color=(100, 220, 130)):
    img = Image.new("RGB", (w, h), bg_color)
    draw = ImageDraw.Draw(img)

    # Metric emoji
    emoji_size = int(h * 0.16)
    ef = get_emoji_font(emoji_size)
    ew, eh = draw.textbbox((0,0), metric_emoji, font=ef)[2:4]
    draw.text(((w - ew) // 2, int(h * 0.12)), metric_emoji, font=ef, embedded_color=True)

    # Metric text
    met_size = int(h * 0.085)
    mf = get_font(met_size)
    mw, mh = draw.textbbox((0,0), metric_text, font=mf)[2:4]
    my = int(h * 0.39)
    draw.text(((w - mw) // 2, my), metric_text, font=mf, fill=accent_color)

    # Detail text
    det_size = int(h * 0.058)
    df = get_font(det_size)
    dw, dh = draw.textbbox((0,0), detail, font=df)[2:4]
    dy = my + mh + int(h * 0.04)
    draw.text(((w - dw) // 2, dy), detail, font=df, fill=(180, 180, 180))

    # Progress bar
    bar_y = int(h * 0.78)
    bar_h = int(h * 0.018)
    bw = int(w * 0.7)
    bx = (w - bw) // 2
    draw.rectangle([bx, bar_y, bx+bw, bar_y+bar_h], fill=(60, 60, 60))
    draw.rectangle([bx, bar_y, bx+int(bw*0.75), bar_y+bar_h], fill=accent_color)

    return img

GAMES = [
    {
        "repo": "distractiondodge",
        "bg": (8, 13, 46),
        "accent": (100, 220, 130),
        "screen1": ("🥷", "Distraction", "Dodge", "Focus Ninja"),
        "screen2": ("🧘", "ZEN FOCUS", "Score: 24", (100, 220, 130)),
    },
    {
        "repo": "cairnbuilder",
        "bg": (13, 26, 20),
        "accent": (100, 200, 120),
        "screen1": ("🏔", "Cairn", "Builder", "Stack focus"),
        "screen2": ("⏱", "18:32", "Focus mode", (100, 200, 120)),
    },
    {
        "repo": "onetaskarena",
        "bg": (20, 10, 46),
        "accent": (180, 100, 220),
        "screen1": ("⚔️", "One-Task", "Arena", "Boss fight focus"),
        "screen2": ("🐍", "HP: 45/100", "ATTACKING", (220, 80, 80)),
    },
    {
        "repo": "inboxcritters",
        "bg": (10, 15, 41),
        "accent": (100, 130, 220),
        "screen1": ("🐭", "Inbox", "Critters", "Brain dump game"),
        "screen2": ("🧠", "7 sorted", "MIT/High/Normal", (100, 130, 220)),
    },
    {
        "repo": "breakquest",
        "bg": (10, 18, 51),
        "accent": (80, 130, 220),
        "screen1": ("🧙", "Break", "Quest", "Breathe & earn loot"),
        "screen2": ("🫁", "Breathe In", "4 seconds", (80, 130, 220)),
    },
    {
        "repo": "streakvillage",
        "bg": (10, 26, 15),
        "accent": (80, 200, 100),
        "screen1": ("🏘️", "Streak", "Village", "Daily builder"),
        "screen2": ("🔥", "7 days", "Keep going!", (255, 160, 40)),
    },
]

for game in GAMES:
    out_dir = f"/Users/tosaojiru/src/repos/{game['repo']}/AppStore/screenshots/en-US"
    os.makedirs(out_dir, exist_ok=True)
    bg = game["bg"]
    accent = game["accent"]
    e1, t1a, t1b, sub = game["screen1"]
    e2, met, det, acc2 = game["screen2"]

    for w, h in SIZES:
        label = f"{w}x{h}"
        # Screen 1: Home
        img = make_screen(w, h, bg, e1, t1a+" "+t1b, sub, accent)
        img.save(f"{out_dir}/watch-01-home-{label}.jpg", "JPEG", quality=92)
        print(f"⌚ watch-01-home-{label}.jpg  ({w}×{h})")

        # Screen 2: Detail/metric
        img2 = make_detail_screen(w, h, bg, e2, met, det, acc2)
        img2.save(f"{out_dir}/watch-02-detail-{label}.jpg", "JPEG", quality=92)
        print(f"⌚ watch-02-detail-{label}.jpg  ({w}×{h})")

print("\nDone! Generated", len(GAMES) * len(SIZES) * 2, "watch screenshots")
