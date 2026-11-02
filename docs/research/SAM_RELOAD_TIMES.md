# SAM Battery Reload Data (research note)

Compiled 2026-11-02 for Janus resupply / `JANUS.wta.rearm` timing.

Confidence levels:
- **H**: official or manufacturer source, or several references that agree.
- **M**: reference sites (GlobalSecurity, FAS, Wikipedia) that agree with each other.
- **L**: a single secondary source, a forum, or general knowledge with no citation found. Treat L figures as tuning defaults, not facts.

## Summary table

| System | Launcher, missiles | Reload method / vehicle | Time per launcher | Crew | Conf. | Sources |
|---|---|---|---|---|---|---|
| SA-2 S-75 | SM-63-type single rail, 1 | PR-11 semi-trailer transloader (1 msl each), ~6 per battery. Missiles are fuelled at the technical battalion | 12-15 min (forum). DCS community: ~45 min including prep. Full battery: 1 h or more | ~3-4 (L) | L | [1][2] |
| SA-3 S-125 | 5P73 quad (or 5P71 twin), 4 (2) | PR-14 series transloader (2 msl), ZiL-131 or Ural chassis. Rail-to-rail transfer, no crane | ~50 min per quad launcher (FAS, Armsnet). One unsourced forum claim: ~1 min per rail pair | ~4 (L) | M (50 min) | [3][4][5][6] |
| SA-5 S-200 | 5P72 single rail, 1 | Fixed site: 5Ju24 rail trolleys fed from the 5T83 loading vehicle | No figure found | n/a | none | n/a |
| SA-6 2K12 Kub | 2P25 SPU, 3 | 2T7 transloader (ZiL-131, crane, 3 msl), 2 per battery | ~10 min | ~3 (L) | M | [7][8][9] |
| SA-8 9K33 Osa | 9A33 TELAR, 4 (Osa-AK: 6 in TLCs) | 9T217 transloader (BAZ-5939, crane), 2 per battery | ~5 min | ~3 (L) | M | [10] |
| SA-9 Strela-1 | 9P31 BRDM-2, 4 canisters | Manual reload by crew | A few minutes (no source found) | 3 | L | n/a |
| SA-10 S-300PS | 5P85S/D TEL, 4 TPK canisters | 5T99 transloader with crane, canister swap | No reliable figure. Deploy time is 5 min. A "~30 min" reload is often quoted but unsourced | ~3-4 (L) | L | [11] |
| SA-11 9K37 Buk | 9A310 TELAR, 4. 9A39 TEL, 4 ready + 4 reloads | 9A39 crane transfers missiles to the TELAR. The 9A39 reloads itself from stores | 5-13 min: ~13 min TELAR from 9A39 (Wikipedia), 5 min (GlobalSecurity). 9A39 self-reload ~15 min | ~3-4 (L) | M | [12][13][14] |
| SA-13 Strela-10 | 9A35/9A34 on MT-LB, 4 ready + 4 stowed | Manual by crew from internal stowage | ~3 min | 3 | L | n/a |
| SA-15 Tor | 9A330/9A331, 8 in two TPK modules | 9T244/9T245 transloader with crane, module swap | ~10 min (GlobalSecurity, M1 generation) | ~3 (L) | M | [15] |
| SA-19 2K22 Tunguska | 2S6, 8 msl + 1,904 rnds 30 mm | 2F77 transloader truck | ~16 min for guns and missiles (2S6M) | 4 | M | [16] |
| MIM-23 Hawk | M192 towed, 3 | M501 loader (tracked forklift-type, 3 msl) | ~5 min (widely quoted, no source located) | 3 (L) | L | n/a |
| MIM-104 Patriot | M901/M903, 4 PAC-2/GEM canisters (more with PAC-3) | HEMTT guided missile transporter with hydraulic crane | Under 45 min typical, ~30 min best. Army minimum standard: 1 h. Certification run: 53 min | 5 | H | [17][18][19] |
| NASAMS | LCHR, 6 AIM-120 | Truck with crane or forklift, canister pods | ~15 min (not located) | ~3 (L) | L | n/a |
| Roland | Vehicle turret, 2 on rails + 8 in internal magazine | Automatic reload from the internal magazine. Magazine restocked by crew | Seconds per rail (automatic). Magazine restock time not found | 3 | L | n/a |
| Rapier | Towed fire unit, 4 | Manual by crew from a Land Rover tender | ~3 min for 4 (L) | 2-3 | L | n/a |
| Avenger | 2 x 4-round Stinger pods | Manual pod swap by crew | ~4-6 min (L) | 2 | L | n/a |
| Chaparral | M54, 4 on rails + 8 stowed | Manual by crew | ~5 min (L) | 5 | L | n/a |

## Per-system notes

- **SA-2:** The V-750 missiles are liquid-fuelled and are fuelled with oxidiser at the regimental technical battalion, then brought forward on PR-11 transloaders. The technical battalion sets the real reload tempo, not the rail transfer. The DCS community figure of ~45 min includes fuelling and transport. A battery has 6 launchers.
- **SA-3:** The 50 min figure (FAS, Armsnet) is per quad launcher. PR-14 transloaders carry 2 missiles each and back up to the rails to load them. A battery of 4 launchers has 16 ready missiles. The "1 min" claim comes from an unsourced DCS forum post.
- **SA-5:** These are fixed sites. Each 5P72 launcher is served by rail trolleys from a loading point. I found no time figure. Suggestion: treat it like the SA-2, with a long reload limited by the depot.
- **SA-6:** A battery is 1S91 + 4 x 2P25 + 2 x 2T7. The two transloaders carry 6 missiles between them, half of the battery's 12 ready rounds per trip. Sources agree on ~10 min to transfer to one launcher.
- **SA-8:** ~5 min using the 9T217 crane. A battery is 4 TELARs + 2 x 9T217.
- **SA-11:** The 9A39 TELs double as reload vehicles. GlobalSecurity's 5 min conflicts with Wikipedia's 13 min.
- **SA-10:** The 5T99 carries replacement canisters and swaps them by crane. I found no reliable time.
- **Patriot:** The best-documented system. A 5-soldier reload crew uses the transporter's crane. Army.mil gives under 45 min as typical and 1 h as the standard. AFCENT reports 53 min for a certification run.
- **SA-9, SA-13, Avenger, Chaparral, Rapier:** Systems that fire MANPADS-class or light missiles; the crew reloads by hand from vehicle or tender stowage. Reloads take minutes. All figures are L.

## Doctrine notes (L unless cited)

- Soviet regiments and brigades hold reloads at the technical battalion or battery, several to tens of km behind the firing batteries. Transloaders shuttle missiles forward, so the number of transloaders limits how fast a battery can reload, not the number of launchers.
- For Janus: requiring an explicit resupply event (`JANUS.wta.rearm`) for a dry battery matches practice, because every system except Roland and the hand-loaded light systems depends on an external reload vehicle.

## Sources

1. DCS forum, S-75 rearming time: https://forum.dcs.world/topic/231503-no-bugs75-sam-sa-2-rearming-time/
2. CombatAce forum, SAM reload times: https://combatace.com/forums/topic/67023-sam-reload-times/
3. FAS, S-125: https://nuke.fas.org/guide/russia/airdef/s-125.htm
4. Armsnet, S-125 entry: https://armsnet.duckdns.org/equipment/f689b32c-5770-4c4c-e5d6-08de6e3c1543
5. Wikipedia, S-125 Neva/Pechora: https://en.wikipedia.org/wiki/S-125_Neva/Pechora
6. Great Russian Encyclopedia, S-125 Neva: https://bigenc.ru/c/s-125-neva-e99696
7. Wikipedia, 2K12 Kub: https://en.wikipedia.org/wiki/2K12_Kub
8. GlobalSecurity, SA-6 specs: https://www.globalsecurity.org/military/world/russia/sa-6-specs.htm
9. Valka/ArmedConflicts, 2K12 Kub: https://www.armedconflicts.com/2K12-Kub-t654
10. Wikipedia, 9K33 Osa: https://en.wikipedia.org/wiki/9K33_Osa
11. Valka/ArmedConflicts, S-300PS: https://origin.armedconflicts.com/topic/view/174212
12. Wikipedia, Buk missile system: https://en.wikipedia.org/wiki/Buk_missile_system
13. GlobalSecurity, SA-11 specs: https://www.globalsecurity.org/military/world/russia/sa-11-specs.htm
14. Kopp, APA 9K37 Buk: https://ausairpower.net/APA-9K37-Buk.html
15. GlobalSecurity, SA-15 specs: https://www.globalsecurity.org/military/world/russia/sa-15-specs.htm
16. GlobalSecurity, 2S6M specs: https://www.globalsecurity.org/military/world/russia/2s6m-specs.htm
17. Army.mil, Patriot reload team: https://www.army.mil/article/212230/teamwork_and_leadership_essential_to_the_success_of_a_patriot_missile_reload_team
18. Army.mil, readiness: https://www.army.mil/article/165246/safety_security_requires_readiness_first
19. AFCENT, Patriot reload crew certification: https://www.afcent.af.mil/News/Article/218380/deployed-patriot-reload-crew-certifiably-ready

Gaps, not consulted in this pass: FM 100-2-3, pvo.guns.ru, vko.ru, Jane's, Military-Today, and manufacturer data for Hawk, NASAMS and Rapier.

## Proposal: modelling the reload delay (for the owner; not built)

Janus Lead, 2026-11-02. The owner's rule stands: Janus has no time rule, and the dry latch clears only on a launch or
`JANUS.wta.rearm`. The delay therefore belongs to the resupply script. Janus only publishes the data and a hook.

1. **Janus ships the table as data, not behaviour.** It adds `JANUS.Reload[type] = { perLauncher = s, vehicle = "...",
   perVehicle = n, conf = "M" }`, keyed like `JANUS.Reach`, with the figures above (midpoint of a range; L rows
   marked). A mission may override it the same way as `REACH`.
2. **The resupply script owns the clock.** When the battery goes dry (subscribe to a new `batteryDry` event; today
   there is only the log line), the script:
   - checks that a reload vehicle is alive within reach of the battery (the transloader, TZM or HEMTT group, by name
     or tag). If none is, the battery stays dry: that is the realism, and the vehicle is a target worth killing.
   - computes `delay = ceil(launchers / transloaders) x perLauncher`, plus drive time if the vehicles are held back at
     the technical battalion (Soviet doctrine), then reloads the DCS units at `now + delay` and calls
     `JANUS.wta.rearm(site, "resupplied")` **when the delay ends, not when it starts**.
3. **No partial readiness in v1.** The battery stays dry until the whole reload finishes, which slightly overstates the
   delay for multi-launcher batteries. Per-launcher readiness would need Janus to track ammo per launcher rather
   than per battery; that is a later card if the owner wants it.
4. **Before any build:** a second, deeper research pass on the L and no-data rows (SA-10 first, as the most used,
   then SA-5, SA-9, Hawk and NASAMS). It should check FM 100-2-3, Kopp/ausairpower and the Russian sources, which
   this pass did not reach.
