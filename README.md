# Coin and Cantrip

A single-player narrative RPG built in **Godot 4.6 / GDScript**. Players cast spells by typing free-form text into a journal-like interface; typos are tolerated via Levenshtein fuzzy matching, and typing accuracy influences spell effectiveness.

---

## Core Concept

Spells are sentences. A sentence is made of **cantrips**, each of which has one **form** (e.g. `ray`, `cone`, `shield`) followed by up to two **elements** (e.g. `fire`, `water`), each optionally modified by **augments** (e.g. `piercing`, `amplified`). Multiple cantrips can be chained in a single spell — a new form word begins a new cantrip.

The input parser doesn't require exact spelling. Each word is fuzzy-matched against the appropriate dictionary depending on what word type is expected next (form → element → augment/element/form). The edit distance between what the player typed and the matched word is carried forward into resolution and will eventually affect spell effectiveness.

---

## Project Layout

```
coin_and_cantrip/
├── project.godot
├── EventScene.tscn        # Main scene — a single "event" (currently a battle)
├── Scripts/
│   ├── EventManager.gd       # Root controller for an event
│   ├── ActionParser.gd       # Typed text → Array[SpellWord]
│   ├── SpellCompiler.gd      # SpellWords → Spell → ResolvedSpell[]
│   ├── EncounterManager.gd   # Turn order and damage application
│   └── EventLogController.gd # Narration output to the player
├── Entities/
│   ├── Entity.gd             # Base class: health, speed, take_damage
│   ├── Player.gd             # Entity that waits for typed input
│   └── MockEnemy.gd          # Placeholder enemy
└── Libs/
    ├── ActionLib.gd          # Vocabulary + SpellWord/Cantrip/Spell classes
    ├── SpellLib.gd           # Spell resolution logic (damage calc per form)
    └── levenshtein.gd        # Edit distance utility
```

---

## Responsibilities at a Glance

| Script | Extends | Role |
|---|---|---|
| `EventManager` | `Control` | Root node of `EventScene`. Owns the current event's state (narrative / encounter / shop / resolved). Wires the input → compiler → encounter → log pipeline. |
| `ActionParser` | `LineEdit` | **Is** the input field. Reads submitted text, fuzzy-matches each word against the vocabulary expected for its position, emits the resulting `Array[SpellWord]`. |
| `SpellCompiler` | `RefCounted` | Pure logic. Groups `SpellWord`s into `Cantrip`s inside a `Spell`, then resolves each cantrip via `SpellLib` into `ResolvedSpell`s. Held as a plain field of `EventManager`. |
| `EncounterManager` | `Node` | Owns turn order via a speed-based timeline. Decides whose turn it is, calls `take_action` on entities, applies spell damage when the Player's turn resolves, detects encounter end. |
| `EventLogController` | `RichTextLabel` | **Is** the narration panel. Appends text when spells resolve, input is empty, or the encounter ends. |
| `Entity` | `Node` | Base class for anything with HP on the timeline. Emits `entity_destroyed` when its HP hits zero. |
| `Player` | `Entity` | Holds a reference to the `InputField` so it can enable/focus it on its turn. |
| `MockEnemy` | `Entity` | Temporary placeholder; hits the first living ally for 10 damage. |
| `ActionLib` | — | Source of truth for vocabulary (`forms`, `elements`, `augments`) and home for the `SpellWord`, `Cantrip`, and `Spell` data classes. |
| `SpellLib` | — | Per-form resolution functions (e.g. `resolve_ray`) that turn a `Cantrip` into a `ResolvedSpell` with final damage. |
| `Levenshtein` | — | Static utility. `Levenshtein.distance(a, b)` returns edit distance, or 128 if either string is empty. |

---

## Data Flow — One Player Turn

```
 ┌─────────────┐   text_submitted    ┌──────────────┐
 │  LineEdit   │ ──────────────────▶ │ ActionParser │
 │ (InputField)│                     │              │
 └─────────────┘                     └──────┬───────┘
                                            │ spell_parsed(Array[SpellWord])
                                            ▼
                                    ┌──────────────────┐
                                    │  EventManager    │
                                    │ (_on_input_field │
                                    │  _spell_parsed)  │
                                    └──┬───────────┬───┘
                  compile_spell(words) │           │ apply_spell_damage(spells)
                                       ▼           ▼
                          ┌────────────────┐   ┌──────────────────┐
                          │ SpellCompiler  │   │ EncounterManager │
                          │ compile ─▶     │   │ - finds target   │
                          │ resolve ─▶     │   │ - take_damage    │
                          │ (via SpellLib) │   │ - end_turn       │
                          └───────┬────────┘   └──────┬───────────┘
                                  │                   │
                         Array[ResolvedSpell]         │
                                  │                   ▼
                                  │          ┌────────────────┐
                                  └─────────▶│ EventLog       │
                                             │ on_spells_     │
                                             │ resolved(...)  │
                                             └────────────────┘
```

Per-turn ordering inside `EncounterManager`:

1. `start_encounter` seeds the timeline: `timeline[entity] = entity.entity_speed`.
2. `start_turn` picks the entity with the lowest timeline value, subtracts that value from everyone (so the fastest hits zero), and calls `take_action` on it.
3. For the `Player`, `take_action` enables the input field and hands control back to the user. For any other entity, `end_turn` is called immediately.
4. `end_turn` sets the acting entity's next turn cost (`ap_cost * entity_speed`), removes anything in `to_be_destroyed`, checks for encounter end, and otherwise loops to `start_turn`.

---

## Signal Inventory

Signals live at node boundaries. Internal calls (like `compile` → `resolve`) do **not** use signals.

| Emitter | Signal | Payload | Connected to |
|---|---|---|---|
| `ActionParser` | `text_submitted` (built-in) | `String` | self (`_on_input_field_text_submitted`) |
| `ActionParser` | `spell_parsed` | `Array[SpellWord]` | `EventManager._on_input_field_spell_parsed` |
| `ActionParser` | `empty_input` | `bool` | `EventLogController._on_input_field_empty_input` |
| `Entity` | `entity_destroyed` | `Entity` | `EncounterManager.on_entity_destroyed` |
| `EncounterManager` | `encounter_resolved` | — | `EventManager.end_encounter` |

---

## Current Vocabulary

Values below are damage multipliers / contributions used by `SpellLib`. These will move around during balancing.

**Forms** (base damage for the cantrip, also the grammar anchor)
- `ray` → 10
- `cone` → 4
- `shield` → 20

**Elements** (added to form's base damage, max 2 per cantrip)
- `fire` → 5
- `water` → 2
- `earth` → 4
- `wind` → 3

**Augments** (multipliers applied to the element they follow)
- `piercing` → ×0.4
- `amplified` → ×1.2
- `swift` → ×0.7

See `Libs/ActionLib.gd` for the source of truth.

---

## Running the Project

Open the project in **Godot 4.6** and run `EventScene.tscn` (set as the main scene). You'll land directly in a mock encounter: one Player vs. one Goblin, ready for typed input.

---

## Status

**Working:** input parsing, fuzzy matching, spell compilation, a minimal turn loop, damage application against a target dummy.

**Next up:** polish spell resolution so element multipliers and distance penalties actually shape damage (see `SpellLib.resolve_ray` — currently only `ray` is implemented).

**On the horizon:** more forms in `SpellLib`, richer enemy AI to replace `MockEnemy`, event types beyond `ENCOUNTER` (the `EVENT_STATE` enum in `EventManager` already has `NARRATIVE` and `SHOP` as placeholders).

---

## Conventions

- **Signals only at node boundaries.** If two pieces of logic live in the same script or are tightly coupled, call directly and return a value. Signal-connected functions' return values are discarded.
- **UI nodes own their own input.** `ActionParser` extends `LineEdit` rather than wrapping one; `EventLogController` extends `RichTextLabel` rather than holding one. Pure logic (e.g. `SpellCompiler`) extends `RefCounted` and is held as a field.
- **Data classes live in `Libs/`.** `SpellWord`, `Cantrip`, `Spell`, and `ResolvedSpell` are all defined inside library scripts next to the code that produces or consumes them.
- **Vocabulary is data, not code.** New forms/elements/augments are dictionary entries in `ActionLib.gd`. A new form *also* needs a resolver in `SpellLib.gd` and a `match` arm in `SpellCompiler.resolve_spell`.
