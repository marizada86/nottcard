"""Vetores de paridade: validação de nome e FPS do perfil."""


@section("profile")
def profile_section():
    from game.core import profile as pf
    names = ["", "a", "ab", "  Ana   Maria ", "x" * 24, "x" * 25, "João_Silva-2.0", "ba$d!", "Ünï côdé", "a\tb"]
    return {"names": [[n, list(pf.validate_name(n))] for n in names],
            "fps": [[repr(v), pf.clean_fps(v)] for v in (30, 60, 45, True, None, "60")] if False else [[30, pf.clean_fps(30)], [60, pf.clean_fps(60)], [45, pf.clean_fps(45)], [None, pf.clean_fps(None)]]}
