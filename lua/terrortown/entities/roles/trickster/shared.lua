if SERVER then
	AddCSLuaFile()
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_trk.vmt")
end

function ROLE:PreInitialize()
	self.color = Color(198, 39, 230, 255)

	self.abbr = "trk"
	self.visibleForTeam = {TEAM_TRAITOR}
	self.surviveBonus = 0
	self.scoreKillsMultiplier = 0
	self.scoreTeamKillsMultiplier = 0
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

if SERVER then
	function ROLE:Initialize()
		for _, role in ipairs(roles.GetList()) do
			if role.baserole == ROLE_TRAITOR or role.index == ROLE_TRAITOR then
				if not self.networkRoles then
					self.networkRoles = {role}
				else
					table.insert(self.networkRoles, role)
				end
			end
		end
	end

	hook.Add("TTT2ModifySelectableRoles", "TTT2ModifySelectableRolesrkNeedsJes", function (selectableRoles)
	  if not selectableRoles[TRICKSTER] then return end
	  if not JESTER or not selectableRoles[JESTER] or GetConVar("ttt2_jes_winstate"):GetInt() ~= 1 then
	    selectableRoles[TRICKSTER] = nil
	  end
	end)

	function TricksterDealNoDamage(ply, attacker)
		if not IsValid(ply) or not IsValid(attacker) then return end
		if not attacker:IsPlayer() or attacker:GetSubRole() ~= ROLE_TRICKSTER then return end

		if ply:GetSubRole() == ROLE_JESTER then
			return true
		end
	end

	hook.Add("PlayerTakeDamage", "TricksterDamage", function (ply, inflictor, attacker, amount, dmginfo)
		if TricksterDealNoDamage(ply, attacker) then
			dmginfo:ScaleDamage(0)
			dmginfo:SetDamage(0)
			return
		end
	end)

	function CheckForJester()
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetSubRole() == ROLE_JESTER then return true end
		end
	end

	function CheckForTrickster()
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetSubRole() == ROLE_TRICKSTER then return true end
		end
	end

	function SetJester()
		if CheckForJester() then return end
		local base_innos = {}
		local all_innos = {}
		local neutrals = {}

		for _, ply in ipairs(player.GetAll()) do
			if ply:HasTeam(TEAM_INNOCENT) then
				if ply:GetSubRole() == ROLE_INNOCENT then
					base_innos[#base_innos + 1] = ply
					all_innos[#all_innos + 1] = ply
				elseif ply:GetBaseRole() ~= ROLE_DETECTIVE then
					all_innos[#all_innos + 1] = ply
				end
			elseif not ply:HasTeam(TEAM_TRAITOR) and ply:GetSubRole() ~= ROLE_TRICKSTER then
				neutrals[#neutrals + 1] = ply
			end
		end

		if #base_innos > 0 then
			local targetply = base_innos[math.random(#base_innos)]
		elseif #all_innos > 0 then
			local targetply = all_innos[math.random(#all_innos)]
		elseif #neutrals > 0 then
			local targetply = neutrals[math.random(#neutrals)]
		else
			return
		end
	end

	function SetTrickJester()
		if CheckForJester() then return end
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetSubRole() ~= ROLE_TRICKSTER then continue end

			ply:SetRole(ROLE_JESTER, TEAM_JESTER)
			return
		end
	end

	function SetTrickInno()
		for _, ply in ipairs(player.GetAll()) do
			if ply:GetSubRole() == ROLE_TRICKSTER then
				ply:SetRole(ROLE_INNOCENT, TEAM_INNOCENT)
			end
		end
	end

	hook.Add("TTTBeginRound", "EnsureTrickHasJester", function()
		local force_mode = GetConVar("ttt2_trk_jester_mode"):GetInt()
		if not TRICKSTER or not JESTER then return end

		if not CheckForTrickster() or CheckForJester() then return end

		if force_mode == 0 then -- Trickster tries to become jester if there isn't one
			if math.random(100) <= GetConVar("ttt_jester_random") then
				SetTrickJester()
			else
				SetTrickInno()
			end
		elseif force_mode == 1 then --  Trickster becomes jester if there isn't one
			SetTrickJester()
		elseif force_mode >= 2 then -- Someone else becomes Jester if there isn't one
			SetJester()
		end
	end)
end
