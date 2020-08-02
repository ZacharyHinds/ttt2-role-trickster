CreateConVar("ttt2_trk_jester_mode", 0, {FCVAR_NOTIFY, FCVAR_ARCHIVE})

if CLIENT then
  hook.Add("TTT2FinishedLoading", "mes_devicon", function() -- addon developer emblem for me ^_^
    AddTTT2AddonDev("76561198049910438")
  end)
end

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_dynamic_trickster_convars", function(tbl)
  tbl[ROLE_TRICKSTER] = tbl[ROLE_TRICKSTER] or {}

  table.insert(tbl[ROLE_TRICKSTER], {
    cvar = "ttt2_trk_jester_mode",
    combobox = true,
    choices = {
      "0 - Trickster tries to become jester if there isn't one",
      "1 - Trickster becomes jester if there isn't one",
      "2 - Someone else becomes jester if there isn't one"
    },
    numStart = 0
    desc = "ttt2_trk_jester_mode (def. 0)"
  })
end)
