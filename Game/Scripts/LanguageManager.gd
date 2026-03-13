extends Node

# ============================================================
# LANGUAGE MANAGER — Singleton
# Supports: English (en), Hindi (hi), Telugu (te)
# Usage:  LanguageManager.t("key")
# ============================================================

var current_language: String = "en"  # default

signal language_changed(lang_code)

# ============================================================
# TRANSLATION TABLE
# ============================================================
const TRANSLATIONS = {

	# ---------- LANGUAGE SELECT SCREEN ----------
	"choose_language":     { "en": "Choose Your Language",    "hi": "अपनी भाषा चुनें",         "te": "మీ భాషను ఎంచుకోండి" },
	"btn_english":         { "en": "English",                 "hi": "अंग्रेज़ी",                "te": "ఇంగ్లీష్" },
	"btn_hindi":           { "en": "Hindi",                   "hi": "हिन्दी",                   "te": "హిందీ" },
	"btn_telugu":          { "en": "Telugu",                  "hi": "तेलुगु",                   "te": "తెలుగు" },

	# ---------- LOGIN SCREEN ----------
	"login_title":         { "en": "Galactic Glitch Hunters", "hi": "गैलेक्टिक ग्लिच हंटर्स", "te": "గెలాక్టిక్ గ్లిచ్ హంటర్స్" },
	"placeholder_name":    { "en": "Enter Username...",       "hi": "उपयोगकर्ता नाम दर्ज करें...", "te": "వినియోగదారు పేరు నమోదు చేయండి..." },
	"placeholder_pass":    { "en": "Enter Password...",       "hi": "पासवर्ड दर्ज करें...",    "te": "పాస్‌వర్డ్ నమోదు చేయండి..." },
	"placeholder_password":{ "en": "Enter Password...",       "hi": "पासवर्ड दर्ज करें...",    "te": "పాస్‌వర్డ్ నమోదు చేయండి..." },
	"btn_login":           { "en": "Login",                   "hi": "लॉगिन",                    "te": "లాగిన్" },
	"btn_guest":           { "en": "Guest",                   "hi": "अतिथि",                    "te": "అతిథి" },
	"btn_change_language": { "en": "Change Language",         "hi": "भाषा बदलें",               "te": "భాష మార్చండి" },
	"signup_link":         { "en": "Don't have an account?\nSignup", "hi": "खाता नहीं है?\nसाइन अप करें", "te": "ఖాతా లేదా?\nసైన్ అప్ చేయండి" },
	"link_signup":         { "en": "Don't have an account?\nSignup", "hi": "खाता नहीं है?\nसाइन अप करें", "te": "ఖాతా లేదా?\nసైన్ అప్ చేయండి" },
	"err_fill_fields":     { "en": "Please fill all fields!", "hi": "कृपया सभी फ़ील्ड भरें!",  "te": "దయచేసి అన్ని ఫీల్డ్‌లు నింపండి!" },
	"err_invalid_creds":   { "en": "Invalid credentials.",    "hi": "गलत जानकारी।",             "te": "తప్పు వివరాలు." },
	"err_enter_name":      { "en": "Enter a name first!",     "hi": "पहले नाम दर्ज करें!",      "te": "ముందు పేరు నమోదు చేయండి!" },

	# ---------- SIGNUP SCREEN ----------
	"signup_title":        { "en": "Create Account",          "hi": "खाता बनाएं",               "te": "ఖాతా సృష్టించండి" },
	"placeholder_signup_name": { "en": "Enter Name...",       "hi": "नाम दर्ज करें...",         "te": "పేరు నమోదు చేయండి..." },
	"placeholder_age":     { "en": "Enter Age (8–12)...",     "hi": "आयु दर्ज करें (8–12)...",  "te": "వయసు నమోదు చేయండి (8–12)..." },
	"btn_signup":          { "en": "Sign Up",                  "hi": "साइन अप",                  "te": "సైన్ అప్" },
	"btn_back_login":      { "en": "Back to Login",            "hi": "लॉगिन पर वापस जाएं",       "te": "లాగిన్‌కు తిరిగి వెళ్ళండి" },
	"err_enter_name2":     { "en": "Please enter your name!",  "hi": "कृपया अपना नाम दर्ज करें!", "te": "దయచేసి మీ పేరు నమోదు చేయండి!" },
	"err_enter_pass":      { "en": "Please enter a password!", "hi": "कृपया पासवर्ड दर्ज करें!", "te": "దయచేసి పాస్‌వర్డ్ నమోదు చేయండి!" },
	"err_enter_age":       { "en": "Please enter your age!",   "hi": "कृपया अपनी आयु दर्ज करें!", "te": "దయచేసి మీ వయసు నమోదు చేయండి!" },
	"err_age_range":       { "en": "Age must be between 8 and 12!", "hi": "आयु 8 से 12 के बीच होनी चाहिए!", "te": "వయసు 8 మరియు 12 మధ్య ఉండాలి!" },
	"err_pass_short":      { "en": "Password must be at least 4 characters!", "hi": "पासवर्ड कम से कम 4 अक्षर का होना चाहिए!", "te": "పాస్‌వర్డ్ కనీసం 4 అక్షరాలు ఉండాలి!" },
	"err_user_exists":     { "en": "Username already exists! Try another.", "hi": "उपयोगकर्ता नाम पहले से मौजूद है! दूसरा प्रयास करें।", "te": "వినియోగదారు పేరు ఇప్పటికే ఉంది! మరొకటి ప్రయత్నించండి." },
	"success_account":     { "en": "Account created! Redirecting...", "hi": "खाता बन गया! पुनर्निर्देशित हो रहे हैं...", "te": "ఖాతా సృష్టించబడింది! దారి మళ్ళిస్తోంది..." },

	# ---------- CHARACTER CREATION ----------
	"char_title":          { "en": "Choose Your Pronouns",   "hi": "अपने सर्वनाम चुनें",       "te": "మీ సర్వనామాలు ఎంచుకోండి" },
	"btn_male":            { "en": "He/Him",                  "hi": "वह/उसे (पुरुष)",           "te": "అతను/అతన్ని" },
	"btn_female":          { "en": "She/Her",                 "hi": "वह/उसे (महिला)",           "te": "ఆమె/ఆమెను" },
	"btn_other":           { "en": "They/Them",               "hi": "वे/उन्हें",                "te": "వారు/వారిని" },
	"btn_confirm":         { "en": "Confirm",                 "hi": "पुष्टि करें",               "te": "నిర్ధారించండి" },

	# ---------- HUB ----------
	"hub_cadet":           { "en": "Cadet: ",                 "hi": "कैडेट: ",                  "te": "కేడెట్: " },
	"hub_rank":            { "en": "Rank: ",                  "hi": "रैंक: ",                   "te": "ర్యాంక్: " },
	"hub_score":           { "en": "Total Data Shards: ",     "hi": "कुल डेटा टुकड़े: ",        "te": "మొత్తం డేటా షార్డ్‌లు: " },
	"hub_missions":        { "en": "Missions Completed: ",    "hi": "पूर्ण मिशन: ",             "te": "పూర్తి చేసిన మిషన్లు: " },
	"btn_start_mission":   { "en": "Start Mission",           "hi": "मिशन शुरू करें",           "te": "మిషన్ ప్రారంభించండి" },
	"hub_mission_progress":{ "en": "Mission Progress: ",      "hi": "मिशन प्रगति: ",            "te": "మిషన్ పురోగతి: " },
	"btn_settings":        { "en": "Settings",                "hi": "सेटिंग्स",                 "te": "సెట్టింగ్స్" },
	"btn_leaderboard":     { "en": "Leaderboard",             "hi": "लीडरबोर्ड",               "te": "లీడర్బోర్డ్" },

	# ---------- SETTINGS / LEADERBOARD ----------
	"settings_title":            { "en": "Settings",                           "hi": "सेटिंग्स",                         "te": "సెట్టింగ్స్" },
	"settings_language":         { "en": "Language",                           "hi": "भाषा",                             "te": "భాష" },
	"settings_master_volume":    { "en": "Master Volume",                      "hi": "मास्टर वॉल्यूम",                    "te": "మాస్టర్ వాల్యూం" },
	"settings_music_credits":    { "en": "Music Credits",                      "hi": "संगीत श्रेय",                        "te": "సంగీత క్రెడిట్స్" },
	"settings_fullscreen":       { "en": "Fullscreen",                         "hi": "फुलस्क्रीन",                        "te": "ఫుల్ స్క్రీన్" },
	"settings_reset_progress":   { "en": "Reset Progress",                     "hi": "प्रगति रीसेट करें",                 "te": "ప్రగతిని రీసెట్ చేయండి" },
	"settings_logout":           { "en": "Log Out",                            "hi": "लॉग आउट",                          "te": "లాగ్ అవుట్" },
	"settings_saved":            { "en": "Settings saved.",                    "hi": "सेटिंग्स सेव हो गईं।",             "te": "సెట్టింగ్స్ సేవ్ అయ్యాయి." },
	"settings_reset_done":       { "en": "Progress reset for this account.",   "hi": "इस खाते की प्रगति रीसेट हो गई।",   "te": "ఈ ఖాతా ప్రగతి రీసెట్ అయ్యింది." },
	"settings_reset_guest":      { "en": "Guest progress cannot be reset.",    "hi": "गेस्ट प्रगति रीसेट नहीं हो सकती।", "te": "గెస్ట్ ప్రగతిని రీసెట్ చేయలేరు." },
	"leaderboard_title":         { "en": "Leaderboard",                        "hi": "लीडरबोर्ड",                         "te": "లీడర్బోర్డ్" },
	"leaderboard_header":        { "en": "Top Pilots",                         "hi": "शीर्ष पायलट",                       "te": "టాప్ పైలట్లు" },
	"leaderboard_empty":         { "en": "No scores yet. Complete missions to rank!", "hi": "अभी कोई स्कोर नहीं। रैंक के लिए मिशन पूरा करें!", "te": "ఇంకా స్కోర్లు లేవు. ర్యాంక్ కోసం మిషన్లు పూర్తి చేయండి!" },
	"leaderboard_signin_prompt": { "en": "Guest scores are not tracked. Please sign in to join the leaderboard.", "hi": "गेस्ट स्कोर ट्रैक नहीं होते। लीडरबोर्ड में आने के लिए साइन इन करें।", "te": "గెస్ట్ స్కోర్లు ట్రాక్ కావు. లీడర్బోర్డ్‌లో చేరేందుకు సైన్ ఇన్ చేయండి." },
	"btn_save":                  { "en": "Save",                               "hi": "सेव",                               "te": "సేవ్" },
	"btn_close":                 { "en": "Close",                              "hi": "बंद करें",                           "te": "మూసివేయి" },
	"info":                      { "en": "Info",                               "hi": "जानकारी",                           "te": "సమాచారం" },

	# ---------- LOADING SCREEN ----------
	"loading":             { "en": "Loading...",              "hi": "लोड हो रहा है...",         "te": "లోడ్ అవుతోంది..." },
	"loading_title":       { "en": "ENTERING HYPERSPACE...", "hi": "हाइपरस्पेस में प्रवेश...", "te": "హైపర్‌స్పేస్‌లోకి ప్రవేశిస్తోంది..." },
	"loading_tip_1":       { "en": "Bias is when we let feelings cloud our judgment.", "hi": "पूर्वाग्रह तब होता है जब भावनाएं हमारे निर्णय को धुंधला कर देती हैं।", "te": "బయాస్ అంటే మన అనుభవాలు మన నిర్ణయాన్ని కప్పివేయడం." },
	"loading_tip_2":       { "en": "Always check your sources before believing a rumor.", "hi": "किसी अफवाह पर विश्वास करने से पहले हमेशा अपने स्रोत जांचें।", "te": "ఒక పుకారు నమ్మే ముందు ఎల్లప్పుడూ మీ వనరులను తనిఖీ చేయండి." },
	"loading_tip_3":       { "en": "Every correct answer weakens The Bias!", "hi": "हर सही जवाब पूर्वाग्रह को कमज़ोर करता है!", "te": "ప్రతి సరైన సమాధానం బయాస్‌ను బలహీనపరుస్తుంది!" },
	"loading_tip_4":       { "en": "Did you know? Everyone deserves to be treated fairly.", "hi": "क्या आप जानते हैं? हर किसी के साथ निष्पक्ष व्यवहार होना चाहिए।", "te": "మీకు తెలుసా? ప్రతి ఒక్కరూ న్యాయంగా చూడబడే హక్కు ఉంది." },
	"loading_tip_5":       { "en": "Robots follow logic, but humans can choose kindness.", "hi": "रोबोट तर्क का पालन करते हैं, लेकिन इंसान दयालुता चुन सकते हैं।", "te": "రోబోట్లు తర్కాన్ని అనుసరిస్తాయి, కానీ మానవులు దయను ఎంచుకోవచ్చు." },
	"loading_tip_6":       { "en": "Stereotypes are not always true — judge people by their actions!", "hi": "रूढ़िवादिता हमेशा सच नहीं होती — लोगों को उनके कार्यों से आंकें!", "te": "స్టీరియోటైప్‌లు ఎల్లప్పుడూ నిజం కాదు — చర్యలతో వ్యక్తులను అంచనా వేయండి!" },

	# ---------- PLANET VIEW ----------
	"arriving_at":         { "en": "ARRIVING AT",             "hi": "पर आ रहे हैं:",             "te": "వద్దకు చేరుతున్నాం:" },

	# ---------- LEVEL 2 CINEMATIC ----------
	"level2_bubble_nova":  { "en": "Hostile signal detected!",  "hi": "शत्रु संकेत मिला!",          "te": "శత్రు సంకేతం గుర్తించబడింది!" },
	"level2_bubble_robot": { "en": "UNIDENTIFIED LIFE FORM.\nELIMINATE.", "hi": "अज्ञात जीव।\nनष्ट करो।", "te": "అజ్ఞాత జీవి.\nనాశనం చేయండి." },

	# ---------- BATTLE / DIALOGUE ----------
	"bias_label":          { "en": "Bias Meter",              "hi": "पूर्वाग्रह मीटर",          "te": "బయాస్ మీటర్" },
	"score_label":         { "en": "Score: ",                 "hi": "अंक: ",                    "te": "స్కోర్: " },

	# ---------- MAIN MENU ----------
	"btn_play":            { "en": "Play",                    "hi": "खेलें",                    "te": "ఆడండి" },
	"btn_quit":            { "en": "Quit",                    "hi": "छोड़ें",                   "te": "నిష్క్రమించండి" },
}

# ============================================================
func _ready():
	print("=== LANGUAGE MANAGER READY === (default: English)")

# Set language from code
func set_language(lang_code: String):
	if lang_code in ["en", "hi", "te"]:
		current_language = lang_code
		print("LanguageManager: Language set to '", lang_code, "'")
		language_changed.emit(lang_code)
	else:
		push_error("LanguageManager: Unknown language code '" + lang_code + "'")

# Translate a key — falls back to English if missing
func t(key: String) -> String:
	if TRANSLATIONS.has(key):
		var entry = TRANSLATIONS[key]
		if entry.has(current_language):
			return entry[current_language]
		elif entry.has("en"):
			return entry["en"]
	push_error("LanguageManager: Missing translation key '" + key + "'")
	return key

# Shortcut: get current language code
func get_language() -> String:
	return current_language
