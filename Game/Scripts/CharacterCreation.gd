extends Control

var current_gender = 1

func _ready():
	# Ensure scene is visible
	self.modulate.a = 1.0
	MusicManager.play_track(MusicManager.TRACK_SIGNAL_TO_NOISE)
	_apply_translations()
	_setup_animations()

func _setup_animations():
	"""Sets up entry animations and button hover effects"""
	# Fade in the title
	if has_node("CenterContainer/MainPanel/TitleLabel"):
		var title = $CenterContainer/MainPanel/TitleLabel
		title.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(title, "modulate:a", 1.0, 0.6)
	
	# Setup button hover effects
	var buttons = [
		"CenterContainer/MainPanel/GenderSelection/Male",
		"CenterContainer/MainPanel/GenderSelection/Female",
		"CenterContainer/MainPanel/GenderSelection/Other",
		"CenterContainer/MainPanel/Confirm"
	]
	for button_path in buttons:
		if has_node(button_path):
			var button: Button = get_node(button_path)
			UIAnimations.setup_tactile_button(button)

func _apply_translations():
	var LM = get_node("/root/LanguageManager")
	# Exact node names from Character_Creation.tscn
	if has_node("CenterContainer/MainPanel/TitleLabel"):
		$CenterContainer/MainPanel/TitleLabel.text = LM.t("char_title")
	if has_node("CenterContainer/MainPanel/GenderSelection/Male"):
		$CenterContainer/MainPanel/GenderSelection/Male.text = LM.t("btn_male")
	if has_node("CenterContainer/MainPanel/GenderSelection/Female"):
		$CenterContainer/MainPanel/GenderSelection/Female.text = LM.t("btn_female")
	if has_node("CenterContainer/MainPanel/GenderSelection/Other"):
		$CenterContainer/MainPanel/GenderSelection/Other.text = LM.t("btn_other")
	if has_node("CenterContainer/MainPanel/Confirm"):
		$CenterContainer/MainPanel/Confirm.text = LM.t("btn_confirm")

func _on_male_pressed(): current_gender = 1
func _on_female_pressed(): current_gender = 2
func _on_other_pressed(): current_gender = 3

func _on_confirm_pressed():
	print("=== CHARACTER CREATION CONFIRMED ===")
	print("Player name: ", GameManager.player_name)
	print("Selected gender: ", current_gender)
	GameManager.save_player_selection(GameManager.player_name, current_gender)
	print("Going to Hub...")
	# Fade out before scene change
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	await tween.finished
	get_tree().change_scene_to_file("res://Scenes/hub.tscn")
