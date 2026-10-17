-- Janus IADS - battery presets: how real batteries are built, mapped to DCS unit types.
-- Lua 5.1. Hand-written data; validated by tools/check_presets.py against src/janus_units.lua
-- (every `type` below must exist in DCS and carry the role the preset says it does).
--
-- Fields per preset:
--   name, era, nations         : for doctrine-profile filters and the setup report
--   units = { {role, type, count, missiles=, ring=, spacing=, note=}, ... }
--       role    : Janus role the unit fills in this battery (see docs/UNIT_DATA_REPORT.md)
--       count   : typical number in one battery / fire unit ("min-max" as {min,max})
--       missiles: ready missiles per launcher in DCS (from GT_t.LN_t ammo_capacity where known)
--       ring    : launchers placed on a ring of this radius (m) around the fire-control radar
--       spacing : typical separation (m) between like units
--   essential = { role, ... }  : roles without which the site cannot fire (setup report warns)
--   aaa_ring = { ... }         : optional gun ring the spawner can add
--   approx = true              : sources disagree or the figure is an estimate
--   requires = { "DLC name" }  : paid DCS content the units need (e.g. "WWII Assets Pack"). Missions using such a
--                                preset only load for players/servers that own the DLC; Janus says so in the setup
--                                report. Free asset packs in CoreMods (Currenthill, China, Cold War...) need no entry
--   sources = { "url or citation", ... }
--
-- Real-world figures are approximate by nature: unit tables changed by year, army and export
-- customer. Each preset cites its sources; where they disagree the preset says so.

JANUS = JANUS or {}
JANUS.Presets = {

  -- ===================================================================== Soviet / Russian
  ["SA-2"] = {
    name = "SA-2 Guideline (S-75 Dvina/Volkhov) battalion fire unit", era = "Early Cold War",
    nations = { "USSR", "Vietnam", "Egypt", "Syria", "Iraq", "China" },
    units = {
      { role = "TR", type = "SNR_75V",        count = 1, note = "Fan Song fire-control radar at the site centre" },
      { role = "LN", type = "S_75M_Volhov",   count = 6, reduced = 3, missiles = 1, ring = 70, note = "six SM-90 launchers in a hexagon, the classic 'Star of David'; 3 when under strength (Vietnam, July 1965)" },
      { role = "SR", type = "p-19 s-125 sr",  count = 1, spacing = 300, note = "DCS has no P-12 Spoon Rest; P-19 Flat Face is the stand-in. DCS needs it: the Fan Song depends on it" },
      { role = "TR", type = "RD_75",          count = { 0, 1 }, reduced = 0, note = "RD-75 Amazonka rangefinder, optional (DCS: SA-2 counter-ECM unit)" },
      { role = "AUX", type = "S_75_ZIL",      count = { 2, 6 }, reduced = 0, note = "PR-11 transloaders with the 6 reload rounds, cosmetic in DCS" },
    },
    essential = { "TR", "LN" },
    aaa_ring = { { type = "ZU-23 Emplacement", count = 4, ring = 400 }, { type = "S-60_Type59_Artillery", count = 2, ring = 600 } },
    approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/S-75_Dvina  (battalion: 1 fire-control radar, 6 launchers, 'Star of David' layout)",
      "https://www.globalsecurity.org/military/world/russia/sa-2-site.htm  (site layout, 60-100 m launcher ring)",
      "http://pvo.guns.ru/s75/s75.htm  (regiment of 3 fire battalions; 1 target channel, 3 missiles guided)",
      "https://www.armedconflicts.com/topic/view/79150  (S-75M battalion; salvo of 3 at 6 s)",
      "https://ia601805.us.archive.org/34/items/soviet-air-defense-system-technical-documents/sam%20simulator/S-75%20family.pdf  (V-755 7-43 km; ~30 km vs fast targets)",
      "https://en.qdnd.vn/military/war-files/part-2-first-battle-first-victory-460849  (24 Jul 1965: 3 of 6 launchers assembled)",
    },
  },

  ["SA-2-VIETNAM"] = {
    name = "SA-2 Guideline, North Vietnamese pattern (1965-72)", era = "Early Cold War",
    nations = { "Vietnam" },
    units = {
      { role = "TR", type = "SNR_75V",        count = 1, note = "Fan Song; emits for seconds only, shut down on Shrike launch" },
      { role = "LN", type = "S_75M_Volhov",   count = 6, reduced = 3, missiles = 1, ring = 70, note = "SA-75M Dvina (V-750, ~30 km); DCS has only the Volkhov launcher" },
      { role = "SR", type = "p-19 s-125 sr",  count = 1, spacing = 2000, note = "acquisition radar sited away from the launchers; the site is often cued by regiment-level radar instead" },
    },
    essential = { "TR", "LN" },
    aaa_ring = { { type = "ZU-23 Emplacement", count = 6, ring = 300 }, { type = "S-60_Type59_Artillery", count = 6, ring = 800 }, { type = "SON_9", count = 1 } },
    approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/Operation_Rolling_Thunder  (SA-2 belt, AAA-heavy defence, dummy sites)",
      "https://en.wikipedia.org/wiki/S-75_Dvina#Vietnam_War",
      "https://www.nationalmuseum.af.mil/Visit/Museum-Exhibits/Fact-Sheets/Display/Article/195928/  (Wild Weasel vs SA-2 sites)",
      "https://allworldwars.com/Tactics-and-Techniques-of-Electronic-Warfare-by-Bernard-Nalty.html  (Fan Song on-air time cut from 10-12 to under 3 min; ~17 nm range)",
      "https://www.globalsecurity.org/military/world/vietnam/nva-ad-sam.htm  (ambush positions, moves, dummy sites; 3-round doctrine, often 1 fired)",
    },
  },

  ["SA-3"] = {
    name = "SA-3 Goa (S-125 Neva/Pechora) battery", era = "Mid Cold War",
    nations = { "USSR", "Syria", "Egypt", "Libya", "Yugoslavia" },
    units = {
      { role = "TR", type = "snr s-125 tr",   count = 1, note = "Low Blow fire-control radar" },
      { role = "SR", type = "p-19 s-125 sr",  count = 1, spacing = 200, note = "Flat Face acquisition; DCS needs it (the Low Blow depends on it)" },
      { role = "LN", type = "5p73 s-125 ln",  count = 4, reduced = 2, missiles = 4, ring = 60, note = "5P73 quad launchers (early batteries: 2-rail 5P71)" },
    },
    essential = { "TR", "LN" },
    approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/S-125_Neva/Pechora  (battery: 1 SNR-125, 4 launchers, P-15/P-19 acquisition)",
      "https://ia601805.us.archive.org/34/items/soviet-air-defense-system-technical-documents/sam%20simulator/S-125%20family.pdf  (5V27 6-17 km, 5V27D 3.5-17 km; 2 missiles guided)",
      "http://pvo.guns.ru/s125/s125.htm  (battery composition; low targets only to ~10 km)",
    },
  },

  ["SA-5"] = {
    name = "SA-5 Gammon (S-200 Angara/Vega) fire channel", era = "Mid Cold War",
    nations = { "USSR", "Syria", "Libya", "Iran", "Ukraine" },
    units = {
      { role = "TR", type = "RPC_5N62V",      count = 1, note = "Square Pair illuminator" },
      { role = "LN", type = "S-200_Launcher", count = 6, reduced = 3, missiles = 1, ring = 150, note = "5P72 launchers; 2 5Yu24 loaders each, cosmetic" },
      { role = "SR", type = "P14_SR",         count = 1, spacing = 1000, note = "P-14 Tall King: group-level (K-9M post, up to 5 channels), but DCS needs one in the group: the 5N62 depends on it (or RLS_19J6 / P-19)" },
    },
    essential = { "TR", "LN" },
    approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/S-200_(missile)  (fire channel: one 5N62 + six launchers; VE 240-255 km, min 17 km)",
      "https://ausairpower.net/APA-S-200VE-Vega-Sites.html  (site layout: K-1/K-2/K-3, 6 launchers, 12 loaders)",
      "https://itc.ua/en/articles/s-200-sam-could-a-60-year-old-weapon-shoot-down-an-a-50/amp/  (K-9M controls up to 5 channels; 190 km vs fighter-bombers, 300 km vs large aircraft)",
    },
  },

  ["SA-6"] = {
    name = "SA-6 Gainful (2K12 Kub) battery", era = "Late Cold War",
    nations = { "USSR", "Syria", "Egypt", "Iraq", "Yugoslavia", "Libya" },
    units = {
      { role = "STR", type = "Kub 1S91 str",  count = 1, note = "Straight Flush search/track/illuminate" },
      { role = "LN",  type = "Kub 2P25 ln",   count = 4, reduced = 2, missiles = 3, ring = 200, note = "2P25 TELs" },
      { role = "SR",  type = "p-19 s-125 sr", count = { 0, 1 }, reduced = 0, spacing = 2000, note = "regiment acquisition (P-15/P-19 + PRV-16; 1S12 Long Track absent from DCS): normally a separate EW group" },
      { role = "AUX", type = "ATZ-10",        count = { 0, 2 }, reduced = 0, note = "reload/fuel trucks, cosmetic" },
    },
    essential = { "STR", "LN" },
    approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/2K12_Kub  (battery: 1 1S91 + 4 2P25; 4-24 km; illumination from 28 km)",
      "https://www.ausairpower.net/APA-Legacy-SAM-TEL-TL.html  (regiment: P-12/18 or P-15, PRV-16, 1S12; 5 batteries)",
      "https://www.globalsecurity.org/military/world/russia/sa-6-ops.htm  (one illuminator: no second engagement until the first missile arrives)",
    },
  },

  ["SA-8"] = {
    name = "SA-8 Gecko (9K33 Osa) battery", era = "Mid Cold War",
    nations = { "USSR", "Syria", "Iraq", "Libya", "Algeria" },
    units = {
      { role = "SHORAD", type = "Osa 9A33 ln",   count = 4, reduced = 2, missiles = 6, spacing = 300, note = "self-contained TELARs" },
      { role = "SR",     type = "Dog Ear radar", count = { 0, 1 }, reduced = 0, note = "stand-in for the PU-12 / Ranzhir battery command post (PPRU-1 serves gun/Strela batteries, not Osa)" },
    },
    essential = { "SHORAD" },
    approx = true,
    sources = { "https://en.wikipedia.org/wiki/9K33_Osa  (battery of four TELARs; Osa-AK 1.5-10 km)", "https://en.wikipedia.org/wiki/PPRU-1  (PPRU-1 belongs to the regimental AD battery)" },
  },

  ["SA-9"] = {
    name = "SA-9 Gaskin (9K31 Strela-1) platoon", era = "Mid Cold War", nations = { "USSR", "Syria", "Egypt" },
    units = {
      { role = "SHORAD", type = "Strela-1 9P31",  count = 4, reduced = 2, missiles = 4, spacing = 200, note = "passive (Flat Box warning): no radar to manage" },
      { role = "SR",     type = "Dog Ear radar",  count = { 0, 1 } },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/9K31_Strela-1", "https://man.fas.org/dod-101/sys/land/row/avoac-opfor-sh.htm  (regimental AD battery: 4 ZSU-23-4 + 4 SA-9/13)" },
  },

  ["SA-13"] = {
    name = "SA-13 Gopher (9K35 Strela-10) platoon", era = "Late Cold War", nations = { "USSR", "Russia", "Syria" },
    units = {
      { role = "SHORAD", type = "Strela-10M3",    count = { 4, 6 }, reduced = 2, missiles = 4, spacing = 200, note = "4 in a Cold War platoon, 6 in the later AD battalion's battery" },
      { role = "SR",     type = "Dog Ear radar",  count = { 0, 1 } },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/9K35_Strela-10", "https://man.fas.org/dod-101/sys/land/row/avoac-opfor-sh.htm  (4 per platoon; 6 2S6 + 6 SA-13 in the later regimental AD battalion)" },
  },

  ["SA-10"] = {
    name = "SA-10 Grumble (S-300PS) battalion", era = "Late Cold War",
    nations = { "USSR", "Russia", "Ukraine", "Syria", "Iran", "China" },
    units = {
      { role = "C2", type = "S-300PS 54K6 cp",        count = 1, note = "DCS needs it (the 40B6M depends on it): stands in for the battalion's 5N63S command cabin; the real 54K6 / 83M6 is regiment-level (SA-10-REGIMENT)" },
      { role = "TR", type = "S-300PS 40B6M tr",        count = 1, note = "30N6 Flap Lid on 40V6M mast (or 5H63C 30H6_tr truck-mounted)" },
      { role = "SR", type = "S-300PS 40B6MD sr",       count = 1, note = "76N6 / 5N66M Clam Shell low-altitude detector, battalion-level; DCS needs one search radar (the 54K6 depends on it). 40B6MD sr_19J6 Tin Shield for a battalion acting alone" },
      { role = "LN", type = "S-300PS 5P85C ln",        count = 4, reduced = 2, missiles = 4, ring = 250, note = "5P85S master TELs: one per launch group of 1 S + 2 D" },
      { role = "LN", type = "S-300PS 5P85D ln",        count = 8, reduced = 4, missiles = 4, ring = 350, note = "5P85D slave TELs (fire only through their 5P85S)" },
      { role = "POWER", type = "generator_5i57",       count = { 0, 2 } },
    },
    essential = { "TR", "LN" },
    approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/S-300_missile_system  (12 TELs per 83M6E; the '4 TELs' line is Iran's export S-300PMU2 batteries)",
      "https://dic.academic.ru/dic.nsf/ruwiki/1132644  (divizion: 5N63S + up to 4 launch groups of 5P85S + 2 5P85D; 5V55R 75 km; 6 targets x 2 missiles)",
      "https://militarnyi.com/uk/articles/zrk-s-300/  (up to 4 launch complexes per divizion; 25 m - 27 km)",
      "https://nuke.fas.org/guide/russia/airdef/s-300pmu.htm  (low-level reach: 32 km, 43 km with the mast)",
      "https://www.ausairpower.net/APA-Grumble-Gargoyle.html  (Western 'battery' = Russian divizion; 40V6M mast)",
    },
  },

  ["SA-10-REGIMENT"] = {
    name = "SA-10 Grumble (S-300PS) regiment command and search", era = "Late Cold War",
    nations = { "USSR", "Russia", "Ukraine" },
    units = {
      { role = "C2", type = "S-300PS 54K6 cp",  count = 1, note = "83M6 command system (54K6 / 5K56 battle-control post): controls up to 6 battalions" },
      { role = "SR", type = "S-300PS 64H6E sr", count = 1, spacing = 500, note = "64N6 Big Bird, one per regiment" },
      { role = "POWER", type = "generator_5i57", count = { 0, 1 } },
    },
    essential = { "SR" },
    approx = true,
    sources = {
      "https://dic.academic.ru/dic.nsf/ruwiki/1132644  (5N83S command post = 5N64S Big Bird + 5K56S; up to 6 battalions)",
      "https://origin.armedconflicts.com/topic/view/174212  (S-300PS regiment organisation)",
    },
  },

  ["SA-11"] = {
    name = "SA-11 Gadfly (9K37 Buk-M1) battalion", era = "Late Cold War",
    nations = { "USSR", "Russia", "Ukraine", "Syria", "Georgia" },
    units = {
      { role = "C2",    type = "SA-11 Buk CC 9S470M1",  count = 1, note = "9S470M1 command post" },
      { role = "SR",    type = "SA-11 Buk SR 9S18M1",   count = 1, spacing = 300, note = "Snow Drift" },
      { role = "TELAR", type = "SA-11 Buk LN 9A310M1",  count = 6, reduced = 4, missiles = 4, spacing = 250, note = "3 batteries of 2 TELAR (+ a 9A39 loader-launcher, absent from DCS); each TELAR has its own Fire Dome and can fight alone" },
    },
    essential = { "TELAR" },
    approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/Buk_missile_system",
      "https://dic.academic.ru/dic.nsf/ruwiki/1286330  (battalion: 9S470 + 9S18 + 3 batteries of 2 9A310 + 1 9A39; brigade of 4 battalions)",
      "https://www.ausairpower.net/APA-9K37-Buk.html  (Buk-M1 3-35 km vs aircraft; DCS's 50 km is a later figure)",
    },
  },

  ["SA-15"] = {
    name = "SA-15 Gauntlet (9K330 Tor) battery", era = "Late Cold War", nations = { "USSR", "Russia", "China", "Iran" },
    units = {
      { role = "SHORAD", type = "Tor 9A331",     count = 4, reduced = 2, missiles = 8, spacing = 300, note = "self-contained; used by Janus as point defence. Tor-M1: 2 targets, 2 missiles each, 1.5-12 km" },
      { role = "SR",     type = "Dog Ear radar", count = { 0, 1 }, reduced = 0, note = "battery command post stand-in (Ranzhir absent from DCS)" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Tor_missile_system  (battery of four TLARs)" },
  },

  ["SA-19"] = {
    name = "SA-19 Grison (2K22 Tunguska) battery", era = "Late Cold War", nations = { "USSR", "Russia" },
    units = {
      { role = "SHORAD", type = "2S6 Tunguska", count = 6, reduced = 4, missiles = 8, spacing = 300, note = "missiles 1.5-8 km (M1: 10 km), guns to 4 km" },
      { role = "SR",     type = "Dog Ear radar", count = { 0, 1 }, reduced = 0, note = "PPRU-1 regimental AD command post" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/2K22_Tunguska  (battery of 6; PPRU-1 cueing)", "https://man.fas.org/dod-101/sys/land/row/avoac-opfor-sh.htm" },
  },

  ["TOR-M2"] = {
    name = "SA-15 Gauntlet (Tor-M2) battery", era = "Modern", nations = { "Russia", "Belarus" },
    units = {
      { role = "SHORAD", type = "CHAP_TorM2", count = 4, reduced = 2, missiles = 16, spacing = 300, note = "Currenthill pack unit (free, in CoreMods); 4 targets, 16 km" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Tor_missile_system#Tor-M2" },
  },

  ["PANTSIR"] = {
    name = "SA-22 Greyhound (Pantsir-S1) battery", era = "Modern", nations = { "Russia", "Syria" },
    units = {
      { role = "SHORAD", type = "CHAP_PantsirS1", count = 6, reduced = 3, missiles = 12, spacing = 300, note = "Currenthill pack unit (free, in CoreMods); battery size uncertain (6, or 3 per half-battery); 2-3 cover one S-300/S-400 battalion" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Pantsir_missile_system  (6 per battery; 2 targets per vehicle; to 20 km)", "https://russiandefpolicy.com/tag/pantsir-s/  (two-battery unit of six vehicles: conflicting)" },
  },

  -- ===================================================================== NATO / US
  ["IRIS-T-SLM"] = {
    name = "IRIS-T SLM fire unit", era = "Modern", nations = { "Germany", "Ukraine", "Egypt", "Sweden" },
    units = {
      { role = "C2",  type = "CHAP_IRISTSLM_CP",  count = 1, note = "tactical operations centre; Currenthill pack (free, in CoreMods)" },
      { role = "STR", type = "CHAP_IRISTSLM_STR", count = 1, note = "TRML-4D radar" },
      { role = "LN",  type = "CHAP_IRISTSLM_LN",  count = 3, reduced = 2, missiles = 8, ring = 400 },
    },
    essential = { "STR", "LN" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/IRIS-T_SLM  (fire unit: TOC, TRML-4D, 3 launchers x 8 missiles)" },
  },

  ["PATRIOT"] = {
    name = "MIM-104 Patriot battery", era = "Late Cold War / Modern",
    nations = { "USA", "Germany", "Netherlands", "Israel", "Saudi Arabia", "Japan", "Poland" },
    units = {
      { role = "STR",   type = "Patriot str",  count = 1, note = "AN/MPQ-53/65 radar set" },
      { role = "C2",    type = "Patriot ECS",  count = 1, note = "Engagement Control Station" },
      { role = "C2",    type = "Patriot EPP",  count = 1, note = "Electric Power Plant (Janus treats it as the battery's POWER node)" },
      { role = "C2",    type = "Patriot AMG",  count = 1, reduced = 0, note = "Antenna Mast Group (comms relay)" },
      { role = "C2",    type = "Patriot cp",   count = { 0, 1 }, reduced = 0, note = "ICC, battalion-level; one per 3-6 batteries" },
      { role = "LN",    type = "Patriot ln",   count = 8, reduced = 4, missiles = 4, ring = 300, note = "M901 launching stations, PAC-2 (4 per launcher); FM 44-85: 8 per fire unit (Wikipedia: nominally 6)" },
    },
    essential = { "STR", "LN" },
    approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/MIM-104_Patriot  (battery: radar set, ECS, EPP, AMG, up to 8 launchers; ICC at battalion)",
      "https://www.globalsecurity.org/space/library/policy/army/fm/44-85/Appb.htm  (FM 44-85: fire unit ECS, AMG, RS, EPP, 8 launching stations; ICC at battalion)",
    },
  },

  ["HAWK"] = {
    name = "MIM-23 I-Hawk (Phase III) battery", era = "Late Cold War",
    nations = { "USA", "Germany", "Israel", "Iran", "Spain", "Greece", "Turkey", "Taiwan", "Japan" },
    units = {
      { role = "C2", type = "Hawk pcp",  count = 1, note = "Platoon Command Post (DCS needs it: the HPIR depends on it)" },
      { role = "SR", type = "Hawk sr",   count = 1, reduced = 0, note = "AN/MPQ-50 PAR pulse acquisition radar" },
      { role = "SR", type = "Hawk cwar", count = 1, spacing = 100, note = "AN/MPQ-55 CWAR low-altitude acquisition" },
      { role = "TR", type = "Hawk tr",   count = 2, reduced = 1, spacing = 150, note = "AN/MPQ-46 HPIR illuminators, one per firing section" },
      { role = "LN", type = "Hawk ln",   count = 6, reduced = 3, missiles = 3, ring = 120, note = "M192 launchers, 3 missiles each; 3 per HPIR. Reduced = assault fire unit (CWAR + HPIR + 3 LN)" },
    },
    essential = { "TR", "LN" },
    approx = true,
    sources = { "https://en.wikipedia.org/wiki/MIM-23_Hawk  (I-Hawk battery: PCP, PAR, CWAR, 2 HPIR, 6 launchers)" },
  },

  ["NASAMS"] = {
    name = "NASAMS fire unit", era = "Modern",
    nations = { "Norway", "USA", "Netherlands", "Finland", "Spain", "Ukraine" },
    units = {
      { role = "C2", type = "NASAMS_Command_Post",  count = 1, note = "Fire Distribution Center" },
      { role = "SR", type = "NASAMS_Radar_MPQ64F1", count = 1, note = "AN/MPQ-64F1 Sentinel" },
      { role = "LN", type = "NASAMS_LN_C",          count = 3, reduced = 2, missiles = 6, ring = 400, note = "AIM-120C canisters; NASAMS_LN_B (AIM-120B) is the same launcher for older fire units" },
    },
    essential = { "C2", "SR", "LN" },
    approx = true,
    sources = { "https://en.wikipedia.org/wiki/NASAMS  (fire unit: 1 FDC, 1 Sentinel, 3 launchers x 6 missiles; battery = 3 fire units)" },
  },

  ["RAPIER"] = {
    name = "Rapier FSA troop", era = "Late Cold War", nations = { "UK", "Iran", "Turkey", "Oman" },
    units = {
      { role = "SHORAD", type = "rapier_fsa_launcher",             count = 4, reduced = 1, missiles = 4, spacing = 600, note = "troop of 4 fire units; reduced = one fire unit" },
      { role = "SR",     type = "rapier_fsa_optical_tracker_unit", count = 4, reduced = 1, spacing = 600 },
      { role = "TR",     type = "rapier_fsa_blindfire_radar",      count = { 0, 2 }, reduced = 0, spacing = 600, note = "Blindfire DN181: only about a third of British fire units had one" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Rapier_(missile)  (troop of 4 fire units, battery of 3 troops; ~1/3 with Blindfire; 0.4-8.2 km)" },
  },

  ["ROLAND"] = {
    name = "Roland battery", era = "Late Cold War", nations = { "Germany", "France", "USA", "Iraq" },
    units = {
      { role = "SHORAD", type = "Roland ADS",   count = 6, reduced = 3, missiles = 8, spacing = 300, note = "each fire unit has its own 15-18 km search radar; Luftwaffe batteries had 8" },
      { role = "SR",     type = "Roland Radar", count = { 0, 1 }, reduced = 0, note = "battery search radar (TRML-2D in Luftwaffe batteries)" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Roland_(missile)" },
  },

  ["HQ-7"] = {
    name = "HQ-7B (FM-90) battery", era = "Modern", nations = { "China", "Pakistan", "Iran" },
    units = {
      { role = "C2",     type = "HQ-7_STR_SP", count = 1, note = "search unit; acts as C2 and search radar (25 km)" },
      { role = "SHORAD", type = "HQ-7_LN_SP",  count = 3, reduced = 2, missiles = 4, ring = 300, note = "each launch unit carries its own tracking radar; 0.7-12 km vs aircraft. HQ-7_LN_P is the Combined Arms player copy, not a towed variant" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/HQ-7  (battery: 1 search unit + 3 launch units)", "https://ausairpower.net/APA-HQ-7-Crotale.html  (0.7-12 km vs aircraft, 15 km vs helicopters, 30-6000 m)" },
  },

  ["AVENGER"] = {
    name = "Avenger platoon", era = "Modern", nations = { "USA" },
    units = {
      { role = "SHORAD", type = "M1097 Avenger", count = 6, reduced = 2, missiles = 8, spacing = 300, note = "platoon HQ + 3 sections of 2" },
      { role = "SR",     type = "NASAMS_Radar_MPQ64F1", count = { 0, 1 }, reduced = 0, note = "Sentinel radar cueing, as in a US SHORAD battery" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/AN/TWQ-1_Avenger", "https://www.globalsecurity.org/military/agency/army/platoon.htm  (Avenger platoon: 3 sections of 2)" },
  },

  ["LINEBACKER"] = {
    name = "M6 Linebacker (Bradley Stinger) platoon", era = "Late Cold War / Modern", nations = { "USA" },
    units = {
      { role = "SHORAD", type = "M6 Linebacker", count = 4, reduced = 2, missiles = 4, spacing = 300, note = "4 ready Stingers + 6 reloads; heavy-division ADA; platoon size not sourced" },
      { role = "SR",     type = "NASAMS_Radar_MPQ64F1", count = { 0, 1 }, reduced = 0, note = "Sentinel / FAAD C2 slew-to-cue" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://www.army-technology.com/projects/linebacker/", "https://man.fas.org/dod-101/sys/land/m6.htm  (FAAD C2 and Sentinel cueing)" },
  },

  ["CHAPARRAL"] = {
    name = "Chaparral platoon", era = "Mid Cold War", nations = { "USA", "Israel", "Taiwan" },
    units = {
      { role = "SHORAD", type = "M48 Chaparral", count = 4, reduced = 2, missiles = 4, spacing = 300, note = "visual/IR detection, FAAR radar alerting; Vulcans were separate batteries of the same battalion: co-site AAA-VULCAN" },
    },
    essential = { "SHORAD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/MIM-72_Chaparral" },
  },

  ["C-RAM"] = {
    name = "C-RAM LPWS section", era = "Modern", nations = { "USA", "UK" },
    units = {
      { role = "CRAM", type = "HEMTT_C-RAM_Phalanx", count = { 2, 4 }, spacing = 400, note = "Land-based Phalanx Weapon System around the protected base; the DCS unit has its own radar. In DCS its engagement of rockets/missiles/bombs is measured by the Phase 0 probe mission" },
    },
    essential = { "CRAM" }, approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/Counter_Rocket,_Artillery,_and_Mortar  (LPWS deployed in sections of several mounts around a base)",
      "https://en.wikipedia.org/wiki/Phalanx_CIWS#Land-based_variant",
    },
  },

  -- ===================================================================== AAA (Vietnam and general)
  ["AAA-100MM"] = {
    name = "KS-19 100 mm battery with Fire Can", era = "Early Cold War", nations = { "USSR", "Vietnam", "China", "Egypt" },
    units = {
      { role = "AAA",    type = "KS-19", count = 6, reduced = 4, ring = 60, note = "6 guns (guns per battery not firmly sourced; one SON-9 directs 4-8); effective 12 km slant / 11 km ceiling with radar" },
      { role = "AAA_FC", type = "SON_9", count = 1, note = "SON-9 Fire Can gun-laying radar (ARM-targetable); DCS needs it (the KS-19 depends on it). Cued by EW under Soviet doctrine, tracks to ~35 km" },
    },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/KS-19  (batteries of 6 guns with SON-9 / PUAZO director)", "https://man.fas.org/dod-101/sys/land/row/ks-19.htm  (12.6 km slant with radar, 4 km on-carriage sights; SON-9 tracks 35 km)", "https://www.allworldwars.com/Tactics-and-Techniques-of-Electronic-Warfare-by-Bernard-Nalty.html  (Fire Can on-air time cut to under 3 min)" },
  },

  ["AAA-57MM"] = {
    name = "S-60 57 mm battery with Fire Can", era = "Early Cold War", nations = { "USSR", "Vietnam", "China", "Syria", "Egypt" },
    units = {
      { role = "AAA",    type = "S-60_Type59_Artillery", count = 6, reduced = 4, ring = 50, note = "6 km with radar, 4 km optical; ceiling 5 km; Vietnam batteries opened fire at 4-6 km" },
      { role = "AAA_FC", type = "SON_9", count = 1, note = "DCS needs it (the S-60 depends on it); Flap Wheel in later batteries" },
    },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/AZP_S-60  (battery: 6 guns + SON-9 radar + PUAZO-6 director)", "https://www.globalsecurity.org/military/world/russia/s-60.htm  (6 km radar / 4 km optical; PVO regiment 4 x 6)", "https://historynet.com/north-vietnams-light-anti-aircraft-artillery/" },
  },

  ["AAA-ZU23"] = {
    name = "ZU-23 light AAA section", era = "Mid Cold War", nations = { "USSR", "Vietnam", "Syria", "Iraq" },
    units = {
      { role = "AAA", type = "ZU-23 Emplacement", count = 4, reduced = 2, spacing = 80, note = "platoon of 4 (2 per battery); airborne batteries of 6; effective 2 km, 1.5 km ceiling" },
    },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/ZU-23-2", "https://man.fas.org/dod-101/sys/land/row/avoac-opfor-sh.htm  (platoons of 4)", "https://gulflink.health.mil/irfna/irfna_refs/n28en143/airdef.html  (2.5 km effective)" },
  },

  ["AAA-SHILKA"] = {
    name = "ZSU-23-4 Shilka platoon", era = "Mid Cold War", nations = { "USSR", "Syria", "Egypt", "Iraq" },
    units = { { role = "AAA", type = "ZSU-23-4 Shilka", count = 4, reduced = 2, spacing = 200, note = "radar-directed; Gun Dish is ARM-targetable; 2.5 km, ceiling 1.5-2 km; 2 per first-echelon battalion in the attack" } },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/ZSU-23-4_Shilka" },
  },

  ["AAA-GEPARD"] = {
    name = "Gepard battery", era = "Late Cold War", nations = { "Germany", "Netherlands", "Belgium" },
    units = { { role = "AAA", type = "Gepard", count = { 6, 7 }, reduced = 3, spacing = 200, note = "battery of 6 (1980s) or 7 (1A2 era); own 15 km search radar" } },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Flakpanzer_Gepard" },
  },

  ["AAA-VULCAN"] = {
    name = "M163 Vulcan platoon", era = "Mid Cold War", nations = { "USA", "Israel" },
    units = { { role = "AAA", type = "Vulcan", count = 4, reduced = 2, spacing = 200, note = "range-only radar, cued visually or by FAAR; 1.2-2.5 km" } },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/M163_VADS" },
  },

  -- ===================================================================== WWII (DCS: WWII Assets Pack DLC)
  ["FLAK-88"] = {
    name = "Heavy Flak battery, 8.8 cm Flak 18/36/37 (WWII)", era = "WWII", nations = { "Germany" },
    requires = { "WWII Assets Pack" },
    units = {
      { role = "AAA",    type = "flak18",              count = { 4, 6 }, reduced = 4, ring = 60, note = "4-gun heavy battery, 6 from 1942 (flak36 / flak37 the same gun; flak41 for late-war Reich defence); ~8 km effective ceiling" },
      { role = "AAA_FC", type = "KDO_Mod40",           count = 1, note = "Kommandogerät 40 director about 270 m from the guns; DCS needs it (the 8.8 cm guns depend on it)" },
      { role = "AAA",    type = "flak30",              count = { 0, 2 }, reduced = 0, spacing = 80, note = "2 cm light guns for close defence of the battery" },
      { role = "AAA",    type = "Flakscheinwerfer_37", count = { 0, 3 }, reduced = 0, ring = 2000, note = "searchlights for night defence, sited 1.5-2.5 km out; separate searchlight units of 9-12 in practice" },
      { role = "POWER",  type = "Maschinensatz_33",    count = { 0, 1 } },
    },
    essential = { "AAA" }, approx = true,
    sources = {
      "https://en.wikipedia.org/wiki/8.8_cm_Flak_18/36/37/41  (batteries of 4-6 guns with a Kommandogerät director; 8 km effective ceiling)",
      "https://lonesentry.com/articles/ttt07/heavy-aa-battery.html  (German heavy battery: 4 or 6 guns + 2 light guns)",
      "https://en.wikipedia.org/wiki/German_searchlights_of_World_War_II",
    },
  },

  ["FLAK-LIGHT"] = {
    name = "Light Flak battery, 2 cm Flak 38 / Flakvierling 38 (WWII)", era = "WWII", nations = { "Germany" },
    requires = { "WWII Assets Pack" },
    units = {
      { role = "AAA", type = "flak38", count = { 3, 6 }, reduced = 3, spacing = 60, note = "Flakvierling 38 (four-barrel 2 cm); 2.2 km effective vertical" },
      { role = "AAA", type = "flak30", count = { 0, 6 }, reduced = 0, spacing = 60, note = "single 2 cm Flak (DCS name 'Flak 38 20mm'); battery of 12 in 4 platoons of 3. DCS has no 3.7 cm Flak (flak36 is the 8.8 cm)" },
    },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/2_cm_Flak_30/38/Flakvierling" },
  },

  ["HAA-UK-37IN"] = {
    name = "British heavy AA battery, QF 3.7 inch (WWII)", era = "WWII", nations = { "UK" },
    requires = { "WWII Assets Pack" },
    units = {
      { role = "AAA",    type = "QF_37_AA",        count = 8, reduced = 4, ring = 80, note = "2 troops of 4 guns; effective ceiling 7.2-7.7 km (9.8 km with the late No.11 predictor)" },
      { role = "AAA_FC", type = "Allies_Director", count = 2, reduced = 1, spacing = 300, note = "one predictor + GL radar per troop; DCS needs it (the 3.7 inch depends on it)" },
      { role = "AAA",    type = "bofors40",        count = { 0, 2 }, reduced = 0, spacing = 150, note = "light guns for close defence" },
    },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/QF_3.7-inch_AA_gun", "https://ra39-45.co.uk/organisation/heavy-anti-aircraft-organisation/heavy-anti-aircraft-battery  (battery of 2 troops of 4 guns)" },
  },

  ["JP-HEAVY"] = {
    name = "Japanese heavy AA battery, Type 88 75 mm (WWII)", era = "WWII", nations = { "Japan" },
    units = {
      { role = "AAA", type = "Type_88_75mm_AA", count = 4, reduced = 2, spacing = 30, note = "4 guns in a rectangle 15-35 m apart (Type_3_80mm_AA for island / navy garrisons); ~7 km effective; no director or radar unit in DCS" },
      { role = "AAA", type = "Type_96_25mm_AA", count = 2, reduced = 1, spacing = 120, note = "light guns for close defence" },
    },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Type_88_75_mm_AA_gun", "https://lonesentry.com/manuals/handbook-japanese-military/japanese-antiaircraft.html  (12-gun battalion: 4 per battery; batteries of 2 to 12 reported)", "https://m.lonesentry.com/manuals/handbook-japanese-military/antiaircraft-tactics.html  (all guns on the lead aircraft)" },
  },

  ["JP-LIGHT"] = {
    name = "Japanese light AA, Type 96 25 mm (WWII)", era = "WWII", nations = { "Japan" },
    units = {
      { role = "AAA", type = "Type_96_25mm_AA",       count = { 4, 6 }, reduced = 2, spacing = 100, note = "around an airstrip; fire beyond 2 km was 'completely ineffective'" },
      { role = "AAA", type = "Type_94_25mm_AA_Truck", count = { 0, 2 }, reduced = 0, spacing = 150 },
    },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Type_96_25_mm_AT/AA_gun", "https://lonesentry.com/articles/ttt/japanese_aa_regiment-flak.html" },
  },

  ["AAA-US-WWII"] = {
    name = "US automatic-weapons AAA platoon (WWII)", era = "WWII", nations = { "USA", "UK" },
    requires = { "WWII Assets Pack" },
    units = {
      { role = "AAA", type = "M45_Quadmount", count = 3, reduced = 2, spacing = 60, note = "M45 quad .50 cal: one per fire unit (effective 500-800 yd)" },
      { role = "AAA", type = "bofors40",      count = { 0, 3 }, reduced = 0, spacing = 80, note = "Bofors 40 mm with director: one per fire unit (core unit)" },
      { role = "AAA", type = "M1_37mm",       count = { 0, 3 }, reduced = 2, spacing = 80, note = "early-war alternative to the Bofors" },
    },
    essential = { "AAA" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/M45_Quadmount", "https://ibiblio.org/hyperwar/USA/ref/FM/PDFs/FM44-2.PDF  (FM 44-2: fire unit = 40 mm + director + quad .50; battery of 8 fire units in platoons of 3, 3, 2)" },
  },

  ["EW-WWII-GERMAN"] = {
    name = "German radar site, Freya + Würzburg (WWII)", era = "WWII", nations = { "Germany" },
    requires = { "WWII Assets Pack" },
    units = {
      { role = "EWR", type = "FuMG-401", count = 1, note = "Freya LZ early warning" },
      { role = "EWR", type = "FuSe-65",  count = 2, reduced = 1, spacing = 200, note = "Würzburg-Riese: one tracks the fighter, one the bomber (Himmelbett box)" },
      { role = "POWER", type = "Maschinensatz_33", count = { 0, 1 } },
    },
    essential = { "EWR" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Freya_radar", "https://en.wikipedia.org/wiki/W%C3%BCrzburg_radar" },
  },

  -- ===================================================================== Early warning / C2 nodes
  ["EW-SOVIET"] = {
    name = "Soviet radiotechnical post", era = "Late Cold War", nations = { "USSR", "Russia" },
    units = {
      { role = "EWR", type = "55G6 EWR", count = 1, note = "Tall Rack, or 1L13 Box Spring" },
      { role = "C2_GENERIC", type = "SKP-11", count = { 0, 1 } },
      { role = "POWER", type = "generator_5i57", count = { 0, 1 } },
    },
    essential = { "EWR" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Soviet_Air_Defence_Forces" },
  },

  ["EW-NATO"] = {
    name = "NATO long-range radar site", era = "Late Cold War / Modern", nations = { "USA", "NATO" },
    units = {
      { role = "EWR", type = "FPS-117", count = 1, note = "AN/FPS-117 (Dome variant for fixed sites)" },
      { role = "EWR", type = "FPS-117 ECS", count = { 0, 1 }, note = "ECS shelter" },
    },
    essential = { "EWR" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/AN/FPS-117" },
  },

  -- ===================================================================== Naval (per the StonewallC carrier standard)
  ["CSG-USN"] = {
    name = "US Navy carrier strike group escort", era = "Modern", nations = { "USA" },
    units = {
      { role = "NAVAL_AD", type = "CVN_73",               count = 1, note = "any Supercarrier hull: CVN_71/72/73/75" },
      { role = "NAVAL_AD", type = "TICONDEROG",           count = 1, spacing = 3000, note = "Ticonderoga CG, air-defence commander" },
      { role = "NAVAL_AD", type = "USS_Arleigh_Burke_IIa", count = 2, spacing = 3000 },
      { role = "NAVAL_AD", type = "PERRY",                count = 1, spacing = 1500, note = "plane guard" },
    },
    essential = { "NAVAL_AD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Carrier_strike_group  (typical CSG: 1 CG, 2-3 DDG/FFG)" },
  },

  ["SAG-RU"] = {
    name = "Russian surface action group", era = "Modern", nations = { "Russia" },
    units = {
      { role = "NAVAL_AD", type = "MOSCOW",     count = 1, note = "Slava-class cruiser, SA-N-6" },
      { role = "NAVAL_AD", type = "NEUSTRASH",  count = 1, spacing = 3000 },
      { role = "NAVAL_AD", type = "REZKY",      count = 1, spacing = 3000 },
      { role = "NAVAL_AD", type = "MOLNIYA",    count = 2, spacing = 2000 },
    },
    essential = { "NAVAL_AD" }, approx = true,
    sources = { "https://en.wikipedia.org/wiki/Slava-class_cruiser" },
  },
}
