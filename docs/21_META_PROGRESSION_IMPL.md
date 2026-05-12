# META-PROGRESSION IMPLEMENTATION

## Schema: `user://hotel_meta.json`

```json
{
  "unlocked_artifacts": [
    "a1_demon_eye", "a2_blood_pact", "a3_iron_will", "a5_shadow_step"
  ],
  "unlocked_starting_stat_upgrades": [
    "s1_vitality_shard", "s4_razor_edge"
  ],
  "runs_completed": 0,
  "bosses_defeated": {},
  "secret_endings_seen": [],
  "deepest_floor_ever": 0,
  "total_limbs_severed": 0,
  "total_weapons_thrown": 0
}
```

**Transaction safety:** Unlocks are PENDING during a run (in-memory only).
Committed to meta save only in `handle_victory()`, `handle_basement_failure()`, or `trigger_ending()`.
Alt-F4 / `restart_run()` discards pending unlocks — no free unlocks.

---

## Unlock Triggers

### Artifacts (4 starting → 12 total)

| Artifact | Rarity | Unlock Trigger |
|----------|--------|---------------|
| a1_demon_eye | common | **START** (default) |
| a2_blood_pact | common | **START** (default) |
| a3_iron_will | common | **START** (default) |
| a5_shadow_step | common | **START** (default) |
| a6_golden_hand | rare | Reach Floor 3 |
| a4_hunger_blade | rare | Reach Floor 5 |
| a7_ring_of_wrath | rare | Defeat any mini-boss |
| a10_demon_heart | cursed | Reach Floor 7 |
| a9_third_eye | rare | Complete 2 runs |
| a11_crown_of_thorns | cursed | Escape basement once |
| a8_pact_of_flesh | cursed | Clear Floor 5 mini-boss |
| a12_void_contract | cursed | Reach Floor 9 |

### Starting Stat Upgrades (2 starting → 11 total)

| Upgrade | Unlock Trigger |
|---------|---------------|
| s1_vitality_shard | **START** (default) |
| s4_razor_edge | **START** (default) |
| s2_swift_step | Complete 1 run |
| s5_sure_shot | Reach Floor 3 |
| s3_iron_skin | Reach Floor 5 |
| s10_ammo_pouch | Defeat any mini-boss |
| s7_quick_hands | Complete 2 runs |
| s6_heavy_arm | Reach Floor 7 |
| s8_steady_grip | Escape basement once |
| s9_second_wind | Complete 3 runs |
| s11_bloodlust | Reach Floor 9 |

---

## Loadout Screen Mock-up

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                      L O A D O U T                         │
│                     ═══════════════                         │
│                                                            │
│    STARTING WEAPONS            STARTING UPGRADE            │
│    ┌────────────────────┐      ┌────────────────────┐      │
│    │                    │      │                    │      │
│    │  > Machete         │      │  > Vitality Shard   │  ○  │
│    │  > Sawed-off       │      │  > Razor Edge       │  ●  │
│    │                    │      │  > None             │  ○  │
│    │                    │      │                    │      │
│    └────────────────────┘      └────────────────────┘      │
│                                                            │
│                   [   START RUN   ]                        │
│                   [     BACK      ]                        │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

Flow: `title_screen` → NEW RUN → `loadout_screen` → START → `floor_01`

---

## Achievement Counters (RunState)

Incremented via EventBus during a run, committed to meta on run end:

| Counter | EventBus Signal | When |
|---------|----------------|------|
| dismembered_limbs | `limb_severed` | Any limb severed |
| weapons_thrown | `weapon_was_thrown` | Player throws weapon |
| basements_escaped | `basement_was_escaped` | Basement escape |
| no_damage_rooms | `room_cleared_no_damage` | Room cleared without damage |
| deals_with_demons | `demon_deal_made` | Player takes a demon deal |
| bosses_defeated | `mini_boss_defeated` | Mini-boss killed |

---

## Files Changed

| File | Action |
|------|--------|
| `scripts/core/save_manager.gd` | Modified — meta save/load |
| `scripts/core/game_manager.gd` | Modified — pending unlocks + triggers |
| `scripts/core/run_state.gd` | Modified — counters + EventBus wiring |
| `scripts/core/event_bus.gd` | Modified — counter signals |
| `scripts/core/artifact_registry.gd` | Modified — unlock filter |
| `scripts/ui/title_screen.gd` | Modified — STATS button + loadout flow |
| `scripts/ui/loadout_screen.gd` | **New** |
| `scenes/ui/loadout_screen.tscn` | **New** |
| `scripts/ui/stats_screen.gd` | **New** |
| `scenes/ui/stats_screen.tscn` | **New** |
| `scripts/ui/unlock_toast.gd` | **New** |
