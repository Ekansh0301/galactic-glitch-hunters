import os

scenes_to_clean = [
    "Game/Scenes/IntroVideo.tscn",
    "Game/Scenes/LanguageSelect.tscn",
    "Game/Scenes/login.tscn",
    "Game/Scenes/signup.tscn",
    "Game/Scenes/Character_Creation.tscn"
]

def remove_leaderboard_node(filepath):
    if not os.path.exists(filepath): return
    with open(filepath, "r", encoding="utf-8") as f:
        content = f.read()

    lines = content.split('\n')
    out_lines = []
    skip = False
    
    for line in lines:
        if line.startswith('[node name="LeaderboardButton" type="Button"'):
            skip = True
            continue
        if skip and (line.startswith('[node ') or line.startswith('[connection ')):
            skip = False
        
        if not skip:
            out_lines.append(line)
            
    new_content = '\n'.join(out_lines).strip() + "\n"

    with open(filepath, "w", encoding="utf-8") as f:
        f.write(new_content)
        
    print(f"Removed LeaderboardButton from {filepath}")

for s in scenes_to_clean:
    remove_leaderboard_node(s)
