import sys, re, glob

files = glob.glob('Game/Scenes/*.tscn')
for filepath in files:
    with open(filepath, 'r', encoding='utf-8') as f:
        c = f.read()

    # remove the stray script include
    c = re.sub(r'\[ext_resource type="Script" path="res://Scripts/LeaderboardButtonAction\.gd"[^\]]*\]\n', '', c)
    # remove the script parameter from the node if present
    c = re.sub(r'script = ExtResource\("ldbpt1"\)\n', '', c)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(c)
