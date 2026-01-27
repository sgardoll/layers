#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

FONTS_DIR = "/Users/home/.claude/skills/canvas-design/canvas-fonts"
OUTPUT_DIR = "/Users/home/Projects/layers/assets/screenshots"

SCREEN_SIZES = {
    "ios": (1290, 2796),
    "android": (1080, 2400),
    "macos": (2880, 1800),
}

INDIGO = (99, 102, 241)
VIOLET = (139, 92, 246)
SOFT_WHITE = (250, 250, 255)
MID_GRAY = (120, 120, 140)


def create_gradient_background(width, height, color1, color2, vertical=True):
    img = Image.new('RGB', (width, height))
    draw = ImageDraw.Draw(img)
    
    if vertical:
        for y in range(height):
            ratio = y / height
            r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
            g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
            b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
            draw.line([(0, y), (width, y)], fill=(r, g, b))
    else:
        for x in range(width):
            ratio = x / width
            r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
            g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
            b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
            draw.line([(x, 0), (x, height)], fill=(r, g, b))
    
    return img


def draw_rounded_rect(draw, bounds, radius, fill=None):
    x1, y1, x2, y2 = bounds
    draw.rectangle([x1 + radius, y1, x2 - radius, y2], fill=fill)
    draw.rectangle([x1, y1 + radius, x2, y2 - radius], fill=fill)
    draw.pieslice([x1, y1, x1 + 2*radius, y1 + 2*radius], 180, 270, fill=fill)
    draw.pieslice([x2 - 2*radius, y1, x2, y1 + 2*radius], 270, 360, fill=fill)
    draw.pieslice([x1, y2 - 2*radius, x1 + 2*radius, y2], 90, 180, fill=fill)
    draw.pieslice([x2 - 2*radius, y2 - 2*radius, x2, y2], 0, 90, fill=fill)


def create_floating_layer(width, height, color, opacity=255):
    layer = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    radius = max(12, int(width * 0.03))
    draw_rounded_rect(draw, (0, 0, width-1, height-1), radius, fill=(*color, opacity))
    return layer


def add_shadow_to_layer(img, layer, pos, blur=20):
    shadow = Image.new('RGBA', (layer.width + 80, layer.height + 80), (0, 0, 0, 0))
    shadow.paste(layer, (40, 40))
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    shadow_data = list(shadow.getdata())
    new_shadow_data = [(r//5, g//5, b//5, a//3) for r, g, b, a in shadow_data]
    shadow.putdata(new_shadow_data)
    img.paste(shadow, (pos[0] - 40, pos[1]), shadow)
    img.paste(layer, pos, layer)


def load_fonts(scale=1.0):
    try:
        return {
            'title': ImageFont.truetype(f"{FONTS_DIR}/InstrumentSans-Bold.ttf", int(72 * scale)),
            'subtitle': ImageFont.truetype(f"{FONTS_DIR}/InstrumentSans-Regular.ttf", int(36 * scale)),
            'label': ImageFont.truetype(f"{FONTS_DIR}/GeistMono-Regular.ttf", int(24 * scale)),
            'step': ImageFont.truetype(f"{FONTS_DIR}/InstrumentSans-Bold.ttf", int(48 * scale)),
            'num': ImageFont.truetype(f"{FONTS_DIR}/GeistMono-Bold.ttf", int(36 * scale)),
        }
    except:
        default = ImageFont.load_default()
        return {k: default for k in ['title', 'subtitle', 'label', 'step', 'num']}


def screenshot_1_hero(width, height, platform="ios"):
    is_landscape = width > height
    scale = width / 1290 if not is_landscape else height / 1290
    
    bg = create_gradient_background(width, height, (20, 20, 35), (10, 10, 20))
    img = bg.convert('RGBA')
    draw = ImageDraw.Draw(img)
    fonts = load_fonts(scale)
    
    if is_landscape:
        title_y = int(80 * scale)
        subtitle_y = int(160 * scale)
        layer_base_y = int(280 * scale)
        layer_w, layer_h = int(500 * scale), int(320 * scale)
        layer_offset_x = int(80 * scale)
        layer_offset_y = int(120 * scale)
        tagline_y = height - int(150 * scale)
    else:
        title_y = int(180 * scale)
        subtitle_y = int(280 * scale)
        layer_base_y = int(800 * scale)
        layer_w, layer_h = int(800 * scale), int(500 * scale)
        layer_offset_x = int(60 * scale)
        layer_offset_y = int(180 * scale)
        tagline_y = height - int(300 * scale)
    
    title = "See What's Hidden"
    bbox = draw.textbbox((0, 0), title, font=fonts['title'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, title_y), title, fill=SOFT_WHITE, font=fonts['title'])
    
    subtitle = "AI-powered layer extraction"
    bbox = draw.textbbox((0, 0), subtitle, font=fonts['subtitle'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, subtitle_y), subtitle, fill=MID_GRAY, font=fonts['subtitle'])
    
    center_x = width // 2
    layers_data = [
        (layer_w, layer_h, INDIGO, 180, -layer_offset_x, 0),
        (int(layer_w * 0.95), int(layer_h * 0.94), VIOLET, 220, 0, layer_offset_y),
        (int(layer_w * 0.9), int(layer_h * 0.88), SOFT_WHITE, 255, layer_offset_x, layer_offset_y * 2),
    ]
    
    for lw, lh, color, opacity, x_off, y_off in layers_data:
        layer = create_floating_layer(lw, lh, color, opacity)
        pos = (center_x - lw // 2 + x_off, layer_base_y + y_off)
        add_shadow_to_layer(img, layer, pos, int(30 * scale))
    
    tagline = "Layers"
    bbox = draw.textbbox((0, 0), tagline, font=fonts['title'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, tagline_y), tagline, fill=SOFT_WHITE, font=fonts['title'])
    
    return img.convert('RGB')


def screenshot_2_3d_viewer(width, height, platform="ios"):
    is_landscape = width > height
    scale = width / 1290 if not is_landscape else height / 1290
    
    bg = create_gradient_background(width, height, (30, 25, 60), (10, 10, 20))
    img = bg.convert('RGBA')
    draw = ImageDraw.Draw(img)
    fonts = load_fonts(scale)
    
    if is_landscape:
        title_y = int(80 * scale)
        subtitle_y = int(150 * scale)
        center_y = height // 2 + int(50 * scale)
        layer_w, layer_h = int(450 * scale), int(290 * scale)
        spacing = int(100 * scale)
    else:
        title_y = int(180 * scale)
        subtitle_y = int(270 * scale)
        center_y = height // 2 + int(100 * scale)
        layer_w, layer_h = int(700 * scale), int(450 * scale)
        spacing = int(120 * scale)
    
    title = "Explore in 3D"
    bbox = draw.textbbox((0, 0), title, font=fonts['title'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, title_y), title, fill=SOFT_WHITE, font=fonts['title'])
    
    subtitle = "Navigate layers in dimensional space"
    bbox = draw.textbbox((0, 0), subtitle, font=fonts['subtitle'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, subtitle_y), subtitle, fill=MID_GRAY, font=fonts['subtitle'])
    
    center_x = width // 2
    num_layers = 5
    
    for i in range(num_layers):
        offset = (i - num_layers // 2) * spacing
        y_offset = abs(i - num_layers // 2) * int(40 * scale)
        layer_scale = 1.0 - abs(i - num_layers // 2) * 0.08
        
        lw = int(layer_w * layer_scale)
        lh = int(layer_h * layer_scale)
        
        if i == num_layers // 2:
            color, opacity = SOFT_WHITE, 255
        else:
            t = abs(i - num_layers // 2) / (num_layers // 2)
            color = (
                int(INDIGO[0] * (1 - t) + VIOLET[0] * t),
                int(INDIGO[1] * (1 - t) + VIOLET[1] * t),
                int(INDIGO[2] * (1 - t) + VIOLET[2] * t),
            )
            opacity = int(255 - t * 100)
        
        layer = create_floating_layer(lw, lh, color, opacity)
        pos = (center_x - lw // 2 + offset, center_y - lh // 2 + y_offset)
        add_shadow_to_layer(img, layer, pos, int(25 * scale))
    
    return img.convert('RGB')


def screenshot_3_export(width, height, platform="ios"):
    is_landscape = width > height
    scale = width / 1290 if not is_landscape else height / 1290
    
    bg = create_gradient_background(width, height, (25, 20, 45), (15, 15, 25))
    img = bg.convert('RGBA')
    draw = ImageDraw.Draw(img)
    fonts = load_fonts(scale)
    
    if is_landscape:
        title_y = int(80 * scale)
        subtitle_y = int(150 * scale)
        card_width = int(500 * scale)
        card_height = int(140 * scale)
        start_y = int(280 * scale)
        gap = int(170 * scale)
        cards_horizontal = True
    else:
        title_y = int(180 * scale)
        subtitle_y = int(270 * scale)
        card_width = int(900 * scale)
        card_height = int(180 * scale)
        start_y = int(450 * scale)
        gap = int(220 * scale)
        cards_horizontal = False
    
    title = "Export Anywhere"
    bbox = draw.textbbox((0, 0), title, font=fonts['title'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, title_y), title, fill=SOFT_WHITE, font=fonts['title'])
    
    subtitle = "PNG, ZIP, or Layers Pack"
    bbox = draw.textbbox((0, 0), subtitle, font=fonts['subtitle'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, subtitle_y), subtitle, fill=MID_GRAY, font=fonts['subtitle'])
    
    options = [
        ("PNG", "Transparent layers"),
        ("ZIP", "All layers packaged"),
        ("Pack", "Editable format"),
    ]
    
    if cards_horizontal:
        total_width = len(options) * card_width + (len(options) - 1) * int(40 * scale)
        start_x = (width - total_width) // 2
        
        for i, (name, desc) in enumerate(options):
            x = start_x + i * (card_width + int(40 * scale))
            y = start_y
            
            card = create_floating_layer(card_width, card_height, (40, 35, 65), 230)
            add_shadow_to_layer(img, card, (x, y), int(20 * scale))
            
            icon_x = x + int(30 * scale)
            icon_y = y + card_height // 2
            draw.ellipse([icon_x, icon_y - int(25 * scale), icon_x + int(50 * scale), icon_y + int(25 * scale)], fill=INDIGO)
            
            draw.text((x + int(100 * scale), y + int(30 * scale)), name, fill=SOFT_WHITE, font=fonts['step'])
            draw.text((x + int(100 * scale), y + int(85 * scale)), desc, fill=MID_GRAY, font=fonts['label'])
    else:
        card_x = (width - card_width) // 2
        
        for i, (name, desc) in enumerate(options):
            y = start_y + i * gap
            
            card = create_floating_layer(card_width, card_height, (40, 35, 65), 230)
            add_shadow_to_layer(img, card, (card_x, y), int(20 * scale))
            
            icon_x = card_x + int(50 * scale)
            icon_y = y + card_height // 2
            draw.ellipse([icon_x, icon_y - int(35 * scale), icon_x + int(70 * scale), icon_y + int(35 * scale)], fill=INDIGO)
            
            draw.text((card_x + int(150 * scale), y + int(45 * scale)), name, fill=SOFT_WHITE, font=fonts['title'])
            draw.text((card_x + int(150 * scale), y + int(115 * scale)), desc, fill=MID_GRAY, font=fonts['label'])
    
    return img.convert('RGB')


def screenshot_4_projects(width, height, platform="ios"):
    is_landscape = width > height
    scale = width / 1290 if not is_landscape else height / 1290
    
    bg = create_gradient_background(width, height, (20, 25, 40), (10, 12, 22))
    img = bg.convert('RGBA')
    draw = ImageDraw.Draw(img)
    fonts = load_fonts(scale)
    
    if is_landscape:
        title_y = int(60 * scale)
        subtitle_y = int(130 * scale)
        card_size = int(320 * scale)
        cols, rows = 4, 2
        start_y = int(220 * scale)
    else:
        title_y = int(180 * scale)
        subtitle_y = int(270 * scale)
        card_size = int(520 * scale)
        cols, rows = 2, 3
        start_y = int(420 * scale)
    
    title = "Your Projects"
    bbox = draw.textbbox((0, 0), title, font=fonts['title'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, title_y), title, fill=SOFT_WHITE, font=fonts['title'])
    
    subtitle = "Saved in the cloud"
    bbox = draw.textbbox((0, 0), subtitle, font=fonts['subtitle'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, subtitle_y), subtitle, fill=MID_GRAY, font=fonts['subtitle'])
    
    gap = int(50 * scale)
    total_w = cols * card_size + (cols - 1) * gap
    start_x = (width - total_w) // 2
    
    colors = [INDIGO, VIOLET, (100, 140, 230), (140, 100, 200), (80, 120, 200), (120, 80, 180), (90, 110, 220), (150, 90, 190)]
    
    for row in range(rows):
        for col in range(cols):
            x = start_x + col * (card_size + gap)
            y = start_y + row * (card_size + gap)
            idx = row * cols + col
            
            card = create_floating_layer(card_size, card_size, colors[idx % len(colors)], 200)
            add_shadow_to_layer(img, card, (x, y), int(20 * scale))
            
            label = f"{3 + idx} layers"
            draw.text((x + int(20 * scale), y + card_size - int(40 * scale)), label, fill=SOFT_WHITE, font=fonts['label'])
    
    return img.convert('RGB')


def screenshot_5_simple(width, height, platform="ios"):
    is_landscape = width > height
    scale = width / 1290 if not is_landscape else height / 1290
    
    bg = create_gradient_background(width, height, (15, 15, 30), (8, 8, 18))
    img = bg.convert('RGBA')
    draw = ImageDraw.Draw(img)
    fonts = load_fonts(scale)
    
    if is_landscape:
        title_y = int(60 * scale)
        step_y = int(200 * scale)
        step_gap = int(0 * scale)
        horizontal_steps = True
    else:
        title_y = int(180 * scale)
        step_y = int(450 * scale)
        step_gap = int(550 * scale)
        horizontal_steps = False
    
    title = "Three Simple Steps"
    bbox = draw.textbbox((0, 0), title, font=fonts['title'])
    draw.text(((width - bbox[2] + bbox[0]) // 2, title_y), title, fill=SOFT_WHITE, font=fonts['title'])
    
    steps = [("Import", "Choose any image"), ("Extract", "AI finds layers"), ("Export", "Save & share")]
    
    if horizontal_steps:
        step_width = int(400 * scale)
        total_w = len(steps) * step_width
        start_x = (width - total_w) // 2
        
        for i, (name, desc) in enumerate(steps):
            x = start_x + i * step_width + step_width // 2
            y = step_y
            
            circle_r = int(50 * scale)
            draw.ellipse([x - circle_r, y, x + circle_r, y + circle_r * 2], fill=INDIGO)
            draw.text((x - int(12 * scale), y + int(25 * scale)), str(i + 1), fill=SOFT_WHITE, font=fonts['num'])
            
            draw.text((x - int(60 * scale), y + int(130 * scale)), name, fill=SOFT_WHITE, font=fonts['step'])
            bbox = draw.textbbox((0, 0), desc, font=fonts['subtitle'])
            draw.text((x - (bbox[2] - bbox[0]) // 2, y + int(190 * scale)), desc, fill=MID_GRAY, font=fonts['subtitle'])
    else:
        for i, (name, desc) in enumerate(steps):
            y = step_y + i * step_gap
            num_x = width // 2 - int(350 * scale)
            
            draw.ellipse([num_x, y, num_x + int(100 * scale), y + int(100 * scale)], fill=INDIGO)
            draw.text((num_x + int(35 * scale), y + int(25 * scale)), str(i + 1), fill=SOFT_WHITE, font=fonts['num'])
            
            draw.text((num_x + int(150 * scale), y + int(10 * scale)), name, fill=SOFT_WHITE, font=fonts['step'])
            draw.text((num_x + int(150 * scale), y + int(65 * scale)), desc, fill=MID_GRAY, font=fonts['subtitle'])
            
            if i < len(steps) - 1:
                line_x = num_x + int(50 * scale)
                draw.line([(line_x, y + int(110 * scale)), (line_x, y + step_gap - int(10 * scale))], fill=INDIGO, width=3)
    
    return img.convert('RGB')


def main():
    print("Generating App Store screenshots for all platforms...")
    
    screenshots = [
        (screenshot_1_hero, "01_hero"),
        (screenshot_2_3d_viewer, "02_3d_viewer"),
        (screenshot_3_export, "03_export"),
        (screenshot_4_projects, "04_projects"),
        (screenshot_5_simple, "05_simple"),
    ]
    
    for platform, (width, height) in SCREEN_SIZES.items():
        platform_dir = os.path.join(OUTPUT_DIR, platform)
        os.makedirs(platform_dir, exist_ok=True)
        print(f"\n{platform.upper()} ({width}x{height}):")
        
        for func, name in screenshots:
            filename = f"{name}.png"
            print(f"  Creating {filename}...")
            img = func(width, height, platform)
            output_path = os.path.join(platform_dir, filename)
            img.save(output_path, "PNG", quality=95)
    
    print(f"\nDone! Screenshots saved to: {OUTPUT_DIR}")
    print("  - ios/     (1290x2796)")
    print("  - android/ (1080x2400)")
    print("  - macos/   (2880x1800)")


if __name__ == "__main__":
    main()
