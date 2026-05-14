extends Control

@onready var background = $Background
@onready var nova_body = $NovaBody
@onready var nova_mouth = $NovaBody/NovaMouth
@onready var dialog_text = $DialogPanel/DialogText
@onready var mouth_timer = $MouthTimer

# Load mouth textures
var mouth_open = preload("res://Assets/Nova_Space_Girl_Sprite/mouth&extras/open_mouth.png")
var mouth_closed = preload("res://Assets/Nova_Space_Girl_Sprite/mouth&extras/closed_mouth.png")

# Perfect run mouth textures
var mouth_happy = preload("res://Assets/Nova_Space_Girl_Sprite/mouth&extras/happy_smile.png")
var mouth_teeth = preload("res://Assets/Nova_Space_Girl_Sprite/mouth&extras/teeth_smile.png")

var is_mouth_open = false
var text_to_show = ""
var text_index = 0
var typing_speed = 0.05
var time_passed = 0.0

# Track if player got all answers correct
var perfect_run = false

func _ready():
    # Retrieve run stats
    var correct_answers = GameState.correct_answers_this_run

    # Check for perfect run
    perfect_run = (correct_answers == 3)

    # Dialogue based on score
    if perfect_run:
        text_to_show = "Perfect run! You have an incredible grasp of equality and fairness. You consistently recognized that true potential is not defined by gender, appearance, or outdated stereotypes. Always remember that everyone deserves a fair chance based on their own merits rather than assumptions.Keep that logic shining and continue to be a champion for equality out there in the galaxy!"
    elif correct_answers >= 1:
        text_to_show = "Good job! We squashed some glitches, but there's always more to learn about bias.You spotted some unfair assumptions, but some stereotypes are deeply ingrained and harder to detect. Remember to question assumptions about what roles or hobbies people “should” have based on how they look.Keep trying, and stay vigilant against those unseen biases!"
    else:
        text_to_show = "That was a rough one. Bias and stereotypes can be tricky to navigate, especially when they disguise themselves as 'common sense'. We ran into the glitches' traps by relying on generalizations instead of seeing individuals for who they truly are. Don't be discouraged! Fairness means looking past the surface and challenging our own assumptions.We'll definitely do better next time!"

    dialog_text.text = ""

    # Set initial mouth texture
    if perfect_run:
        nova_mouth.texture = mouth_happy
    else:
        nova_mouth.texture = mouth_closed

    # Start mouth animation
    mouth_timer.timeout.connect(_on_mouth_timer_timeout)
    mouth_timer.start()


func _process(delta):
    # Typewriter effect
    if text_index < text_to_show.length():
        time_passed += delta

        if time_passed >= typing_speed:
            time_passed = 0.0
            dialog_text.text += text_to_show[text_index]
            text_index += 1

    else:
        # Finished speaking
        mouth_timer.stop()

        # Final mouth state
        if perfect_run:
            nova_mouth.texture = mouth_happy
        else:
            nova_mouth.texture = mouth_closed


func _on_mouth_timer_timeout():

    # PERFECT RUN:
    # switch between happy_smile and teeth_smile
    if perfect_run:

        if is_mouth_open:
            nova_mouth.texture = mouth_happy
        else:
            nova_mouth.texture = mouth_teeth

    # NORMAL / BAD RUN:
    # switch between open_mouth and closed_mouth
    else:

        if is_mouth_open:
            nova_mouth.texture = mouth_closed
        else:
            nova_mouth.texture = mouth_open

    is_mouth_open = !is_mouth_open


func _input(event):
    # Press enter / space to skip or continue
    if event is InputEventKey and event.pressed and (
        event.keycode == KEY_SPACE or event.keycode == KEY_ENTER
    ):

        if text_index < text_to_show.length():

            # Skip typing
            dialog_text.text = text_to_show
            text_index = text_to_show.length()

            mouth_timer.stop()

            # Final mouth state
            if perfect_run:
                nova_mouth.texture = mouth_happy
            else:
                nova_mouth.texture = mouth_closed

        else:
            # Advance to next scene (Credits)
            get_tree().change_scene_to_file("res://Scenes/CreditsVideo.tscn")