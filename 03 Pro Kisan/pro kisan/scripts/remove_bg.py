import os
import math
from PIL import Image

ASSETS_DIR = r"c:\Users\Admin\Desktop\my project\MASS APP\03 Pro Kisan\pro kisan\assets\images"
EXCLUDE = ["header_farm_banner.png"]

def is_background_color(r, g, b, a, bg_sample):
    if a == 0:
        return True
    
    # 1. Color distance from corner background sample
    sr, sg, sb, _ = bg_sample
    color_dist = math.sqrt((r - sr)**2 + (g - sg)**2 + (b - sb)**2)
    if color_dist < 65:
        return True
        
    # 2. Light grey or off-white background (brightness > 140 and r,g,b low variance)
    if r > 140 and g > 140 and b > 140:
        if max(abs(r - g), abs(g - b), abs(r - b)) < 30:
            return True
            
    return False

def make_transparent(file_path):
    img = Image.open(file_path).convert("RGBA")
    width, height = img.size
    pixels = img.load()
    
    # Sample corner pixels for initial background color
    corners = [pixels[0, 0], pixels[width - 1, 0], pixels[0, height - 1], pixels[width - 1, height - 1]]
    bg_sample = (220, 220, 220, 255)
    for c in corners:
        if c[3] > 0:
            bg_sample = c
            break
            
    visited = set()
    queue = []
    
    # Add border pixels to queue if they match background criterion
    for x in range(width):
        for y in [0, height - 1]:
            r, g, b, a = pixels[x, y]
            if is_background_color(r, g, b, a, bg_sample):
                queue.append((x, y))
                visited.add((x, y))
                
    for y in range(height):
        for x in [0, width - 1]:
            r, g, b, a = pixels[x, y]
            if (x, y) not in visited and is_background_color(r, g, b, a, bg_sample):
                queue.append((x, y))
                visited.add((x, y))
                
    # BFS flood fill to remove background
    while queue:
        cx, cy = queue.pop(0)
        pixels[cx, cy] = (0, 0, 0, 0)
        
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < width and 0 <= ny < height:
                if (nx, ny) not in visited:
                    r, g, b, a = pixels[nx, ny]
                    if is_background_color(r, g, b, a, bg_sample):
                        visited.add((nx, ny))
                        queue.append((nx, ny))
                        
    # Edge anti-aliasing / smoothing pass
    for x in range(1, width - 1):
        for y in range(1, height - 1):
            r, g, b, a = pixels[x, y]
            if a > 0:
                has_transparent = any(pixels[x + dx, y + dy][3] == 0 for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)])
                if has_transparent:
                    sr, sg, sb, _ = bg_sample
                    dist = math.sqrt((r - sr)**2 + (g - sg)**2 + (b - sb)**2)
                    if dist < 85:
                        new_alpha = int(a * (dist / 85.0))
                        pixels[x, y] = (r, g, b, new_alpha)

    img.save(file_path, "PNG")
    print(f"Processed: {os.path.basename(file_path)}")

def main():
    count = 0
    for filename in os.listdir(ASSETS_DIR):
        if filename.endswith(".png") and filename not in EXCLUDE:
            full_path = os.path.join(ASSETS_DIR, filename)
            make_transparent(full_path)
            count += 1
    print(f"Total {count} PNG images converted to transparent background!")

if __name__ == "__main__":
    main()
