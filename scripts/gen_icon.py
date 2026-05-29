#!/usr/bin/env python3
"""生成 TextPocket 应用图标"""
from PIL import Image, ImageDraw, ImageFont
import math

SIZE = 1024

def draw_rounded_rect(draw, xy, radius, fill, outline=None, width=0):
    x0, y0, x1, y1 = xy
    draw.rounded_rectangle(xy, radius=radius, fill=fill, outline=outline, width=width)

def create_icon():
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # 背景：渐变圆角矩形
    for y in range(SIZE):
        ratio = y / SIZE
        r = int(52 + ratio * 20)
        g = int(120 + ratio * 30)
        b = int(246 - ratio * 30)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b))

    # 圆角遮罩
    mask = Image.new("L", (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (SIZE, SIZE)], radius=220, fill=255)
    img.putalpha(mask)

    # 重新获取 draw（alpha 通道变化后）
    draw = ImageDraw.Draw(img)

    # 剪贴板底板（白色卡片）
    board_margin = 140
    board_top = 180
    board_bottom = SIZE - 100
    board_r = 60
    draw_rounded_rect(draw,
        (board_margin, board_top, SIZE - board_margin, board_bottom),
        radius=board_r, fill=(255, 255, 255, 230))

    # 剪贴板顶部夹子
    clip_w = 260
    clip_h = 80
    clip_x = (SIZE - clip_w) // 2
    clip_y = board_top - 30
    draw_rounded_rect(draw,
        (clip_x, clip_y, clip_x + clip_w, clip_y + clip_h),
        radius=30, fill=(200, 210, 230), outline=(170, 185, 210), width=4)

    # 夹子中间的圆孔
    hole_r = 22
    hole_cx = SIZE // 2
    hole_cy = clip_y + clip_h // 2
    draw.ellipse(
        (hole_cx - hole_r, hole_cy - hole_r, hole_cx + hole_r, hole_cy + hole_r),
        fill=(52, 120, 246))

    # 文本行（模拟剪贴板内容）
    line_y_start = board_top + 120
    line_gap = 75
    line_margin = board_margin + 80
    line_height = 28

    # 深色文本行
    line_colors = [
        (52, 120, 246),   # 蓝色（标题行）
        (80, 80, 95),     # 深灰
        (140, 145, 160),  # 浅灰
        (80, 80, 95),
        (140, 145, 160),
    ]
    line_widths = [0.7, 0.85, 0.55, 0.75, 0.4]

    for i, (color, w_ratio) in enumerate(zip(line_colors, line_widths)):
        y = line_y_start + i * line_gap
        x1 = line_margin
        x2 = x1 + (SIZE - 2 * line_margin) * w_ratio
        r = line_height // 2
        draw_rounded_rect(draw, (x1, y, int(x2), y + line_height), radius=r, fill=(*color, 180))

    # 右下角小口袋图标（装饰）
    pocket_x = SIZE - board_margin - 160
    pocket_y = board_bottom - 160
    pocket_size = 100
    draw_rounded_rect(draw,
        (pocket_x, pocket_y, pocket_x + pocket_size, pocket_y + pocket_size),
        radius=20, fill=(52, 120, 246, 60))
    # 口袋里的小勾
    draw.line(
        [(pocket_x + 25, pocket_y + 55), (pocket_x + 42, pocket_y + 72), (pocket_x + 75, pocket_y + 35)],
        fill=(52, 120, 246), width=10, joint="curve")

    return img

if __name__ == "__main__":
    icon = create_icon()
    icon.save("TextPocket/Resources/AppIcon.png")
    print("✅ AppIcon.png 已生成")
