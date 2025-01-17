---
-- @class ENT
-- @section ttt_logic_role

ENT.Type = "point"
ENT.Base = "base_point"

local IsValid = IsValid

ROLE_NONE = ROLE_NONE or 3

ENT.Role = ROLE_NONE

---
-- @param string key
-- @param string|number value
-- @realm shared
function ENT:KeyValue(key, value)
	if key == "OnPass" or key == "OnFail" then
		-- this is our output, so handle it as such
		self:StoreOutput(key, value)
	elseif key == "Role" then
		if isstring(value) then
			value = _G[value] or value
		end

		self.Role = tonumber(value)

		if not self.Role then
			ErrorNoHalt("ttt_logic_role: bad value for Role key, not a number\n")

			self.Role = ROLE_NONE
		end
	end
end

---
-- @param string name
-- @param Entity|Player activator
-- @return[default=true] boolean
-- @realm shared
function ENT:AcceptInput(name, activator)
	if name == "TestActivator" then
		if IsValid(activator) and activator:IsPlayer() then
			local activator_role = (GetRoundState() == ROUND_PREP) and ROLE_INNOCENT or activator:GetBaseRole()

			if self.Role == ROLE_NONE or self.Role == activator_role then
				Dev(2, activator, "passed logic_role test of", self:GetName())

				self:TriggerOutput("OnPass", activator)
			else
				Dev(2, activator, "failed logic_role test of", self:GetName())

				self:TriggerOutput("OnFail", activator)
			end
		end

		return true
	end
end
