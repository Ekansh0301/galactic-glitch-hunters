import os
import re

scenes = [
    "Game/Scenes/hub.tscn",
    "Game/Scenes/hub_new.tscn"
]

def restore_leaderboard(filepath):
    if not os.path.exists(filepath): return
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    # Step 1: Remove all current [node name="LeaderboardButton" ...] blocks
    lines = content.split('\n')
    out_lines = []
    skip = False
    for line in lines:
        if line.startswith('[node name="LeaderboardButton"'):
            skip = True
            continue
        if skip and (line.startswith('[node ') or line.startswith('[connection ')):
            skip = False
        
        if not skip:
            out_lines.append(line)
            
    # Step 2: Insert the LeaderboardButton correctly under TopRightButtons
    # First, find where TopRightButtons is declared
    trb_idx = -1
    for i, line in enumerate(out_lines):
        if line.startswith('[node name="TopRightButtons"'):
            trb_idx = i
            break
            
    if trb_idx != -1:
        # Find the next [node block after TopRightButtons starts
        insert_idx = -1
        for i in range(trb_idx + 1, len(out_lines)):
            if out_lines[i].startswith('[node '):
                insert_idx = i
                break
        if insert_idx == -1:
            insert_idx = len(out_lines)
            
        # Also need to extract the theme id for secondary_button_theme.tres just in case it isn't exactly 4_theme
        theme_match = re.search(r'\[ext_resource[^>]*path="res://Assets/themes/secondary_button_theme.tres".*?id="([^"]+)"\]', content)
        theme_id = theme_match.group(1) if theme_match else "4_theme"

        leaderboard_node = f"""[node name="LeaderboardButton" type="Button" parent="TopRightButtons"]
custom_minimum_size = Vector2(120, 55)
layout_mode = 2
theme = ExtResource("{theme_id}")
text = "Leaderboard"
"""
        out_lines.insert(insert_idx, leaderboard_node)
        
    content = '\n'.join(out_lines)

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)
        
    print(f"Restored LeaderboardButton in {filepath}")

for s in scenes:
    restore_leaderboard(s)
