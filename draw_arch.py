#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import os

W, H = 2500, 1000  # 5:2 ratio
BG = "#0d1117"
img = Image.new("RGB", (W, H), BG)
draw = ImageDraw.Draw(img)

# Use a font that supports Turkish characters
def get_font(size):
    for path in [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/SFNSText.ttf",
        "/System/Library/Fonts/SFNS.ttf",
        "/Library/Fonts/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
    ]:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except:
                pass
    return ImageFont.load_default()

font_title = get_font(22)
font_body = get_font(15)
font_label = get_font(13)
font_arrow = get_font(12)
font_heading = get_font(28)

# Layer definitions
layers = [
    {
        "x": 40, "y": 80, "w": 310, "h": 820,
        "bg": "#1b2d4a", "border": "#58a6ff", "title": "CLI Katmanı",
        "subtitle": "swift-argument-parser",
        "items": ["check", "review", "improve", "search", "add", "scrape", "stats"],
        "item_bg": "#264166", "item_border": "#58a6ff",
    },
    {
        "x": 430, "y": 80, "w": 310, "h": 820,
        "bg": "#1a3a2a", "border": "#3fb950", "title": "İçerik Girdisi",
        "subtitle": "Makale toplama & önbellek",
        "items": ["Scraper\nURL fetch\nSwiftSoup HTML", "Add\nYerel .md dosyaları", "~/.yazman/\ncorpus/ önbellek"],
        "item_bg": "#234d34", "item_border": "#3fb950",
    },
    {
        "x": 820, "y": 80, "w": 310, "h": 820,
        "bg": "#2a3a1a", "border": "#8bc34a", "title": "RAG Boru Hattı",
        "subtitle": "Aktör tabanlı vektör araması",
        "items": ["Parçalama\n500 kar / 100 örtüşme", "Embedding\nnomic-embed-text", "SIMD Cosine\nAccelerate vDSP", "embeddings.json\ndisk deposu"],
        "item_bg": "#3a4d24", "item_border": "#8bc34a",
    },
    {
        "x": 1210, "y": 80, "w": 310, "h": 820,
        "bg": "#2a1a3a", "border": "#bc8cff", "title": "Denetim Motoru",
        "subtitle": "Analiz & akış çıktısı",
        "items": ["Checker", "Paragraf çıkarma", "RAG bağlam inşası", "LLM akışı"],
        "item_bg": "#3d2654", "item_border": "#bc8cff",
    },
    {
        "x": 1600, "y": 80, "w": 310, "h": 820,
        "bg": "#3a2a0a", "border": "#d29922", "title": "Ollama",
        "subtitle": "Yerel LLM Sunucusu",
        "items": ["gemma3:4b\nMetin üretimi", "nomic-embed-text\nGömme üretimi", "Lifecycle\nbrew svc\nsinyal yönetimi"],
        "item_bg": "#4d3a14", "item_border": "#d29922",
    },
    {
        "x": 1990, "y": 80, "w": 470, "h": 820,
        "bg": "#2a1a2a", "border": "#e57373", "title": "Terminal Çıktısı",
        "subtitle": "Rainbow · OSLog",
        "items": ["Spinner\nBraille animasyonu\nkelime açılması", "İlerleme çubuğu\n& yüzde göstergesi", "Rainbow\nrenkli çıktı", "OSLog\nyapısal günlük\n5 kategori"],
        "item_bg": "#3d2434", "item_border": "#e57373",
    },
]

def rounded_rect(draw, xy, radius, fill, outline, width=2):
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)

def text_center(draw, text, x, y, w, font, fill):
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    draw.text((x + (w - tw) // 2, y), text, font=font, fill=fill)

# Draw layers
for layer in layers:
    lx, ly, lw, lh = layer["x"], layer["y"], layer["w"], layer["h"]

    # Layer background
    rounded_rect(draw, (lx, ly, lx + lw, ly + lh), 12, layer["bg"], layer["border"], 2)

    # Title
    text_center(draw, layer["title"], lx, ly + 15, lw, font_title, "#ffffff")

    # Subtitle
    text_center(draw, layer["subtitle"], lx, ly + 45, lw, font_label, "#888888")

    # Items
    items = layer["items"]
    item_margin = 15
    available_h = lh - 90
    item_gap = 12
    total_gaps = (len(items) - 1) * item_gap
    item_h = (available_h - total_gaps - item_margin * 2) // len(items)

    for i, item in enumerate(items):
        ix = lx + item_margin
        iy = ly + 80 + i * (item_h + item_gap)
        iw = lw - item_margin * 2
        ih = item_h

        rounded_rect(draw, (ix, iy, ix + iw, iy + ih), 8, layer["item_bg"], layer["item_border"], 1)

        lines = item.split("\n")
        total_text_h = len(lines) * 20
        start_y = iy + (ih - total_text_h) // 2
        for j, line in enumerate(lines):
            text_center(draw, line, ix, start_y + j * 20, iw, font_body, "#e6edf3")

# Draw arrows between layers
arrow_color = "#6b7b8d"
arrow_pairs = [
    (350, 490, 430, 490),
    (740, 490, 820, 490),
    (1130, 490, 1210, 490),
    (1520, 490, 1600, 490),
    (1910, 490, 1990, 490),
]

for x1, y1, x2, y2 in arrow_pairs:
    draw.line([(x1, y1), (x2, y2)], fill=arrow_color, width=3)
    aw = 10
    draw.polygon([(x2, y2), (x2 - aw, y2 - aw // 2), (x2 - aw, y2 + aw // 2)], fill=arrow_color)

# Arrow labels
labels = [
    (360, 460, "komutlar"),
    (750, 460, "makaleler"),
    (1140, 460, "benzer\nparçalar"),
    (1530, 460, "LLM\nistekleri"),
    (1920, 460, "yanıtlar"),
]
for x, y, label in labels:
    for i, line in enumerate(label.split("\n")):
        draw.text((x, y + i * 15), line, font=font_arrow, fill="#888888")

# Top title
title = "Yazman — Sistem Mimarisi"
bbox = draw.textbbox((0, 0), title, font=font_heading)
tw = bbox[2] - bbox[0]
draw.text(((W - tw) // 2, 25), title, font=font_heading, fill="#e6edf3")

# Bottom note
note = "Tüm işlem yerel makinenizde gerçekleşir — veri dışarıya çıkmaz."
bbox = draw.textbbox((0, 0), note, font=font_label)
tw = bbox[2] - bbox[0]
draw.text(((W - tw) // 2, H - 40), note, font=font_label, fill="#666666")

# Save at 2x for sharpness
img = img.resize((W * 2, H * 2), Image.LANCZOS)
img.save("/Users/alp/Development/Yazman/architecture.png", "PNG")
print(f"Saved {W*2}x{H*2} (5:2 ratio)")
