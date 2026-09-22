"""Exporta o conteúdo declarativo do core Python (constantes, dataclasses estáticos, decks build_*) → data/core/<módulo>.json.

    python tools/export_data.py [--src PASTA_DO_NOTTCARD_AI]

Dataclasses viram {"__type": "Card", ...campos}; tuplas viram listas; conjuntos viram listas ordenadas; chaves de dict viram
string (tuplas de chave viram "a,b", sinalizado em "__tuplekeys"). O que não é dado (funções, classes) é ignorado.
"""
from __future__ import annotations

import argparse
import dataclasses
import enum
import importlib
import inspect
import json
import pkgutil
import sys
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "data" / "core"
SKIP_MODULES = {"__init__"}
skipped: list[str] = []


def enc(v, where=""):
    if v is None or isinstance(v, (bool, int, float, str)):
        return v
    if dataclasses.is_dataclass(v) and not isinstance(v, type):
        d = {"__type": type(v).__name__}
        for f in dataclasses.fields(v):
            fv = getattr(v, f.name)
            if callable(fv) and not isinstance(fv, type):
                d[f.name] = {"__fn": getattr(fv, "__name__", "lambda")}
                try:
                    if not [p for p in inspect.signature(fv).parameters.values() if p.default is p.empty]:
                        d[f.name + "__result"] = enc(fv(), f"{where}.{f.name}()")
                except Exception as e:  # noqa: BLE001
                    skipped.append(f"{where}.{f.name}(): {type(e).__name__}: {e}")
                continue
            d[f.name] = enc(fv, f"{where}.{f.name}")
        return d
    if isinstance(v, (list, tuple)):
        return [enc(x, where) for x in v]
    if isinstance(v, (set, frozenset)):
        return [enc(x, where) for x in sorted(v, key=repr)]
    if isinstance(v, dict):
        out = {}
        tuple_keys = False
        for k, x in v.items():
            if isinstance(k, tuple):
                tuple_keys = True
                k = ",".join(str(p) for p in k)
            out[str(k)] = enc(x, f"{where}[{k}]")
        if tuple_keys:
            out["__tuplekeys"] = True
        return out
    if isinstance(v, enum.Enum):
        return v.value
    raise TypeError(f"{where}: {type(v).__name__}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--src", default=str(Path(__file__).resolve().parent.parent / ".baseline" / "v0.18.0"))
    args = ap.parse_args()
    sys.path.insert(0, args.src)
    core = importlib.import_module("game.core")
    OUT.mkdir(parents=True, exist_ok=True)
    for m in pkgutil.iter_modules(core.__path__):
        if m.name in SKIP_MODULES:
            continue
        mod = importlib.import_module("game.core." + m.name)
        data = {}
        for name, val in vars(mod).items():
            if name.startswith("_") or inspect.ismodule(val) or inspect.isclass(val):
                continue
            if inspect.isfunction(val):
                if val.__module__ == mod.__name__ and name.startswith("build_"):
                    try:
                        if not [p for p in inspect.signature(val).parameters.values() if p.default is p.empty]:
                            data["@" + name] = enc(val(), f"{m.name}.{name}()")
                    except Exception as e:  # noqa: BLE001
                        skipped.append(f"{m.name}.{name}(): {type(e).__name__}: {e}")
                continue
            if inspect.isbuiltin(val) or not (name.isupper() or name[0].isupper()) or getattr(val, "__module__", "") in ("typing", "collections.abc", "types"):
                continue
            try:
                data[name] = enc(val, f"{m.name}.{name}")
            except TypeError as e:
                skipped.append(f"{m.name}.{name}: {e}")
        if data:
            (OUT / f"{m.name}.json").write_text(json.dumps(data, ensure_ascii=False, indent=1), encoding="utf-8")
            print(f"{m.name}: {len(data)} entradas")
    if skipped:
        print("IGNORADOS:")
        print("\n".join("  " + s for s in skipped))


if __name__ == "__main__":
    main()
