extends RefCounted
## Regras deterministas para a contenção compartilhada de texto da UI.

func test_content_rect_respects_padding() -> String:
	var inner: Rect2 = Gfx.content_rect(Rect2(10, 20, 100, 50), 8)
	if inner.position != Vector2(18, 28) or inner.size != Vector2(84, 34):
		return "retângulo interno incorreto: %s" % inner
	return ""

func test_fit_size_never_exceeds_requested_size() -> String:
	var body: int = Gfx.fitting_size("Rótulo muito extenso para um botão compacto", 22, 100, 12)
	if body < 12 or body > 22:
		return "corpo adaptativo fora do intervalo: %d" % body
	return ""

func test_wrap_preserves_explicit_paragraphs() -> String:
	var lines: Array = Gfx.wrap_lines("Primeira linha\nSegunda linha", 18, 500)
	if lines.size() != 2 or lines[0] != "Primeira linha" or lines[1] != "Segunda linha":
		return "quebra de parágrafo perdida: %s" % lines
	return ""
