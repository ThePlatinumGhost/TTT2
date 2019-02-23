local surface = surface

-- Fonts
surface.CreateFont("PureSkinRole", {font = "Trebuchet24", size = 30, weight = 700})
surface.CreateFont("PureSkinBar", {font = "Trebuchet24", size = 21, weight = 1000})
surface.CreateFont("PureSkinWep", {font = "Trebuchet24", size = 21, weight = 1000})
surface.CreateFont("PureSkinWepNum", {font = "Trebuchet24", size = 21, weight = 700})

-- base drawing functions
include("cl_drawing_functions.lua")

local defaultColor = Color(49, 71, 94)

HUD.previewImage = Material("vgui/ttt/huds/pure_skin/preview.png")

local savingKeys

function HUD:GetSavingKeys()
	if not savingKeys then
		local savingKeys = table.Copy(self.BaseClass.GetSavingKeys(self))

		savingKeys.basecolor = {
			typ = "color",
			desc = "BaseColor",
			OnChange = function(slf, col)
				for _, elem in ipairs(slf:GetHUDElements()) do
					local el = hudelements.GetStored(elem)
					if el then
						el.basecolor = col
					end
				end
			end
		}
	end

	print("saving keys: ", savingKeys)
	PrintTable(savingKeys or {ret = "nil"})

	return savingKeys
end

HUD.basecolor = defaultColor

function HUD:Initialize()
	self:ForceHUDElement("pure_skin_playerinfo")
	self:ForceHUDElement("pure_skin_roundinfo")
	self:ForceHUDElement("pure_skin_wswitch")
	self:ForceHUDElement("pure_skin_drowning")
	self:ForceHUDElement("pure_skin_mstack")
	--self:ForceHUDElement("old_ttt_spec")
	--self:ForceHUDElement("old_ttt_items")

	-- Initialize elements default values
	for _, v in ipairs(self:GetHUDElements()) do
		local elem = hudelements.GetStored(v)
		if elem then
			elem:Initialize()
			elem:SetDefaults()

			local skeys = elem:GetSavingKeys()

			-- load and initialize all HUDELEMENT data from database
			if SQL.CreateSqlTable("ttt2_hudelements", skeys) then
				local loaded = SQL.Load("ttt2_hudelements", elem.id, elem, skeys)

				if not loaded then
					SQL.Init("ttt2_hudelements", elem.id, elem, skeys)
				end
			end

			elem:Load()

			elem.initialized = true
		else
			Msg("Error: HUD " .. (self.id or "?") .. " has unkown element named " .. v .. "\n")
		end
	end

	self:PerformLayout()
end

function HUD:Loaded()
	for _, elem in ipairs(self:GetHUDElements()) do
		local el = hudelements.GetStored(elem)
		if el then
			el.basecolor = self.basecolor
		end
	end
end

function HUD:Reset()
	self.basecolor = defaultColor
end

-- Voice overriding
include("cl_voice.lua")

-- Popup overriding
include("cl_popup.lua")
