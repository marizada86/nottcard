"""Gera esqueletos GDScript (só os campos) dos dataclasses do core Python → <saída>/<snake>.gd.
Os métodos são portados à mão depois. Uso: python tools/gen_dataclasses.py <saída> [Nome ...]"""
import dataclasses, importlib, inspect, pkgutil, re, sys, typing
from pathlib import Path

SRC = str(Path(__file__).resolve().parent.parent / ".baseline" / "v0.18.0")
sys.path.insert(0, SRC)
core = importlib.import_module("game.core")


def snake(n):
    return re.sub(r"(?<!^)(?=[A-Z])", "_", n).lower()


def lit(f, hints):
    if f.default is not dataclasses.MISSING:
        d = f.default
    elif f.default_factory is not dataclasses.MISSING:
        d = f.default_factory()
    else:
        d = dataclasses.MISSING
    t = str(hints.get(f.name, ""))
    if d is dataclasses.MISSING:
        if t.startswith("<class 'str'>") or t == "str": return '""', "String"
        if "int" == t or t == "<class 'int'>": return "0", "int"
        if "float" in t and "None" not in t: return "0.0", "float"
        if "bool" in t: return "false", "bool"
        if "dict" in t: return "{}", "Dictionary"
        if "tuple" in t or "list" in t: return "[]", "Array"
        return "null", "Variant"
    if d is None: return "null", "Variant"
    if isinstance(d, bool): return str(d).lower(), "bool"
    if isinstance(d, int): return str(d), "int"
    if isinstance(d, float): return repr(d), "float"
    if isinstance(d, str): return '"%s"' % d.replace('"', '\\"'), "String"
    if isinstance(d, (tuple, list)): return "[]", "Array"
    if isinstance(d, dict): return "{}", "Dictionary"
    return "null", "Variant"


def main():
    out = Path(sys.argv[1]); out.mkdir(parents=True, exist_ok=True)
    want = set(sys.argv[2:])
    for m in pkgutil.iter_modules(core.__path__):
        mod = importlib.import_module("game.core." + m.name)
        for n, v in vars(mod).items():
            if inspect.isclass(v) and dataclasses.is_dataclass(v) and v.__module__ == mod.__name__ and (not want or n in want):
                try: hints = typing.get_type_hints(v)
                except Exception: hints = {}
                lines = [f"class_name {n}", "extends RefCounted", f"## Porte de game/core/{m.name}.py::{n}. Gerado por tools/gen_dataclasses.py; métodos à mão.", ""]
                for f in dataclasses.fields(v):
                    l, t = lit(f, hints)
                    lines.append(f"var {f.name}: {t} = {l}" if t != "Variant" else f"var {f.name} = {l}")
                (out / f"{snake(n)}.gd").write_text("\n".join(lines) + "\n", encoding="utf-8")
                print(n, "->", snake(n) + ".gd")

main()
