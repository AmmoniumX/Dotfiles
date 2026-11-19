# Shader bundle

A ready-to-use collection of shaders for biri's [post-process shader
system](../../docs/wiki/Configuration:-Global-Shader.md), collected from a live setup.
Everything here is self-contained — the `.kdl` files inline their GLSL, and the `.frag`
files are plain fragment shader sources referenced by `path` from window rules.

## Layout

| Directory | Kind | Wired via |
|---|---|---|
| `cursor/` | Full `global-shader {}` blocks: effects that follow the mouse (glow, comet, trail, ripple, spotlight, …). Most declare `cursor-radius`, so only a box around the cursor reshades and the rest of the output stays scanout-eligible. | `include` |
| `screen/` | Full `global-shader {}` blocks: whole-output colour grades (CRT, grayscale, vignette, warm tint). | `include` |
| `close/` | `animations { window-close {} }` blocks with custom close shaders (fade, whirlpool, melt, ripple, lightning). | `include` |
| `window/` | Per-window `.frag` sources for `shader {}` in window rules (CRT, parchment, pixel mosaic, fisheye + RGB split, text-legibility for transparent terminals, shimmer, ripple drops, Rorschach ink, mercury sheen). | `window-rule { shader { path "…" } }` |

## Wiring

Put this directory next to `config.kdl` (as `shaders/`) and include the shaders you want
directly. Paths are relative to the config file:

```kdl
include "shaders/close/close-fade.kdl"
include "shaders/cursor/comet.kdl"
```

Each `cursor/` and `screen/` file is a complete `global-shader {}` block, so include
one at a time. To switch shaders, edit the include and reload the config.

Window shaders are wired directly, for example:

```kdl
window-rule {
    match app-id="foot"
    shader {
        path "~/.config/niri/shaders/window/crt.frag"
    }
}
```

See the [global shader docs](../../docs/wiki/Configuration:-Global-Shader.md) for the
`global_color` contract, available uniforms, multi-pass chains, and the performance notes.
