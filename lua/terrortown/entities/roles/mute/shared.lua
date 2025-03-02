-- ROLE.Base = "ttt_role_base"
--
-- ROLE.index = ROLE_INNOCENT

if SERVER then
  AddCSLuaFile()

  resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_mute.vmt")
end

function ROLE:PreInitialize()
  self.color = Color(180, 255, 169)

  self.abbr = "mute" -- abbreviation
  self.scoreKillsMultiplier = 5 -- multiplier for kill of player of another team
  self.scoreTeamKillsMultiplier = -8 -- multiplier for teamkill
  self.defaultEquipment = INNO_EQUIPMENT
  self.unknownTeam = true

  self.defaultTeam = TEAM_INNOCENT

  self.conVarData = {
    pct = 0.17,
    maximum = 1,
    minPlayers = 6,
    credits = 0,
    togglable = false,
    random = 50
  }
end

-- now link this subrole with its baserole
function ROLE:Initialize()
  roles.SetBaseRole(self, ROLE_INNOCENT)
end

if SERVER then

  -- hook.Add("TTT2RoleNotSelectable", MuteRoleSelectable, function(roleData)
  --   if roleData.name == "Mute" and not true then
  --     print("[dttt-roles] This role requires dttt to be installed, consider either adding dttt or removing this addon.")
  --     return false
  --   end
  -- end)

  hook.Add("TTT2AvoidGeneralChat", "MuteRoleChat", function(ply, message)
    if not IsValid(ply) or not ply:IsActive() or ply:GetSubRole() ~= ROLE_MUTE then return end

    return false
  end)

  hook.Add("TTT2AvoidTeamChat", "MuteRoleTeamChat", function(ply, message)
    if not IsValid(ply) or not ply:IsActive() or ply:GetSubRole() ~= ROLE_MUTE then return end

    return false
  end)

  hook.Add("TTT2CanUseVoiceChat", "MuteRoleVoiceChat", function(ply, isTeam)
    if not IsValid(ply) or not ply:IsActive() or ply:GetSubRole() ~= ROLE_MUTE then return end

    return false
  end)

  hook.Add("TTT2PlayerRadioCommand", "MuteRoleRadio", function(ply, msgName, msgTarget)
    if not IsValid(ply) or not ply:IsActive() or ply:GetSubRole() ~= ROLE_MUTE then return end

    return true
  end)

  hook.Add("TTT2CanUsePointer", "MuteRolePointer", function(ply, mode, trPos, trEnt)
    if not IsValid(ply) or not ply:IsActive() or ply:GetSubRole() ~= ROLE_MUTE then return end

    return false
  end)

  hook.Add("TTT2SpecialRoleSyncing", "MuteRoleSync", function(ply, tbl)
    if not IsValid(ply) or ply == nil or ply:GetSubRole() ~= ROLE_MUTE then return end

    local selection = GetConVar("ttt2_mute_roles"):GetInt()

    if selection == 0 then
      -- Reveal all traitors to the mute
      for p in pairs(tbl) do
        local team = p:GetTeam()
        if (team == TEAM_TRAITOR) then
          tbl[p] = {p:GetSubRole(), team}
        end
      end
    elseif selection == 1 then
      -- Reveal all innocents to the mute
      for p in pairs(tbl) do
        local team = p:GetTeam()
        if (team == TEAM_INNOCENT) then
          tbl[p] = {p:GetSubRole(), team}
        end
      end
    elseif selection == 2 then
      -- Reveal all roles to the mute
      for p in pairs(tbl) do
        tbl[p] = {p:GetSubRole(), p:GetTeam()}
      end
    end

  end)

  hook.Add("PlayerTakeDamage", "MuteDamageScale", function(ent, infl, att, amount, dmginfo)
    if att:GetSubRole() ~= ROLE_MUTE then return end

    dmginfo:ScaleDamage(GetConVar("ttt2_mute_dmg_scale"):GetFloat())
  end)
end

if CLIENT then
  hook.Add("TTT2ClientRadioCommand", "MuteRoleRadio", function(ply, msgName, msgTarget)
    if not IsValid(ply) or not ply:IsActive() or ply:GetSubRole() ~= ROLE_MUTE then return end

    return true
  end)

  function ROLE:AddToSettingsMenu(parent)
    local form = vgui.CreateTTT2Form(parent, "header_roles_additional")
    local translate = LANG.TryTranslation

    local choices = {
      translate("label_ttt2_mute_roles_traitor"),
      translate("label_ttt2_mute_roles_innocent"),
      translate("label_ttt2_mute_roles_all")
    }

    form:MakeComboBox({
      label = "label_ttt2_mute_roles",
      choices = choices,
      selectName = choices[GetConVar("ttt2_mute_roles"):GetInt() + 1],
      OnChange = function(value)
        local index = -1
        for i,choice in pairs(choices) do
          if choice == value then index = i end
        end

        if (index == -1) then return end

        index = index - 1 -- switch from lua 1-based indexing to cvar range 
        cvars.ChangeServerConVar("ttt2_mute_roles", index)
      end
    })

    form:MakeSlider({
      serverConvar = "ttt2_mute_dmg_scale",
      label = "label_ttt2_mute_dmg_scale",
      min = GetConVar("ttt2_mute_dmg_scale"):GetMin(),
      max = GetConVar("ttt2_mute_dmg_scale"):GetMax(),
      decimal = 2
    })
  end
end