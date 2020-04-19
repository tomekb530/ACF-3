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