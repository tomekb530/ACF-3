local function GetAllPhysicalEntities(Ent, Tab)
	local Res = Tab or {}

	if IsValid(Ent) and not Res[Ent] then
		Res[Ent] = true

		if Ent.Constraints then
			for K, V in pairs(Ent.Constraints) do
				if not IsValid(V) then -- Constraints don't clean up after themselves
					Ent.Constraints[K] = nil -- But we will do Garry a favor and clean up after him
					continue
				end

				if V.Type ~= "NoCollide" then -- NoCollides aren't a real constraint
					GetAllPhysicalEntities(V.Ent1, Res)
					GetAllPhysicalEntities(V.Ent2, Res)
				end
			end
		end
	end

	return Res
end

local function GetAllChildren(Ent, Tab)
	local Res = Tab or {}

	for _, V in pairs(Ent:GetChildren()) do
		if not IsValid(V) or Res[V] then continue end

		Res[V] = true
		GetAllChildren(V, Res)
	end

	return Res
end

do -- Contraption awareness/CFW -----------------
	hook.Add("OnSetMass", "ACF", function(Ent, _, NewMass)
		if Ent.ACF and Ent.ACF.LegalMass and NewMass ~= Ent.ACF.LegalMass then
			return false
		end
	end)

	local ColGroupFilter = {COLLISION_GROUP_DEBRIS = true, COLLISION_GROUP_DEBRIS_TRIGGER = true}
	hook.Add("OnContraptionAppend", "ACF ColGroups", function(_, Ent)
		if ColGroupFilter[Ent:GetCollisionGroup()] then -- If the collision group is set to something we dont like
			Ent:SetCollisionGroup(COLLISION_GROUP_NONE) -- Reset it

		end
	end)
end

do -- ACF Parent Detouring ----------------------
	local Detours = {}
	function ACF.AddParentDetour(Class, Variable)
		if not Class then return end
		if not Variable then return end

		Detours[Class] = function(Entity)
			return Entity[Variable]
		end
	end

	hook.Add("Initialize", "ACF Parent Detour", function()
		local EntMeta = FindMetaTable("Entity")
		local SetParent = EntMeta.SetParent

		function EntMeta:SetParent(Entity, ...)
			if IsValid(Entity) then
				local Detour = Detours[Entity:GetClass()]

				if Detour then
					Entity = Detour(Entity)
				end
			end

			SetParent(self, Entity, ...)
		end

		hook.Remove("Initialize", "ACF Parent Detour")
	end)
end ---------------------------------------------

-- Globalize ------------------------------------
ACF.GetAllChildren 			= GetAllChildren