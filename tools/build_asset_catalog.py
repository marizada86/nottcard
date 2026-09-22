from pathlib import Path
from reportlab.lib.pagesizes import landscape
from reportlab.lib.utils import ImageReader
from reportlab.pdfgen import canvas

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output" / "pdf" / "catalogo-assets-m1-m9.pdf"
ASSETS = [
    ("M2 - HQ", "assets/hq/hq_002_q1.png"), ("M2 - HQ", "assets/hq/hq_002_q2.png"), ("M2 - HQ", "assets/hq/hq_002_q3.png"),
    ("M2 - HQ", "assets/hq/hq_003_q1.png"), ("M2 - HQ", "assets/hq/hq_003_q2.png"), ("M2 - HQ", "assets/hq/hq_003_q3.png"),
    ("M3", "assets/enemies/gargula_corrompida.png"), ("M3", "assets/portraits/aila.png"), ("M3", "assets/items/ampulheta_silencio_eterno.png"), ("M3", "assets/world/props/livrinho.png"),
    ("M4", "assets/rooms/m4_ponte_perseguicao.png"), ("M4", "assets/enemies/rebelde_ponte.png"), ("M4", "assets/portraits/bella.png"), ("M4", "assets/portraits/kein.png"), ("M4", "assets/items/cadernos_magicos.png"),
    ("M5", "assets/enemies/astherion_fase_1.png"), ("M5", "assets/enemies/astherion_fase_2.png"), ("M5", "assets/enemies/notivago.png"), ("M5", "assets/items/colar_visao_verdadeira.png"),
    ("M6", "assets/enemies/willie_amalgame.png"), ("M7", "assets/portraits/korrak.png"), ("M7", "assets/portraits/leoric.png"),
    ("M8", "assets/portraits/erik.png"), ("M8", "assets/enemies/demonio_sedutor.png"),
    ("M9", "assets/enemies/kein_fase_1.png"), ("M9", "assets/enemies/beholder.png"), ("M9", "assets/enemies/death_tyrant.png"),
]

PAGE_W, PAGE_H = landscape((842, 595))
MARGIN, GAP, COLS, ROWS = 30, 18, 3, 2
CELL_W = (PAGE_W - 2 * MARGIN - (COLS - 1) * GAP) / COLS
CELL_H = (PAGE_H - 90 - MARGIN - (ROWS - 1) * GAP) / ROWS

def draw_cover(c):
    c.setFillColorRGB(0.035, 0.05, 0.09)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    c.setFillColorRGB(0.43, 0.68, 1)
    c.setFont("Helvetica-Bold", 34)
    c.drawString(52, PAGE_H - 130, "Nottcard - Catalogo de Assets")
    c.setFillColorRGB(0.82, 0.86, 0.94)
    c.setFont("Helvetica", 17)
    c.drawString(54, PAGE_H - 168, "Lotes produzidos de M2 a M9")
    c.setFont("Helvetica", 12)
    c.drawString(54, PAGE_H - 222, "Pixel art dark fantasy - revisao interna da equipe")
    c.setFillColorRGB(0.78, 0.48, 0.22)
    c.rect(54, PAGE_H - 270, 260, 4, fill=1, stroke=0)

def draw_page(c, group, entries, page_no):
    c.setFillColorRGB(0.97, 0.98, 1)
    c.rect(0, 0, PAGE_W, PAGE_H, fill=1, stroke=0)
    c.setFillColorRGB(0.06, 0.09, 0.15)
    c.setFont("Helvetica-Bold", 20)
    c.drawString(MARGIN, PAGE_H - 38, group)
    c.setFont("Helvetica", 9)
    c.drawRightString(PAGE_W - MARGIN, PAGE_H - 35, f"Pagina {page_no}")
    for i, (_, rel) in enumerate(entries):
        x = MARGIN + (i % COLS) * (CELL_W + GAP)
        y = PAGE_H - 72 - (i // COLS + 1) * CELL_H - (i // COLS) * GAP
        p = ROOT / rel
        image = ImageReader(str(p))
        iw, ih = image.getSize()
        scale = min(CELL_W / iw, (CELL_H - 30) / ih)
        dw, dh = iw * scale, ih * scale
        c.drawImage(image, x + (CELL_W - dw) / 2, y + 25 + (CELL_H - 30 - dh) / 2, dw, dh, mask='auto')
        c.setFillColorRGB(0.08, 0.12, 0.2)
        c.setFont("Helvetica", 8)
        c.drawCentredString(x + CELL_W / 2, y + 8, Path(rel).name)

def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)
    c = canvas.Canvas(str(OUT), pagesize=(PAGE_W, PAGE_H))
    draw_cover(c); c.showPage()
    groups = {}
    for item in ASSETS:
        groups.setdefault(item[0], []).append(item)
    page_no = 1
    for group, entries in groups.items():
        for start in range(0, len(entries), COLS * ROWS):
            draw_page(c, group, entries[start:start + COLS * ROWS], page_no)
            page_no += 1
            c.showPage()
    c.save()

if __name__ == "__main__":
    main()
