class_name OfferScreen
extends UiScreen
## game/ui/choose_card_screen.py + game/app.py::open_offer — a oferta "escolha 1 de 3" (carta rara do chefe ou pergaminho).

var then: Callable
var cards: Array = []
var rects: Array = []
var is_scroll: bool = false
var swapping: bool = false
var title: String = ""
var decline_rect := Rect2(Gfx.W / 2.0 - 130, Gfx.H - 110, 260, 50)

func _init(then_: Callable) -> void:
	then = then_

func enter() -> void:
	_setup()

func _setup() -> void:
	var st := app.save_state
	var offer: Variant = st.pending_offer
	is_scroll = offer.get("source") == Scrolls.SCROLL_SOURCE
	swapping = is_scroll and offer.has("chosen")
	rects = []
	if swapping:
		var owner: String = offer.get("for", "")
		var owner_name: String = CharacterDefs.all()[owner].name if CharacterDefs.all().has(owner) else "o personagem"
		title = "Estoque cheio de %s: qual pergaminho sai?" % owner_name
		cards = Scrolls.stock_cards(st, owner)
	elif is_scroll:
		title = "Escolha 1 pergaminho"
		cards = Scrolls.offered_cards(st)
	else:
		title = "Escolha 1 carta rara do chefe"
		cards = Collection.offered_cards(st)
	var w := 250
	var gap := 40
	var total := cards.size() * w + (cards.size() - 1) * gap
	for i in range(cards.size()):
		rects.append(Rect2((Gfx.W - total) / 2.0 + i * (w + gap), 170, w, 360))

func _pick(index: int) -> void:
	var st := app.save_state
	var card: Card = cards[index]
	if swapping:
		var s: Variant = Scrolls.by_card_name(card.name)
		if s != null:
			Scrolls.swap_pending(st, s.id)
	elif is_scroll:
		var r := Scrolls.pick(st, card.name)
		if r == "full":
			app.save_store.save(st)
			app.set_screen(OfferScreen.new(then))
			return
	else:
		Collection.pick_offer(st, card.name)
	app.save_store.save(st)
	app.open_offer(then)

func handle_input(event: InputEvent) -> void:
	if not is_click(event):
		return
	for i in range(rects.size()):
		if rects[i].has_point(event.position):
			_pick(i)
			return
	if swapping and decline_rect.has_point(event.position):
		Scrolls.decline_pending(app.save_state)
		app.save_store.save(app.save_state)
		app.open_offer(then)

func draw(ci: CanvasItem) -> void:
	Gfx.screen_background(ci, "recompensa")
	Gfx.scrim(ci, Rect2(0, 0, Gfx.W, Gfx.H), 170)
	Gfx.text(ci, title, Vector2(Gfx.W / 2.0, 80), 38, UiTheme.TEXT_COLOR, "center")
	var m := mouse()
	for i in range(cards.size()):
		CardView.draw_card(ci, cards[i], rects[i], rects[i].has_point(m), true)
	if swapping:
		Gfx.button(ci, decline_rect, "Recusar o novo", decline_rect.has_point(m))
