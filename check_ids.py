import sys, re, glob
for filepath in glob.glob('Game/Scenes/*.tscn'):
    with open(filepath, 'r', encoding='utf-8') as f:
        c = f.read()
    m = re.search(r'\[ext_resource.*res://Scripts/LeaderboardButtonAction\.gd.*id="([^"]+)"\]', c)
    if m: print(filepath, 'has it as', m.group(1))
