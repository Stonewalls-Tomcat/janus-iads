# Janus engagement reach

DCS lists some weapons at their ballistic or best-case range. Examples: KS-19 20 km, S-300PS 120 km (the 48N6 figure, not the PS's 5V55R), Buk-M1 50 km (a Buk-M2 figure). Janus uses the **doctrinal reach** instead: the far boundary of the kill zone against a fighter (owner, 2026-10-17, after the Breakwater review, in which an SA-10 came up on a 96 km cue and its missiles never flew beyond 72 km).

`JANUS.Reach` in `src/janus_doctrine.lua` holds these values per DCS type:

- `hi`: reach against a target 3 km or more above the site.
- `lo`: reach against a target 1 km or less above the site, for the systems whose low-level reach is sourced. Between 1 and 3 km Janus interpolates linearly.
- `ceil`: a gun's effective ceiling.
- `track`: a gun-laying radar's tracking range.

The value used is never larger than the DCS figure.

Where Janus reads it:

| Reader | What it does with the reach |
|---|---|
| The network's engagement range (`node.engageRange`, `node.engageLow`) | Uses it as the site's engagement range. |
| The WTA Pk envelope (`JANUS.wta.envelope`, `pk`) | Gives zero Pk beyond the reach at the target's height. |
| The EMCON ambush ring | A dark cued SAM radar comes up only when an EW plot puts the target inside `ambush` × reach at that target's height. |
| The flak trap and gun ceiling (`JANUS.aaa.reach`) | Uses the gun reach and ceiling. |
| Cued gun radars | A Fire Can comes up when an EW plot is inside `ambush` × its tracking range. That puts it on and tracking before the guns can reach. |

Settings:
- `REACH = false` uses the DCS figures only.
- `REACH = { ["<DCS type>"] = { hi = m, lo = m } }` replaces an entry.
- `["<DCS type>"] = false` removes an entry.

## Table

| DCS type | hi | lo | ceiling / track | DCS figure | Basis |
|---|---|---|---|---|---|
| `S-300PS 5P85C ln`, `5P85D ln` | 75 km | 40 km | | 120 km | 5V55R 75 km ([academic.ru](https://dic.academic.ru/dic.nsf/ruwiki/1132644), [militarnyi](https://militarnyi.com/uk/articles/zrk-s-300/)). Low level: 30N6 horizon 32 km, 43 km on the 40V6M mast ([FAS](https://nuke.fas.org/guide/russia/airdef/s-300pmu.htm)). DCS launches seen at 72 km and below (Breakwater). |
| `S-200_Launcher` | 150 km | 40 km | | 255 km | Against fighters. 240-255 km applies to large aircraft only; S-200D 190 km vs fighter-bombers ([itc.ua](https://itc.ua/en/articles/s-200-sam-could-a-60-year-old-weapon-shoot-down-an-a-50/amp/)). **Approximate.** |
| `S_75M_Volhov` | 35 km | 18 km | | 43 km | V-755 reaches about 30-35 km against fast targets; 43 km only against subsonic ones ([S-75 tech doc](https://ia601805.us.archive.org/34/items/soviet-air-defense-system-technical-documents/sam%20simulator/S-75%20family.pdf), [USAF museum](https://www.nationalmuseum.af.mil/Visit/Museum-Exhibits/Fact-Sheets/Display/Article/196037/)). |
| `5p73 s-125 ln` | 17 km | 10 km | | 18 km | 5V27 6-17 km; 22-25 km against subsonic targets only; low targets to about 10 km ([S-125 tech doc](https://ia601805.us.archive.org/34/items/soviet-air-defense-system-technical-documents/sam%20simulator/S-125%20family.pdf), [pvo.guns.ru](http://pvo.guns.ru/s125/s125.htm)). |
| `Kub 2P25 ln` | 24 km | | | 25 km | 3M9 4-24 km ([Wikipedia](https://en.wikipedia.org/wiki/2K12_Kub)). |
| `SA-11 Buk LN 9A310M1` | 35 km | | | 50 km | Buk-M1 3-35 km ([APA](https://www.ausairpower.net/APA-9K37-Buk.html), [militarnyi](https://militarnyi.com/uk/articles/zrk-buk-m1)). |
| `Osa 9A33 ln` | 10 km | | | 10.3 km | Osa-AK 1.5-10 km ([Wikipedia](https://en.wikipedia.org/wiki/9K33_Osa)). |
| `HQ-7_LN_SP`, `HQ-7_LN_P` | 12 km | | | 15 km | 0.7-12 km vs aircraft; 15 km vs helicopters only ([APA](https://ausairpower.net/APA-HQ-7-Crotale.html)). |
| `KS-19` | 12 km | | ceiling 11 km | 20 km | 12.6 km slant with radar ([FAS](https://man.fas.org/dod-101/sys/land/row/ks-19.htm)); ceiling 39,000 ft ([Nalty](https://www.allworldwars.com/Tactics-and-Techniques-of-Electronic-Warfare-by-Bernard-Nalty.html)). |
| `S-60_Type59_Artillery` | 6 km | | ceiling 5 km | 6 km | 6 km with radar, 4 km optical ([GlobalSecurity](https://www.globalsecurity.org/military/world/russia/s-60.htm)). |
| `ZSU-23-4 Shilka` | 2.5 km | | ceiling 2 km | 2.5 km | ([GlobalSecurity](https://www.globalsecurity.org/military/world/russia/zsu-23-4.htm)). |
| ZU-23 family | 2 km | | ceiling 1.5 km | 2.5 km | 2.5 km effective; Vietnam crews opened fire at about 1 km ([gulflink](https://gulflink.health.mil/irfna/irfna_refs/n28en143/airdef.html), [HistoryNet](https://historynet.com/north-vietnams-light-anti-aircraft-artillery/)). |
| `ZSU_57_2` | 4 km | | ceiling 3 km | 7 km | Optical only; about 4 km effective slant ([gulflink](https://gulflink.health.mil/irfna/irfna_refs/n28en143/airdef.html)). |
| `SON_9` | | | track 35 km | 55 km detection | Fire Can detects at 55-80 km, but its reliable automatic tracking is 35 km ([armedconflicts](https://www.armedconflicts.com/-t37400), [FAS](https://man.fas.org/dod-101/sys/land/row/ks-19.htm)). |
| `flak30`, `flak38` | 2 km | | ceiling 2 km | 2.5 km | Flakvierling 2.2 km effective vertical ([Wikipedia](https://en.wikipedia.org/wiki/2_cm_Flak_30/38/Flakvierling)). |
| `M45_Quadmount` | 0.8 km | | ceiling 0.8 km | 1.5 km | Effective 500-800 yd ([Wikipedia](https://en.wikipedia.org/wiki/M45_Quadmount)). |
| `M1_37mm` | 2 km | | ceiling 1.5 km | 5.7 km | 1.1 km on-carriage sights, 2 km with director ([Wikipedia](https://en.wikipedia.org/wiki/37_mm_gun_M1)). |
| `Type_96_25mm_AA`, `Type_94_25mm_AA_Truck` | 1 km | | ceiling 1 km | 3.5 km | The Japanese judged fire beyond 2 km "completely ineffective" ([Lone Sentry](https://lonesentry.com/manuals/handbook-japanese-military/japanese-antiaircraft.html)). |

Unchanged, because the DCS figure already fits the sources:

- Tor, Tor-M2, Pantsir, Tunguska, Strela-1/10, Patriot, NASAMS, IRIS-T SLM, Rapier, Roland, Avenger/Linebacker, Gepard, Vulcan, C-RAM, Bofors.
- The heavy WWII guns (8.8 cm Flak, QF 3.7 inch, Type 88). DCS lists these *shorter* than their real reach; whether the DCS AI can shoot farther needs a server test.
- The Hawk keeps its DCS-behaviour cap of 25 km (`JANUS.wta.DCS_REACH`): it launches only once its HPIR locks at about 13-15 nm.

Open points:

- The Chaparral: Wikipedia gives 5 km, DCS 8.5 km. The later MIM-72G may reach farther. Not changed.
- SA-2-VIETNAM: DCS has only the Volkhov launcher. The Dvina (V-750) reached about 30 km and cannot be told apart by type.
