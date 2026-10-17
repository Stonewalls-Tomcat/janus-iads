-- Network module: checks for paths the full mutation gate of 2026-10-17 found untested (role tables, tiers,
-- range classes, doctrine fallback, duplicate and late pickup, wrecks, the setup report line).
local F = dofile("tests/fake_dcs.lua")
local JANUS_FILE = arg and arg[1] or "dist/janus.lua"
local BLUE = coalition.side.BLUE

local passed, failed = 0, 0
local function check(cond, msg)
  if cond then passed = passed + 1 else failed = failed + 1; print("  FAIL: " .. msg) end
end
local function load(settings)
  JANUS_SETTINGS = settings
  assert(loadfile(JANUS_FILE))()
  return JANUS
end
local function node(name) return JANUS.net.nodes[name] end
local freshReset = F.reset
F.reset = function()
  if JANUS then check(not F.logContains("ERROR JANUS"), "no Janus errors before a reset (t=" .. F.time .. ")") end
  freshReset()
end

-- a DCS type per unit role, from the unit DB (deterministic: the first type in name order)
F.reset()
local J0 = load()
local byRole = {}
do
  local names = {}
  for t in pairs(J0.UnitDB) do names[#names + 1] = t end
  table.sort(names)
  for _, t in ipairs(names) do
    local r = J0.UnitDB[t]
    if r.role and not byRole[r.role] and not r.dlc then byRole[r.role] = t end
  end
end
local WORD = { C2 = "CMD", EW = "EW", BATTERY = "SAM", PD = "PD", AAA = "AAA", NAVAL = "SHIP" }
-- unit roles that keep a node of each kind working (janus_network WORKING), and some that do not
local WORKING = {
  C2 = { "C2", "C2_GENERIC", "EWR" },
  EW = { "EWR", "SR", "STR", "TR", "AIRBORNE_SENSOR", "TELAR", "SHORAD" },
  BATTERY = { "TR", "STR", "TELAR", "SHORAD", "AAA_FC", "NAVAL_AD" },
  PD = { "TR", "STR", "TELAR", "SHORAD", "CRAM", "AAA" },
  AAA = { "AAA", "AAA_FC", "SHORAD", "MANPADS" },
  NAVAL = { "NAVAL_AD", "NAVAL" },
}
local NOT_WORKING = { BATTERY = "LN", EW = "LN", AAA = "LN", PD = "LN", NAVAL = "AAA", C2 = "LN" }

-- ---------------------------------------------------------------- 1. which unit roles keep a site working
do
  for kind, roles in pairs(WORKING) do
    for _, role in ipairs(roles) do
      local t = byRole[role]
      check(t ~= nil, "a DCS type for role " .. role)
      if t then
        F.reset()
        local name = WORD[kind] .. " Probe"
        F.addGroup{ name = name, units = { { type = t, x = 0, z = 0 } } }
        load()
        F.run(3)
        local n = node(name)
        check(n and n.kind == kind and n.working, kind .. " with only a " .. role .. " (" .. t .. ") is working")
      end
    end
    local bad = byRole[NOT_WORKING[kind]]
    F.reset()
    local name = WORD[kind] .. " Probe"
    F.addGroup{ name = name, units = { { type = bad, x = 0, z = 0 } } }
    load()
    F.run(3)
    local n = node(name)
    check(n == nil or not n.working, kind .. " with only a " .. NOT_WORKING[kind] .. " is not working")
  end
end

-- ---------------------------------------------------------------- 2. radar and shooter roles
do
  local RADAR = { "EWR", "SR", "STR", "TR", "TELAR", "SHORAD", "CRAM", "AAA_FC", "NAVAL_AD", "AIRBORNE_SENSOR" }
  for _, role in ipairs(RADAR) do
    F.reset()
    F.addGroup{ name = "SAM Probe", units = { { type = byRole[role], x = 0, z = 0 } } }
    load()
    F.run(2)
    check(node("SAM Probe") and node("SAM Probe").hasRadar, role .. " counts as a radar")
  end
  F.reset()
  F.addGroup{ name = "SAM Probe", units = { { type = byRole.LN, x = 0, z = 0 } } }
  load()
  F.run(2)
  check(node("SAM Probe") and not node("SAM Probe").hasRadar, "a launcher alone has no radar")
  -- shooters: a type of the role with a threat range
  local function shooter(role)
    local names = {}
    for t, r in pairs(JANUS.UnitDB) do if r.role == role and (r.threatRange or 0) > 0 and not r.dlc then names[#names + 1] = t end end
    table.sort(names)
    return names[1]
  end
  for _, role in ipairs({ "LN", "TELAR", "SHORAD", "CRAM", "AAA", "MANPADS", "NAVAL_AD" }) do
    local t = shooter(role)
    F.reset()
    F.addGroup{ name = "SAM Probe", units = { { type = t, x = 0, z = 0 } } }
    local J = load({ REACH = false })
    F.run(2)
    check(node("SAM Probe") and node("SAM Probe").engageRange == J.UnitDB[t].threatRange, role .. " counts as a shooter (" .. tostring(t) .. ")")
  end
  F.reset()
  F.addGroup{ name = "SAM Probe", units = { { type = "S-300PS 64H6E sr", x = 0, z = 0 } } }
  load()
  F.run(2)
  check(node("SAM Probe").engageRange == 0, "a search radar is no shooter")
end

-- ---------------------------------------------------------------- 3. tiers: tags, name words, default
do
  F.reset()
  F.addGroup{ name = "SAM A ACE", units = { { type = "Kub 1S91 str" } } }
  F.addGroup{ name = "SAM B GRN", units = { { type = "Kub 1S91 str", x = 1000 } } }
  F.addGroup{ name = "SAM C VET", units = { { type = "Kub 1S91 str", x = 2000 } } }
  F.addGroup{ name = "SAM D REG", units = { { type = "Kub 1S91 str", x = 3000 } } }
  F.addGroup{ name = "SAM E", units = { { type = "Kub 1S91 str", x = 4000 } } }
  F.addGroup{ name = "SAM F [skill:vet]", units = { { type = "Kub 1S91 str", x = 5000 } } }
  F.addGroup{ name = "SAM G [tier:Ace]", units = { { type = "Kub 1S91 str", x = 6000 } } }
  F.addGroup{ name = "SAM H [tier:best] GRN", units = { { type = "Kub 1S91 str", x = 7000 } } }
  load()
  F.run(2)
  check(node("SAM A ACE").tier == "ACE" and node("SAM B GRN").tier == "GRN" and node("SAM C VET").tier == "VET"
    and node("SAM D REG").tier == "REG", "tier from the name word")
  check(node("SAM E").tier == "REG", "untagged: REG")
  check(node("SAM F [skill:vet]").tier == "VET", "[skill:] tag, any case")
  check(node("SAM G [tier:Ace]").tier == "ACE", "[tier:] tag")
  check(node("SAM H [tier:best] GRN").tier == "GRN", "an unknown tag value falls back to the name word")
end

-- ---------------------------------------------------------------- 4. range class: the longest class in the group
do
  F.reset()
  local names = { NONE = nil, SR = nil, MR = nil, LR = nil }
  local all = {}
  for t in pairs(J0.UnitDB) do all[#all + 1] = t end
  table.sort(all)
  for _, t in ipairs(all) do
    local rc = J0.UnitDB[t].rangeClass
    if rc and not names[rc] and not J0.UnitDB[t].dlc then names[rc] = t end
  end
  F.addGroup{ name = "SAM SM", units = { { type = names.SR }, { type = names.MR, x = 50 } } }
  F.addGroup{ name = "SAM ML", units = { { type = names.MR, x = 1000 }, { type = names.LR, x = 1050 } } }
  F.addGroup{ name = "SAM LS", units = { { type = names.LR, x = 2000 }, { type = names.SR, x = 2050 } } }
  F.addGroup{ name = "SAM S", units = { { type = names.SR, x = 3000 } } }
  F.addGroup{ name = "SAM N", units = { { type = "generator_5i57", x = 4000 }, { type = "Kub 2P25 ln", x = 4050 } } }
  load()
  F.run(2)
  check(node("SAM SM").rangeClass == "MR" and node("SAM ML").rangeClass == "LR" and node("SAM LS").rangeClass == "LR"
    and node("SAM S").rangeClass == "SR", "range class: the longest in the group wins")
  check(node("SAM N").rangeClass == JANUS.UnitDB["Kub 2P25 ln"].rangeClass or node("SAM N").rangeClass == "NONE",
    "no classed unit: NONE or the launcher's class")
end

-- ---------------------------------------------------------------- 5. doctrine per coalition, fallback
do
  F.reset()
  F.addGroup{ name = "EW Red", units = { { type = "55G6 EWR" } } }
  F.addGroup{ name = "EW Blue", coalition = BLUE, units = { { type = "FPS-117", x = 5000 } } }
  load({ RED_DOCTRINE = "NOPE", BLUE_DOCTRINE = "NOPE_EITHER" })
  F.run(2)
  check(node("EW Red").net.doctrine.name == "SOVIET_PVO_1985", "red: unknown doctrine falls back to SOVIET_PVO_1985")
  check(node("EW Blue").net.doctrine.name == "US_MODERN", "blue: unknown doctrine falls back to US_MODERN")
  F.reset()
  F.addGroup{ name = "EW Red", units = { { type = "55G6 EWR" } } }
  F.addGroup{ name = "EW Blue", coalition = BLUE, units = { { type = "FPS-117", x = 5000 } } }
  load({ RED_DOCTRINE = "NVA_VIETNAM_1965_72", BLUE_DOCTRINE = "NATO_COLDWAR" })
  F.run(2)
  check(node("EW Red").net.doctrine.name == "NVA_VIETNAM_1965_72" and node("EW Blue").net.doctrine.name == "NATO_COLDWAR",
    "each coalition reads its own doctrine setting")
  check(F.logContains("network red/main (1x EW, NVA_VIETNAM_1965_72") and F.logContains("network blue/main (1x EW, NATO_COLDWAR"),
    "setup report: counts per kind and the doctrine")
end

-- ---------------------------------------------------------------- 6. pickup: duplicates, late groups, wrecks
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11" } } }
  local J = load()
  F.run(2)
  local site = node("CMD Post").site
  local count0 = #J.net.list
  check(J.net.addSite(site) == node("CMD Post") and #J.net.list == count0, "adding a known site returns its node, no duplicate")
  local g = F.spawn{ name = "SAM Late VET", units = { { type = "Kub 1S91 str", x = 20000 }, { type = "Kub 2P25 ln", x = 20200 } } }
  F.run(2.5)
  check(node("SAM Late VET") == nil, "a late group is not picked up before the next tick")
  F.run(4)
  check(node("SAM Late VET") ~= nil and node("SAM Late VET").tier == "VET" and #J.net.list == count0 + 1, "picked up a moment after BIRTH")
  check(F.logContains("picked up SAM Late VET [BATTERY] in red/main"), "pickup logged")
  local nsites = #J.sites
  J.net.pickUp(g)
  check(#J.net.list == count0 + 1 and #J.sites == nsites, "a second pickup of the same group changes nothing")
  F.spawn{ name = "Truck convoy", units = { { type = "Ural-375", x = 30000 } } }
  F.run(8)
  check(node("Truck convoy") == nil, "a group without a role word is not picked up")
  -- a wreck that still exists (life 0) is not alive
  g.units[1].life = 0
  g.units[2].life = 0
  F.fire({ id = world.event.S_EVENT_DEAD, initiator = g.units[1] })
  F.run(20)                                   -- the network refreshes every 5 s
  check(not node("SAM Late VET").alive and F.logContains("SAM Late VET destroyed"), "units at life 0 count as dead")
end

-- ---------------------------------------------------------------- 7. a dead group keeps its last position
do
  F.reset()
  F.addGroup{ name = "CMD Post", units = { { type = "SKP-11" } } }
  local g = F.addGroup{ name = "SAM Pos", units = { { type = "Kub 1S91 str", x = 12345, z = 678 } } }
  load()
  F.run(2)
  F.kill(g.units[1])
  F.run(6)
  local p = node("SAM Pos").pos
  check(p and p.x == 12345 and p.z == 678, "a destroyed site keeps its last known position")
end

print(string.format("test_gaps_network: %d passed, %d failed", passed, failed))
if failed > 0 then os.exit(1) end
