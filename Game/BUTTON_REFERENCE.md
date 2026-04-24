# Quick Reference: Button Themes

## Available Button Themes

### 1. Primary Button Theme
**File:** `res://Assets/themes/primary_button_theme.tres`
**Use for:** Main actions, important decisions

```gdscript
# Example usage in GDScript
[ext_resource type="Theme" path="res://Assets/themes/primary_button_theme.tres" id="theme_primary"]

[node name="LoginButton" type="Button"]
custom_minimum_size = Vector2(200, 55)
theme = ExtResource("theme_primary")
text = "Start Game"
```

**Visual Properties:**
- Background: Bright Blue (0.2, 0.5, 0.9)
- Border: Light Blue
- Corner Radius: 10px
- Padding: 25px x 15px
- Shadow: 6px with 0.4 opacity

**Best Used For:**
- Login/Signup buttons
- Confirm/Accept actions
- Start Mission/Continue
- Submit forms

---

### 2. Standard Button Theme
**File:** `res://Assets/themes/button_theme.tres`
**Use for:** Regular interactive elements

```gdscript
[ext_resource type="Theme" path="res://Assets/themes/button_theme.tres" id="theme_button"]

[node name="SelectButton" type="Button"]
custom_minimum_size = Vector2(140, 55)
theme = ExtResource("theme_button")
text = "He/Him"
```

**Visual Properties:**
- Background: Medium Blue (0.15, 0.2, 0.4)
- Border: Blue-Grey
- Corner Radius: 8px
- Padding: 20px x 12px
- Shadow: 4px with 0.3 opacity

**Best Used For:**
- Selection buttons (pronouns, options)
- Menu items
- Standard interactions
- Toggle buttons

---

### 3. Secondary Button Theme
**File:** `res://Assets/themes/secondary_button_theme.tres`
**Use for:** Less prominent actions

```gdscript
[ext_resource type="Theme" path="res://Assets/themes/secondary_button_theme.tres" id="theme_secondary"]

[node name="BackButton" type="Button"]
custom_minimum_size = Vector2(150, 45)
theme = ExtResource("theme_secondary")
text = "Back"
```

**Visual Properties:**
- Background: Dark Grey (0.15, 0.15, 0.15)
- Border: Light Grey
- Corner Radius: 8px
- Padding: 20px x 12px
- Shadow: 4px with 0.3 opacity

**Best Used For:**
- Back/Cancel buttons
- Settings/Options
- Secondary navigation
- Less important actions

---

## Button State Colors

### Primary Button
| State | Background Color | Border Color |
|-------|-----------------|--------------|
| Normal | RGB(0.2, 0.5, 0.9) | RGB(0.3, 0.7, 1.0) |
| Hover | RGB(0.3, 0.6, 1.0) | RGB(0.5, 0.85, 1.0) |
| Pressed | RGB(0.15, 0.4, 0.75) | RGB(0.2, 0.6, 0.9) |
| Disabled | RGB(0.3, 0.3, 0.3) | RGB(0.5, 0.5, 0.5) |

### Standard Button
| State | Background Color | Border Color |
|-------|-----------------|--------------|
| Normal | RGB(0.15, 0.2, 0.4) | RGB(0.4, 0.6, 0.9) |
| Hover | RGB(0.25, 0.35, 0.6) | RGB(0.5, 0.75, 1.0) |
| Pressed | RGB(0.1, 0.15, 0.3) | RGB(0.3, 0.5, 0.8) |
| Disabled | RGB(0.2, 0.2, 0.2) | RGB(0.4, 0.4, 0.4) |

### Secondary Button
| State | Background Color | Border Color |
|-------|-----------------|--------------|
| Normal | RGB(0.15, 0.15, 0.15) | RGB(0.5, 0.5, 0.6) |
| Hover | RGB(0.25, 0.25, 0.3) | RGB(0.65, 0.65, 0.75) |
| Pressed | RGB(0.1, 0.1, 0.15) | RGB(0.4, 0.4, 0.5) |
| Disabled | RGB(0.2, 0.2, 0.2) | RGB(0.4, 0.4, 0.4) |

---

## Recommended Button Sizes

### By Context

**Login/Signup Forms:**
```gdscript
# Main action button
custom_minimum_size = Vector2(0, 55)

# Secondary actions
custom_minimum_size = Vector2(200, 45)

# Input fields
custom_minimum_size = Vector2(0, 50)
```

**Hub/Menu Screens:**
```gdscript
# Start Mission (primary action)
custom_minimum_size = Vector2(0, 60)

# Side panel buttons
custom_minimum_size = Vector2(0, 45)

# Top bar elements
custom_minimum_size = Vector2(0, 40)
```

**In-Game HUD:**
```gdscript
# Action buttons
custom_minimum_size = Vector2(120, 50)

# Small utility buttons
custom_minimum_size = Vector2(80, 35)
```

**Character Creation:**
```gdscript
# Selection buttons (side by side)
custom_minimum_size = Vector2(140, 55)

# Confirm button
custom_minimum_size = Vector2(250, 60)
```

---

## Layout Best Practices

### Centered Button Layout
```gdscript
[node name="CenterContainer" type="CenterContainer"]
layout_mode = 1
anchors_preset = 15  # Full Rect
anchor_right = 1.0
anchor_bottom = 1.0

[node name="VBoxContainer" type="VBoxContainer"]
custom_minimum_size = Vector2(450, 0)
layout_mode = 2
theme_override_constants/separation = 15
alignment = 1  # Center
```

### Button Row Layout
```gdscript
[node name="ButtonRow" type="HBoxContainer"]
layout_mode = 2
theme_override_constants/separation = 15
alignment = 1  # Center

[node name="Button1" type="Button"]
custom_minimum_size = Vector2(200, 45)
layout_mode = 2

[node name="Button2" type="Button"]
custom_minimum_size = Vector2(200, 45)
layout_mode = 2
```

### Side Panel Layout
```gdscript
[node name="SidePanel" type="VBoxContainer"]
layout_mode = 1
anchors_preset = 6  # Right Wide
anchor_left = 1.0
anchor_top = 0.5
anchor_right = 1.0
anchor_bottom = 0.5
offset_left = -180.0
offset_top = -100.0
offset_right = -20.0
offset_bottom = 100.0
theme_override_constants/separation = 15
```

---

## Common Spacing Values

**Container Separations:**
- Small spacing: `10-15px`
- Medium spacing: `20-25px`
- Large spacing: `30-40px`

**Margins/Padding:**
- Tight: `10px`
- Standard: `20px`
- Comfortable: `30px`

**Button Minimum Sizes:**
- Small: `80 x 35`
- Medium: `140 x 45`
- Large: `200 x 55`
- Extra Large: `250 x 60`

---

## Input Field Styling

### Standard Input Style
```gdscript
[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_input"]
bg_color = Color(0.1, 0.1, 0.15, 0.85)
border_width_left = 2
border_width_top = 2
border_width_right = 2
border_width_bottom = 2
border_color = Color(0.3, 0.5, 0.8, 0.8)
corner_radius_top_left = 6
corner_radius_top_right = 6
corner_radius_bottom_right = 6
corner_radius_bottom_left = 6

[node name="UsernameInput" type="LineEdit"]
custom_minimum_size = Vector2(0, 50)
layout_mode = 2
theme_override_font_sizes/font_size = 18
theme_override_styles/normal = SubResource("StyleBoxFlat_input")
placeholder_text = "Username"
alignment = 1  # Center
```

---

## Label Styling

### Title Label
```gdscript
[sub_resource type="LabelSettings" id="LabelSettings_title"]
font_size = 42
font_color = Color(0.9, 0.95, 1, 1)
outline_size = 4
outline_color = Color(0, 0, 0, 0.6)

[node name="TitleLabel" type="Label"]
text = "Galactic Glitch Hunters"
label_settings = SubResource("LabelSettings_title")
horizontal_alignment = 1  # Center
```

### Subtitle/Header Label
```gdscript
[sub_resource type="LabelSettings" id="LabelSettings_header"]
font_size = 28
font_color = Color(0.95, 0.95, 1, 1)
outline_size = 3
outline_color = Color(0, 0, 0, 0.7)
```

### Error Label
```gdscript
[sub_resource type="LabelSettings" id="LabelSettings_error"]
font_size = 16
font_color = Color(1, 0.3, 0.3, 1)
outline_size = 2
outline_color = Color(0, 0, 0, 0.8)
```

### Score Label
```gdscript
[sub_resource type="LabelSettings" id="LabelSettings_score"]
font_size = 32
font_color = Color(0.3, 0.8, 1, 1)
outline_size = 3
outline_color = Color(0, 0, 0, 0.8)
```

---

## Integration with Existing Code

### Connecting Buttons in GDScript
```gdscript
# In your scene script
func _ready():
	# Get button references
	var login_btn = $CenterContainer/MainPanel/LoginButton
	var back_btn = $CenterContainer/MainPanel/BackButton
	
	# Connect signals
	login_btn.pressed.connect(_on_login_pressed)
	back_btn.pressed.connect(_on_back_pressed)

func _on_login_pressed():
	# Handle login
	pass

func _on_back_pressed():
	# Handle back navigation
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
```

### Dynamic Button Creation
```gdscript
func create_styled_button(text: String, is_primary: bool = false) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(200, 55)
	
	if is_primary:
		button.theme = load("res://Assets/themes/primary_button_theme.tres")
	else:
		button.theme = load("res://Assets/themes/secondary_button_theme.tres")
	
	return button
```

---

## Tips for Consistency

1. **Always use themes** - Don't style buttons individually
2. **Set minimum sizes** - Ensures consistent button dimensions
3. **Use proper containers** - VBoxContainer/HBoxContainer for layout
4. **Maintain spacing** - Use theme_override_constants/separation
5. **Center important content** - Use CenterContainer for main UI
6. **Add spacers** - Use empty Control nodes for spacing
7. **Label everything** - Use clear, descriptive label_settings
8. **Test on different resolutions** - Ensure layouts scale properly

---

## Troubleshooting

**Button not showing theme:**
- Check that theme resource path is correct
- Ensure theme is loaded with ext_resource
- Verify theme is assigned to button node

**Button text not visible:**
- Check font_color in theme
- Ensure outline_size isn't too large
- Verify button size is large enough for text

**Layout not centered:**
- Use CenterContainer for centering
- Check anchors_preset is set correctly
- Verify grow_horizontal and grow_vertical settings

**Buttons too small/large:**
- Set custom_minimum_size explicitly
- Check container constraints
- Adjust padding in theme if needed

---

**Last Updated:** Phase 1 Completion - March 8, 2026
