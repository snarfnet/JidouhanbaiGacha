from PIL import Image, ImageDraw, ImageFont
import os

def generate_icon(size, output_path):
    img = Image.new('RGB', (size, size))
    draw = ImageDraw.Draw(img)

    # Dark blue gradient background
    for y in range(size):
        r = int(20 + (y / size) * 10)
        g = int(20 + (y / size) * 10)
        b = int(50 + (y / size) * 30)
        draw.line([(0, y), (size, y)], fill=(r, g, b))

    # Vending machine body (gray rectangle)
    margin = size * 0.15
    machine_left = margin
    machine_right = size - margin
    machine_top = size * 0.08
    machine_bottom = size * 0.85
    draw.rounded_rectangle(
        [machine_left, machine_top, machine_right, machine_bottom],
        radius=size * 0.05,
        fill=(70, 70, 80)
    )

    # Display window (dark blue)
    win_margin = size * 0.22
    win_top = size * 0.14
    win_bottom = size * 0.55
    draw.rounded_rectangle(
        [win_margin, win_top, size - win_margin, win_bottom],
        radius=size * 0.03,
        fill=(30, 40, 70)
    )

    # Drink cans in display (colorful small rectangles)
    colors = [(255, 80, 80), (80, 150, 255), (80, 200, 100), (255, 200, 50), (200, 80, 200),
              (255, 140, 60), (80, 200, 200), (255, 100, 150), (100, 200, 80)]
    can_w = size * 0.06
    can_h = size * 0.10
    start_x = win_margin + size * 0.04
    start_y = win_top + size * 0.04
    idx = 0
    for row in range(3):
        for col in range(3):
            cx = start_x + col * (can_w + size * 0.04)
            cy = start_y + row * (can_h + size * 0.02)
            color = colors[idx % len(colors)]
            draw.rounded_rectangle(
                [cx, cy, cx + can_w, cy + can_h],
                radius=size * 0.01,
                fill=color
            )
            idx += 1

    # Dispense slot (black rectangle at bottom of machine)
    slot_top = size * 0.62
    slot_bottom = size * 0.72
    slot_left = size * 0.28
    slot_right = size - size * 0.28
    draw.rounded_rectangle(
        [slot_left, slot_top, slot_right, slot_bottom],
        radius=size * 0.02,
        fill=(20, 20, 30)
    )

    # Orange button
    btn_cx = size * 0.65
    btn_cy = size * 0.58
    btn_r = size * 0.04
    draw.ellipse([btn_cx - btn_r, btn_cy - btn_r, btn_cx + btn_r, btn_cy + btn_r], fill=(255, 160, 40))

    # "GACHA" text at bottom
    try:
        font_size = int(size * 0.10)
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", font_size)
    except:
        try:
            font = ImageFont.truetype("C:/Windows/Fonts/arialbd.ttf", font_size)
        except:
            font = ImageFont.load_default()

    text = "GACHA"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    tx = (size - tw) / 2
    ty = size * 0.86
    draw.text((tx, ty), text, fill=(255, 180, 50), font=font)

    img.save(output_path, 'PNG')

sizes = {
    'icon-20@2x.png': 40,
    'icon-20@3x.png': 60,
    'icon-29@2x.png': 58,
    'icon-29@3x.png': 87,
    'icon-40@2x.png': 80,
    'icon-40@3x.png': 120,
    'icon-60@2x.png': 120,
    'icon-60@3x.png': 180,
    'icon-1024.png': 1024,
}

out_dir = os.path.join(os.path.dirname(__file__), '..', 'JidouhanbaiGacha', 'Resources', 'Assets.xcassets', 'AppIcon.appiconset')
os.makedirs(out_dir, exist_ok=True)

for filename, size in sizes.items():
    path = os.path.join(out_dir, filename)
    generate_icon(size, path)
    print(f"Generated {filename} ({size}x{size})")
