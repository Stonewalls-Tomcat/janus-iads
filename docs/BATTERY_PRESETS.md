# Janus battery presets

Generated from `src/janus_presets.lua` by `tools/check_presets.py` (43 presets, all DCS type names verified against `data/units.json`). Real-world compositions are **approximate**: tables of organisation changed by year, army and export customer; each preset lists its sources.

Everything in `CoreMods` is free DCS content, including the Currenthill pack (`CHAP_*`: Pantsir-S1, Tor-M2, IRIS-T SLM, Project 22160). Presets that use paid DLC units say so in a box.

**Count** is the full table of organisation (a range: optional units). **Reduced** is a doctrinally plausible reduced-strength unit: `JANUS.spawnBattery(preset, point, { reduced = true })`; blank = as Count (its minimum). Engagement ranges Janus uses (often shorter than DCS lists) are in `docs/REACH.md`.

## `AAA-100MM` - KS-19 100 mm battery with Fire Can

Era: Early Cold War · Users: USSR, Vietnam, China, Egypt · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `KS-19` | 6 | 4 |  | ring 60 m | 6 guns (guns per battery not firmly sourced; one SON-9 directs 4-8); effective 12 km slant / 11 km ceiling with radar |
| AAA_FC | `SON_9` | 1 |  |  |  | SON-9 Fire Can gun-laying radar (ARM-targetable); DCS needs it (the KS-19 depends on it). Cued by EW under Soviet doctrine, tracks to ~35 km |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/KS-19  (batteries of 6 guns with SON-9 / PUAZO director)
- https://man.fas.org/dod-101/sys/land/row/ks-19.htm  (12.6 km slant with radar, 4 km on-carriage sights; SON-9 tracks 35 km)
- https://www.allworldwars.com/Tactics-and-Techniques-of-Electronic-Warfare-by-Bernard-Nalty.html  (Fire Can on-air time cut to under 3 min)

## `AAA-57MM` - S-60 57 mm battery with Fire Can

Era: Early Cold War · Users: USSR, Vietnam, China, Syria, Egypt · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `S-60_Type59_Artillery` | 6 | 4 |  | ring 50 m | 6 km with radar, 4 km optical; ceiling 5 km; Vietnam batteries opened fire at 4-6 km |
| AAA_FC | `SON_9` | 1 |  |  |  | DCS needs it (the S-60 depends on it); Flap Wheel in later batteries |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/AZP_S-60  (battery: 6 guns + SON-9 radar + PUAZO-6 director)
- https://www.globalsecurity.org/military/world/russia/s-60.htm  (6 km radar / 4 km optical; PVO regiment 4 x 6)
- https://historynet.com/north-vietnams-light-anti-aircraft-artillery/

## `SA-2` - SA-2 Guideline (S-75 Dvina/Volkhov) battalion fire unit

Era: Early Cold War · Users: USSR, Vietnam, Egypt, Syria, Iraq, China · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| TR | `SNR_75V` | 1 |  |  |  | Fan Song fire-control radar at the site centre |
| LN | `S_75M_Volhov` | 6 | 3 | 1 | ring 70 m | six SM-90 launchers in a hexagon, the classic 'Star of David'; 3 when under strength (Vietnam, July 1965) |
| SR | `p-19 s-125 sr` | 1 |  |  | spacing 300 m | DCS has no P-12 Spoon Rest; P-19 Flat Face is the stand-in. DCS needs it: the Fan Song depends on it |
| TR | `RD_75` | 0-1 | 0 |  |  | RD-75 Amazonka rangefinder, optional (DCS: SA-2 counter-ECM unit) |
| AUX | `S_75_ZIL` | 2-6 | 0 |  |  | PR-11 transloaders with the 6 reload rounds, cosmetic in DCS |

Optional AAA ring: 4× `ZU-23 Emplacement` at 400 m, 2× `S-60_Type59_Artillery` at 600 m

Essential roles: TR, LN

Sources:
- https://en.wikipedia.org/wiki/S-75_Dvina  (battalion: 1 fire-control radar, 6 launchers, 'Star of David' layout)
- https://www.globalsecurity.org/military/world/russia/sa-2-site.htm  (site layout, 60-100 m launcher ring)
- http://pvo.guns.ru/s75/s75.htm  (regiment of 3 fire battalions; 1 target channel, 3 missiles guided)
- https://www.armedconflicts.com/topic/view/79150  (S-75M battalion; salvo of 3 at 6 s)
- https://ia601805.us.archive.org/34/items/soviet-air-defense-system-technical-documents/sam%20simulator/S-75%20family.pdf  (V-755 7-43 km; ~30 km vs fast targets)
- https://en.qdnd.vn/military/war-files/part-2-first-battle-first-victory-460849  (24 Jul 1965: 3 of 6 launchers assembled)

## `SA-2-VIETNAM` - SA-2 Guideline, North Vietnamese pattern (1965-72)

Era: Early Cold War · Users: Vietnam · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| TR | `SNR_75V` | 1 |  |  |  | Fan Song; emits for seconds only, shut down on Shrike launch |
| LN | `S_75M_Volhov` | 6 | 3 | 1 | ring 70 m | SA-75M Dvina (V-750, ~30 km); DCS has only the Volkhov launcher |
| SR | `p-19 s-125 sr` | 1 |  |  | spacing 2000 m | acquisition radar sited away from the launchers; the site is often cued by regiment-level radar instead |

Optional AAA ring: 6× `ZU-23 Emplacement` at 300 m, 6× `S-60_Type59_Artillery` at 800 m, 1× `SON_9`

Essential roles: TR, LN

Sources:
- https://en.wikipedia.org/wiki/Operation_Rolling_Thunder  (SA-2 belt, AAA-heavy defence, dummy sites)
- https://en.wikipedia.org/wiki/S-75_Dvina#Vietnam_War
- https://www.nationalmuseum.af.mil/Visit/Museum-Exhibits/Fact-Sheets/Display/Article/195928/  (Wild Weasel vs SA-2 sites)
- https://allworldwars.com/Tactics-and-Techniques-of-Electronic-Warfare-by-Bernard-Nalty.html  (Fan Song on-air time cut from 10-12 to under 3 min; ~17 nm range)
- https://www.globalsecurity.org/military/world/vietnam/nva-ad-sam.htm  (ambush positions, moves, dummy sites; 3-round doctrine, often 1 fired)

## `AAA-GEPARD` - Gepard battery

Era: Late Cold War · Users: Germany, Netherlands, Belgium · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `Gepard` | 6-7 | 3 |  | spacing 200 m | battery of 6 (1980s) or 7 (1A2 era); own 15 km search radar |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/Flakpanzer_Gepard

## `EW-SOVIET` - Soviet radiotechnical post

Era: Late Cold War · Users: USSR, Russia · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| EWR | `55G6 EWR` | 1 |  |  |  | Tall Rack, or 1L13 Box Spring |
| C2_GENERIC | `SKP-11` | 0-1 |  |  |  |  |
| POWER | `generator_5i57` | 0-1 |  |  |  |  |

Essential roles: EWR

Sources:
- https://en.wikipedia.org/wiki/Soviet_Air_Defence_Forces

## `HAWK` - MIM-23 I-Hawk (Phase III) battery

Era: Late Cold War · Users: USA, Germany, Israel, Iran, Spain, Greece, Turkey, Taiwan, Japan · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| C2 | `Hawk pcp` | 1 |  |  |  | Platoon Command Post (DCS needs it: the HPIR depends on it) |
| SR | `Hawk sr` | 1 | 0 |  |  | AN/MPQ-50 PAR pulse acquisition radar |
| SR | `Hawk cwar` | 1 |  |  | spacing 100 m | AN/MPQ-55 CWAR low-altitude acquisition |
| TR | `Hawk tr` | 2 | 1 |  | spacing 150 m | AN/MPQ-46 HPIR illuminators, one per firing section |
| LN | `Hawk ln` | 6 | 3 | 3 | ring 120 m | M192 launchers, 3 missiles each; 3 per HPIR. Reduced = assault fire unit (CWAR + HPIR + 3 LN) |

Essential roles: TR, LN

Sources:
- https://en.wikipedia.org/wiki/MIM-23_Hawk  (I-Hawk battery: PCP, PAR, CWAR, 2 HPIR, 6 launchers)

## `RAPIER` - Rapier FSA troop

Era: Late Cold War · Users: UK, Iran, Turkey, Oman · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `rapier_fsa_launcher` | 4 | 1 | 4 | spacing 600 m | troop of 4 fire units; reduced = one fire unit |
| SR | `rapier_fsa_optical_tracker_unit` | 4 | 1 |  | spacing 600 m |  |
| TR | `rapier_fsa_blindfire_radar` | 0-2 | 0 |  | spacing 600 m | Blindfire DN181: only about a third of British fire units had one |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/Rapier_(missile)  (troop of 4 fire units, battery of 3 troops; ~1/3 with Blindfire; 0.4-8.2 km)

## `ROLAND` - Roland battery

Era: Late Cold War · Users: Germany, France, USA, Iraq · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `Roland ADS` | 6 | 3 | 8 | spacing 300 m | each fire unit has its own 15-18 km search radar; Luftwaffe batteries had 8 |
| SR | `Roland Radar` | 0-1 | 0 |  |  | battery search radar (TRML-2D in Luftwaffe batteries) |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/Roland_(missile)

## `SA-10` - SA-10 Grumble (S-300PS) battalion

Era: Late Cold War · Users: USSR, Russia, Ukraine, Syria, Iran, China · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| C2 | `S-300PS 54K6 cp` | 1 |  |  |  | DCS needs it (the 40B6M depends on it): stands in for the battalion's 5N63S command cabin; the real 54K6 / 83M6 is regiment-level (SA-10-REGIMENT) |
| TR | `S-300PS 40B6M tr` | 1 |  |  |  | 30N6 Flap Lid on 40V6M mast (or 5H63C 30H6_tr truck-mounted) |
| SR | `S-300PS 40B6MD sr` | 1 |  |  |  | 76N6 / 5N66M Clam Shell low-altitude detector, battalion-level; DCS needs one search radar (the 54K6 depends on it). 40B6MD sr_19J6 Tin Shield for a battalion acting alone |
| LN | `S-300PS 5P85C ln` | 4 | 2 | 4 | ring 250 m | 5P85S master TELs: one per launch group of 1 S + 2 D |
| LN | `S-300PS 5P85D ln` | 8 | 4 | 4 | ring 350 m | 5P85D slave TELs (fire only through their 5P85S) |
| POWER | `generator_5i57` | 0-2 |  |  |  |  |

Essential roles: TR, LN

Sources:
- https://en.wikipedia.org/wiki/S-300_missile_system  (12 TELs per 83M6E; the '4 TELs' line is Iran's export S-300PMU2 batteries)
- https://dic.academic.ru/dic.nsf/ruwiki/1132644  (divizion: 5N63S + up to 4 launch groups of 5P85S + 2 5P85D; 5V55R 75 km; 6 targets x 2 missiles)
- https://militarnyi.com/uk/articles/zrk-s-300/  (up to 4 launch complexes per divizion; 25 m - 27 km)
- https://nuke.fas.org/guide/russia/airdef/s-300pmu.htm  (low-level reach: 32 km, 43 km with the mast)
- https://www.ausairpower.net/APA-Grumble-Gargoyle.html  (Western 'battery' = Russian divizion; 40V6M mast)

## `SA-10-REGIMENT` - SA-10 Grumble (S-300PS) regiment command and search

Era: Late Cold War · Users: USSR, Russia, Ukraine · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| C2 | `S-300PS 54K6 cp` | 1 |  |  |  | 83M6 command system (54K6 / 5K56 battle-control post): controls up to 6 battalions |
| SR | `S-300PS 64H6E sr` | 1 |  |  | spacing 500 m | 64N6 Big Bird, one per regiment |
| POWER | `generator_5i57` | 0-1 |  |  |  |  |

Essential roles: SR

Sources:
- https://dic.academic.ru/dic.nsf/ruwiki/1132644  (5N83S command post = 5N64S Big Bird + 5K56S; up to 6 battalions)
- https://origin.armedconflicts.com/topic/view/174212  (S-300PS regiment organisation)

## `SA-11` - SA-11 Gadfly (9K37 Buk-M1) battalion

Era: Late Cold War · Users: USSR, Russia, Ukraine, Syria, Georgia · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| C2 | `SA-11 Buk CC 9S470M1` | 1 |  |  |  | 9S470M1 command post |
| SR | `SA-11 Buk SR 9S18M1` | 1 |  |  | spacing 300 m | Snow Drift |
| TELAR | `SA-11 Buk LN 9A310M1` | 6 | 4 | 4 | spacing 250 m | 3 batteries of 2 TELAR (+ a 9A39 loader-launcher, absent from DCS); each TELAR has its own Fire Dome and can fight alone |

Essential roles: TELAR

Sources:
- https://en.wikipedia.org/wiki/Buk_missile_system
- https://dic.academic.ru/dic.nsf/ruwiki/1286330  (battalion: 9S470 + 9S18 + 3 batteries of 2 9A310 + 1 9A39; brigade of 4 battalions)
- https://www.ausairpower.net/APA-9K37-Buk.html  (Buk-M1 3-35 km vs aircraft; DCS's 50 km is a later figure)

## `SA-13` - SA-13 Gopher (9K35 Strela-10) platoon

Era: Late Cold War · Users: USSR, Russia, Syria · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `Strela-10M3` | 4-6 | 2 | 4 | spacing 200 m | 4 in a Cold War platoon, 6 in the later AD battalion's battery |
| SR | `Dog Ear radar` | 0-1 |  |  |  |  |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/9K35_Strela-10
- https://man.fas.org/dod-101/sys/land/row/avoac-opfor-sh.htm  (4 per platoon; 6 2S6 + 6 SA-13 in the later regimental AD battalion)

## `SA-15` - SA-15 Gauntlet (9K330 Tor) battery

Era: Late Cold War · Users: USSR, Russia, China, Iran · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `Tor 9A331` | 4 | 2 | 8 | spacing 300 m | self-contained; used by Janus as point defence. Tor-M1: 2 targets, 2 missiles each, 1.5-12 km |
| SR | `Dog Ear radar` | 0-1 | 0 |  |  | battery command post stand-in (Ranzhir absent from DCS) |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/Tor_missile_system  (battery of four TLARs)

## `SA-19` - SA-19 Grison (2K22 Tunguska) battery

Era: Late Cold War · Users: USSR, Russia · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `2S6 Tunguska` | 6 | 4 | 8 | spacing 300 m | missiles 1.5-8 km (M1: 10 km), guns to 4 km |
| SR | `Dog Ear radar` | 0-1 | 0 |  |  | PPRU-1 regimental AD command post |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/2K22_Tunguska  (battery of 6; PPRU-1 cueing)
- https://man.fas.org/dod-101/sys/land/row/avoac-opfor-sh.htm

## `SA-6` - SA-6 Gainful (2K12 Kub) battery

Era: Late Cold War · Users: USSR, Syria, Egypt, Iraq, Yugoslavia, Libya · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| STR | `Kub 1S91 str` | 1 |  |  |  | Straight Flush search/track/illuminate |
| LN | `Kub 2P25 ln` | 4 | 2 | 3 | ring 200 m | 2P25 TELs |
| SR | `p-19 s-125 sr` | 0-1 | 0 |  | spacing 2000 m | regiment acquisition (P-15/P-19 + PRV-16; 1S12 Long Track absent from DCS): normally a separate EW group |
| AUX | `ATZ-10` | 0-2 | 0 |  |  | reload/fuel trucks, cosmetic |

Essential roles: STR, LN

Sources:
- https://en.wikipedia.org/wiki/2K12_Kub  (battery: 1 1S91 + 4 2P25; 4-24 km; illumination from 28 km)
- https://www.ausairpower.net/APA-Legacy-SAM-TEL-TL.html  (regiment: P-12/18 or P-15, PRV-16, 1S12; 5 batteries)
- https://www.globalsecurity.org/military/world/russia/sa-6-ops.htm  (one illuminator: no second engagement until the first missile arrives)

## `EW-NATO` - NATO long-range radar site

Era: Late Cold War / Modern · Users: USA, NATO · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| EWR | `FPS-117` | 1 |  |  |  | AN/FPS-117 (Dome variant for fixed sites) |
| EWR | `FPS-117 ECS` | 0-1 |  |  |  | ECS shelter |

Essential roles: EWR

Sources:
- https://en.wikipedia.org/wiki/AN/FPS-117

## `LINEBACKER` - M6 Linebacker (Bradley Stinger) platoon

Era: Late Cold War / Modern · Users: USA · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `M6 Linebacker` | 4 | 2 | 4 | spacing 300 m | 4 ready Stingers + 6 reloads; heavy-division ADA; platoon size not sourced |
| SR | `NASAMS_Radar_MPQ64F1` | 0-1 | 0 |  |  | Sentinel / FAAD C2 slew-to-cue |

Essential roles: SHORAD

Sources:
- https://www.army-technology.com/projects/linebacker/
- https://man.fas.org/dod-101/sys/land/m6.htm  (FAAD C2 and Sentinel cueing)

## `PATRIOT` - MIM-104 Patriot battery

Era: Late Cold War / Modern · Users: USA, Germany, Netherlands, Israel, Saudi Arabia, Japan, Poland · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| STR | `Patriot str` | 1 |  |  |  | AN/MPQ-53/65 radar set |
| C2 | `Patriot ECS` | 1 |  |  |  | Engagement Control Station |
| C2 | `Patriot EPP` | 1 |  |  |  | Electric Power Plant (Janus treats it as the battery's POWER node) |
| C2 | `Patriot AMG` | 1 | 0 |  |  | Antenna Mast Group (comms relay) |
| C2 | `Patriot cp` | 0-1 | 0 |  |  | ICC, battalion-level; one per 3-6 batteries |
| LN | `Patriot ln` | 8 | 4 | 4 | ring 300 m | M901 launching stations, PAC-2 (4 per launcher); FM 44-85: 8 per fire unit (Wikipedia: nominally 6) |

Essential roles: STR, LN

Sources:
- https://en.wikipedia.org/wiki/MIM-104_Patriot  (battery: radar set, ECS, EPP, AMG, up to 8 launchers; ICC at battalion)
- https://www.globalsecurity.org/space/library/policy/army/fm/44-85/Appb.htm  (FM 44-85: fire unit ECS, AMG, RS, EPP, 8 launching stations; ICC at battalion)

## `AAA-SHILKA` - ZSU-23-4 Shilka platoon

Era: Mid Cold War · Users: USSR, Syria, Egypt, Iraq · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `ZSU-23-4 Shilka` | 4 | 2 |  | spacing 200 m | radar-directed; Gun Dish is ARM-targetable; 2.5 km, ceiling 1.5-2 km; 2 per first-echelon battalion in the attack |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/ZSU-23-4_Shilka

## `AAA-VULCAN` - M163 Vulcan platoon

Era: Mid Cold War · Users: USA, Israel · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `Vulcan` | 4 | 2 |  | spacing 200 m | range-only radar, cued visually or by FAAR; 1.2-2.5 km |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/M163_VADS

## `AAA-ZU23` - ZU-23 light AAA section

Era: Mid Cold War · Users: USSR, Vietnam, Syria, Iraq · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `ZU-23 Emplacement` | 4 | 2 |  | spacing 80 m | platoon of 4 (2 per battery); airborne batteries of 6; effective 2 km, 1.5 km ceiling |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/ZU-23-2
- https://man.fas.org/dod-101/sys/land/row/avoac-opfor-sh.htm  (platoons of 4)
- https://gulflink.health.mil/irfna/irfna_refs/n28en143/airdef.html  (2.5 km effective)

## `CHAPARRAL` - Chaparral platoon

Era: Mid Cold War · Users: USA, Israel, Taiwan · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `M48 Chaparral` | 4 | 2 | 4 | spacing 300 m | visual/IR detection, FAAR radar alerting; Vulcans were separate batteries of the same battalion: co-site AAA-VULCAN |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/MIM-72_Chaparral

## `SA-3` - SA-3 Goa (S-125 Neva/Pechora) battery

Era: Mid Cold War · Users: USSR, Syria, Egypt, Libya, Yugoslavia · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| TR | `snr s-125 tr` | 1 |  |  |  | Low Blow fire-control radar |
| SR | `p-19 s-125 sr` | 1 |  |  | spacing 200 m | Flat Face acquisition; DCS needs it (the Low Blow depends on it) |
| LN | `5p73 s-125 ln` | 4 | 2 | 4 | ring 60 m | 5P73 quad launchers (early batteries: 2-rail 5P71) |

Essential roles: TR, LN

Sources:
- https://en.wikipedia.org/wiki/S-125_Neva/Pechora  (battery: 1 SNR-125, 4 launchers, P-15/P-19 acquisition)
- https://ia601805.us.archive.org/34/items/soviet-air-defense-system-technical-documents/sam%20simulator/S-125%20family.pdf  (5V27 6-17 km, 5V27D 3.5-17 km; 2 missiles guided)
- http://pvo.guns.ru/s125/s125.htm  (battery composition; low targets only to ~10 km)

## `SA-5` - SA-5 Gammon (S-200 Angara/Vega) fire channel

Era: Mid Cold War · Users: USSR, Syria, Libya, Iran, Ukraine · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| TR | `RPC_5N62V` | 1 |  |  |  | Square Pair illuminator |
| LN | `S-200_Launcher` | 6 | 3 | 1 | ring 150 m | 5P72 launchers; 2 5Yu24 loaders each, cosmetic |
| SR | `P14_SR` | 1 |  |  | spacing 1000 m | P-14 Tall King: group-level (K-9M post, up to 5 channels), but DCS needs one in the group: the 5N62 depends on it (or RLS_19J6 / P-19) |

Essential roles: TR, LN

Sources:
- https://en.wikipedia.org/wiki/S-200_(missile)  (fire channel: one 5N62 + six launchers; VE 240-255 km, min 17 km)
- https://ausairpower.net/APA-S-200VE-Vega-Sites.html  (site layout: K-1/K-2/K-3, 6 launchers, 12 loaders)
- https://itc.ua/en/articles/s-200-sam-could-a-60-year-old-weapon-shoot-down-an-a-50/amp/  (K-9M controls up to 5 channels; 190 km vs fighter-bombers, 300 km vs large aircraft)

## `SA-8` - SA-8 Gecko (9K33 Osa) battery

Era: Mid Cold War · Users: USSR, Syria, Iraq, Libya, Algeria · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `Osa 9A33 ln` | 4 | 2 | 6 | spacing 300 m | self-contained TELARs |
| SR | `Dog Ear radar` | 0-1 | 0 |  |  | stand-in for the PU-12 / Ranzhir battery command post (PPRU-1 serves gun/Strela batteries, not Osa) |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/9K33_Osa  (battery of four TELARs; Osa-AK 1.5-10 km)
- https://en.wikipedia.org/wiki/PPRU-1  (PPRU-1 belongs to the regimental AD battery)

## `SA-9` - SA-9 Gaskin (9K31 Strela-1) platoon

Era: Mid Cold War · Users: USSR, Syria, Egypt · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `Strela-1 9P31` | 4 | 2 | 4 | spacing 200 m | passive (Flat Box warning): no radar to manage |
| SR | `Dog Ear radar` | 0-1 |  |  |  |  |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/9K31_Strela-1
- https://man.fas.org/dod-101/sys/land/row/avoac-opfor-sh.htm  (regimental AD battery: 4 ZSU-23-4 + 4 SA-9/13)

## `AVENGER` - Avenger platoon

Era: Modern · Users: USA · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `M1097 Avenger` | 6 | 2 | 8 | spacing 300 m | platoon HQ + 3 sections of 2 |
| SR | `NASAMS_Radar_MPQ64F1` | 0-1 | 0 |  |  | Sentinel radar cueing, as in a US SHORAD battery |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/AN/TWQ-1_Avenger
- https://www.globalsecurity.org/military/agency/army/platoon.htm  (Avenger platoon: 3 sections of 2)

## `C-RAM` - C-RAM LPWS section

Era: Modern · Users: USA, UK · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| CRAM | `HEMTT_C-RAM_Phalanx` | 2-4 |  |  | spacing 400 m | Land-based Phalanx Weapon System around the protected base; the DCS unit has its own radar. In DCS its engagement of rockets/missiles/bombs is measured by the Phase 0 probe mission |

Essential roles: CRAM

Sources:
- https://en.wikipedia.org/wiki/Counter_Rocket,_Artillery,_and_Mortar  (LPWS deployed in sections of several mounts around a base)
- https://en.wikipedia.org/wiki/Phalanx_CIWS#Land-based_variant

## `CSG-USN` - US Navy carrier strike group escort

Era: Modern · Users: USA · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| NAVAL_AD | `CVN_73` | 1 |  |  |  | any Supercarrier hull: CVN_71/72/73/75 |
| NAVAL_AD | `TICONDEROG` | 1 |  |  | spacing 3000 m | Ticonderoga CG, air-defence commander |
| NAVAL_AD | `USS_Arleigh_Burke_IIa` | 2 |  |  | spacing 3000 m |  |
| NAVAL_AD | `PERRY` | 1 |  |  | spacing 1500 m | plane guard |

Essential roles: NAVAL_AD

Sources:
- https://en.wikipedia.org/wiki/Carrier_strike_group  (typical CSG: 1 CG, 2-3 DDG/FFG)

## `HQ-7` - HQ-7B (FM-90) battery

Era: Modern · Users: China, Pakistan, Iran · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| C2 | `HQ-7_STR_SP` | 1 |  |  |  | search unit; acts as C2 and search radar (25 km) |
| SHORAD | `HQ-7_LN_SP` | 3 | 2 | 4 | ring 300 m | each launch unit carries its own tracking radar; 0.7-12 km vs aircraft. HQ-7_LN_P is the Combined Arms player copy, not a towed variant |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/HQ-7  (battery: 1 search unit + 3 launch units)
- https://ausairpower.net/APA-HQ-7-Crotale.html  (0.7-12 km vs aircraft, 15 km vs helicopters, 30-6000 m)

## `IRIS-T-SLM` - IRIS-T SLM fire unit

Era: Modern · Users: Germany, Ukraine, Egypt, Sweden · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| C2 | `CHAP_IRISTSLM_CP` | 1 |  |  |  | tactical operations centre; Currenthill pack (free, in CoreMods) |
| STR | `CHAP_IRISTSLM_STR` | 1 |  |  |  | TRML-4D radar |
| LN | `CHAP_IRISTSLM_LN` | 3 | 2 | 8 | ring 400 m |  |

Essential roles: STR, LN

Sources:
- https://en.wikipedia.org/wiki/IRIS-T_SLM  (fire unit: TOC, TRML-4D, 3 launchers x 8 missiles)

## `NASAMS` - NASAMS fire unit

Era: Modern · Users: Norway, USA, Netherlands, Finland, Spain, Ukraine · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| C2 | `NASAMS_Command_Post` | 1 |  |  |  | Fire Distribution Center |
| SR | `NASAMS_Radar_MPQ64F1` | 1 |  |  |  | AN/MPQ-64F1 Sentinel |
| LN | `NASAMS_LN_C` | 3 | 2 | 6 | ring 400 m | AIM-120C canisters; NASAMS_LN_B (AIM-120B) is the same launcher for older fire units |

Essential roles: C2, SR, LN

Sources:
- https://en.wikipedia.org/wiki/NASAMS  (fire unit: 1 FDC, 1 Sentinel, 3 launchers x 6 missiles; battery = 3 fire units)

## `PANTSIR` - SA-22 Greyhound (Pantsir-S1) battery

Era: Modern · Users: Russia, Syria · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `CHAP_PantsirS1` | 6 | 3 | 12 | spacing 300 m | Currenthill pack unit (free, in CoreMods); battery size uncertain (6, or 3 per half-battery); 2-3 cover one S-300/S-400 battalion |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/Pantsir_missile_system  (6 per battery; 2 targets per vehicle; to 20 km)
- https://russiandefpolicy.com/tag/pantsir-s/  (two-battery unit of six vehicles: conflicting)

## `SAG-RU` - Russian surface action group

Era: Modern · Users: Russia · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| NAVAL_AD | `MOSCOW` | 1 |  |  |  | Slava-class cruiser, SA-N-6 |
| NAVAL_AD | `NEUSTRASH` | 1 |  |  | spacing 3000 m |  |
| NAVAL_AD | `REZKY` | 1 |  |  | spacing 3000 m |  |
| NAVAL_AD | `MOLNIYA` | 2 |  |  | spacing 2000 m |  |

Essential roles: NAVAL_AD

Sources:
- https://en.wikipedia.org/wiki/Slava-class_cruiser

## `TOR-M2` - SA-15 Gauntlet (Tor-M2) battery

Era: Modern · Users: Russia, Belarus · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| SHORAD | `CHAP_TorM2` | 4 | 2 | 16 | spacing 300 m | Currenthill pack unit (free, in CoreMods); 4 targets, 16 km |

Essential roles: SHORAD

Sources:
- https://en.wikipedia.org/wiki/Tor_missile_system#Tor-M2

## `AAA-US-WWII` - US automatic-weapons AAA platoon (WWII)

Era: WWII · Users: USA, UK · *approximate*

> **Requires the DCS: WWII Assets Pack DLC.** A mission that uses these units only loads for players and servers that own it; Janus warns about this in the setup report and `spawnBattery` refuses the preset when the DLC is missing.

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `M45_Quadmount` | 3 | 2 |  | spacing 60 m | M45 quad .50 cal: one per fire unit (effective 500-800 yd) |
| AAA | `bofors40` | 0-3 | 0 |  | spacing 80 m | Bofors 40 mm with director: one per fire unit (core unit) |
| AAA | `M1_37mm` | 0-3 | 2 |  | spacing 80 m | early-war alternative to the Bofors |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/M45_Quadmount
- https://ibiblio.org/hyperwar/USA/ref/FM/PDFs/FM44-2.PDF  (FM 44-2: fire unit = 40 mm + director + quad .50; battery of 8 fire units in platoons of 3, 3, 2)

## `EW-WWII-GERMAN` - German radar site, Freya + Würzburg (WWII)

Era: WWII · Users: Germany · *approximate*

> **Requires the DCS: WWII Assets Pack DLC.** A mission that uses these units only loads for players and servers that own it; Janus warns about this in the setup report and `spawnBattery` refuses the preset when the DLC is missing.

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| EWR | `FuMG-401` | 1 |  |  |  | Freya LZ early warning |
| EWR | `FuSe-65` | 2 | 1 |  | spacing 200 m | Würzburg-Riese: one tracks the fighter, one the bomber (Himmelbett box) |
| POWER | `Maschinensatz_33` | 0-1 |  |  |  |  |

Essential roles: EWR

Sources:
- https://en.wikipedia.org/wiki/Freya_radar
- https://en.wikipedia.org/wiki/W%C3%BCrzburg_radar

## `FLAK-88` - Heavy Flak battery, 8.8 cm Flak 18/36/37 (WWII)

Era: WWII · Users: Germany · *approximate*

> **Requires the DCS: WWII Assets Pack DLC.** A mission that uses these units only loads for players and servers that own it; Janus warns about this in the setup report and `spawnBattery` refuses the preset when the DLC is missing.

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `flak18` | 4-6 | 4 |  | ring 60 m | 4-gun heavy battery, 6 from 1942 (flak36 / flak37 the same gun; flak41 for late-war Reich defence); ~8 km effective ceiling |
| AAA_FC | `KDO_Mod40` | 1 |  |  |  | Kommandogerät 40 director about 270 m from the guns; DCS needs it (the 8.8 cm guns depend on it) |
| AAA | `flak30` | 0-2 | 0 |  | spacing 80 m | 2 cm light guns for close defence of the battery |
| AAA | `Flakscheinwerfer_37` | 0-3 | 0 |  | ring 2000 m | searchlights for night defence, sited 1.5-2.5 km out; separate searchlight units of 9-12 in practice |
| POWER | `Maschinensatz_33` | 0-1 |  |  |  |  |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/8.8_cm_Flak_18/36/37/41  (batteries of 4-6 guns with a Kommandogerät director; 8 km effective ceiling)
- https://lonesentry.com/articles/ttt07/heavy-aa-battery.html  (German heavy battery: 4 or 6 guns + 2 light guns)
- https://en.wikipedia.org/wiki/German_searchlights_of_World_War_II

## `FLAK-LIGHT` - Light Flak battery, 2 cm Flak 38 / Flakvierling 38 (WWII)

Era: WWII · Users: Germany · *approximate*

> **Requires the DCS: WWII Assets Pack DLC.** A mission that uses these units only loads for players and servers that own it; Janus warns about this in the setup report and `spawnBattery` refuses the preset when the DLC is missing.

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `flak38` | 3-6 | 3 |  | spacing 60 m | Flakvierling 38 (four-barrel 2 cm); 2.2 km effective vertical |
| AAA | `flak30` | 0-6 | 0 |  | spacing 60 m | single 2 cm Flak (DCS name 'Flak 38 20mm'); battery of 12 in 4 platoons of 3. DCS has no 3.7 cm Flak (flak36 is the 8.8 cm) |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/2_cm_Flak_30/38/Flakvierling

## `HAA-UK-37IN` - British heavy AA battery, QF 3.7 inch (WWII)

Era: WWII · Users: UK · *approximate*

> **Requires the DCS: WWII Assets Pack DLC.** A mission that uses these units only loads for players and servers that own it; Janus warns about this in the setup report and `spawnBattery` refuses the preset when the DLC is missing.

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `QF_37_AA` | 8 | 4 |  | ring 80 m | 2 troops of 4 guns; effective ceiling 7.2-7.7 km (9.8 km with the late No.11 predictor) |
| AAA_FC | `Allies_Director` | 2 | 1 |  | spacing 300 m | one predictor + GL radar per troop; DCS needs it (the 3.7 inch depends on it) |
| AAA | `bofors40` | 0-2 | 0 |  | spacing 150 m | light guns for close defence |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/QF_3.7-inch_AA_gun
- https://ra39-45.co.uk/organisation/heavy-anti-aircraft-organisation/heavy-anti-aircraft-battery  (battery of 2 troops of 4 guns)

## `JP-HEAVY` - Japanese heavy AA battery, Type 88 75 mm (WWII)

Era: WWII · Users: Japan · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `Type_88_75mm_AA` | 4 | 2 |  | spacing 30 m | 4 guns in a rectangle 15-35 m apart (Type_3_80mm_AA for island / navy garrisons); ~7 km effective; no director or radar unit in DCS |
| AAA | `Type_96_25mm_AA` | 2 | 1 |  | spacing 120 m | light guns for close defence |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/Type_88_75_mm_AA_gun
- https://lonesentry.com/manuals/handbook-japanese-military/japanese-antiaircraft.html  (12-gun battalion: 4 per battery; batteries of 2 to 12 reported)
- https://m.lonesentry.com/manuals/handbook-japanese-military/antiaircraft-tactics.html  (all guns on the lead aircraft)

## `JP-LIGHT` - Japanese light AA, Type 96 25 mm (WWII)

Era: WWII · Users: Japan · *approximate*

| Role | DCS type | Count | Reduced | Missiles | Layout | Note |
|---|---|---|---|---|---|---|
| AAA | `Type_96_25mm_AA` | 4-6 | 2 |  | spacing 100 m | around an airstrip; fire beyond 2 km was 'completely ineffective' |
| AAA | `Type_94_25mm_AA_Truck` | 0-2 | 0 |  | spacing 150 m |  |

Essential roles: AAA

Sources:
- https://en.wikipedia.org/wiki/Type_96_25_mm_AT/AA_gun
- https://lonesentry.com/articles/ttt/japanese_aa_regiment-flak.html

