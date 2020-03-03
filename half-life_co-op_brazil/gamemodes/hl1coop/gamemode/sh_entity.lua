local meta = FindMetaTable("Entity")

function meta:IsTrigger()
	local class = self:GetClass()
	return class == "trigger_once" or class == "trigger_multiple"
end