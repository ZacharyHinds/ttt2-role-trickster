function ROLE:PreInitialize()
	self.color = Color(198, 39, 230, 255)

	self.abbr = "trk"
	self.visibleForTeam = {TEAM_TRAITOR}
	self.surviveBonus = 0
	self.scoreKillsMultiplier = 1
	self.scoreTeamKillsMultiplier = -8
	self.preventWin = true

	self.defaultTeam = TEAM_JESTER
	self.defaultEquipment = INNO_EQUIPMENT

	self.conVarData = {
		pct = 0.17,
		maximum = 1,
		minPlayers = 6,
		togglable = true
	}
end

hook.Add("TTT2ModifySelectableRoles", "TTT2ModifySelectableRolesrkNeedsJes", function (selectableRoles)
  if not selectableRoles[TRICKSTER] then return end
  if not JESTER or not selectableRoles[JESTER] or GetConVar("ttt2_jes_winstate"):GetInt() ~= 1 then
    selectableRoles[TRICKSTER] = nil
  end
end)
