class_name UiTheme
extends RefCounted
## game/ui/theme.py — cores e fontes compartilhadas entre as telas.

const BACKGROUND_COLOR := Color8(18, 18, 24)
const TEXT_COLOR := Color8(230, 230, 230)
const TEXT_MUTED := Color8(150, 150, 160)
const PANEL_COLOR := Color8(30, 30, 40)
const CARD_BORDER := Color8(10, 10, 14)
const SELECTED_BORDER := Color8(255, 215, 90)
const BUTTON_COLOR := Color8(50, 60, 90)
const BUTTON_HOVER := Color8(70, 85, 120)
const HP_BAR_BG := Color8(60, 20, 20)
const HP_BAR_FG := Color8(170, 40, 40)
const AIM_LINE_COLOR := Color8(255, 215, 90)
const BONUS_COLOR := Color8(200, 160, 255)
const BONUS_OUTLINE := Color8(255, 215, 90)
const HEAL_COLOR := Color8(110, 220, 120)
const BLOCKED_COLOR := Color8(170, 170, 180)
const TEXT_OUTLINE := Color8(15, 15, 20)

const CARD_COLORS := {
	"Vermelho": Color8(150, 45, 45),
	"Amarelo": Color8(170, 150, 40),
	"Azul": Color8(45, 90, 150),
	"Roxo": Color8(100, 55, 140),
}
const CARD_TEXT_COLORS := {
	"Vermelho": Color8(255, 110, 100),
	"Amarelo": Color8(255, 225, 100),
	"Azul": Color8(110, 170, 255),
	"Roxo": Color8(190, 140, 255),
}

static var _fonts: Dictionary = {}

static func _load_font(filename: String) -> Font:
	if not _fonts.has(filename):
		var f: Font = load("res://assets/fonts/%s" % filename)
		_fonts[filename] = f if f != null else ThemeDB.fallback_font
	return _fonts[filename]

## A fonte padrão do pygame (SysFont(None, n)) — aqui a Alegreya Sans, que acompanha o jogo.
static func font() -> Font:
	if not _fonts.has("__system"):
		var f := SystemFont.new()
		f.font_names = PackedStringArray(["Arial", "Helvetica", "Liberation Sans", "sans-serif"])
		f.font_weight = 700
		f.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
		_fonts["__system"] = f
	return _fonts["__system"]

static func card_title_font() -> Font:
	return _load_font("CinzelDecorative-Bold.ttf")

static func card_text_font(bold: bool = false) -> Font:
	return _load_font("AlegreyaSans-Bold.ttf" if bold else "AlegreyaSans-Regular.ttf")

static func card_color(color_name: String) -> Color:
	return CARD_COLORS.get(color_name, Color8(100, 100, 100))

static func card_text_color(color_name: String) -> Color:
	return CARD_TEXT_COLORS.get(color_name, TEXT_COLOR)
