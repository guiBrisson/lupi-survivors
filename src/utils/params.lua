local Params = {}

---Merge two tables together
---@param default table
---@param params table|nil
---@return table
function Params.Merge(default, params)
    local merged = {}

    for key, value in pairs(default) do
        merged[key] = value
    end

    if params then
        for key, value in pairs(params) do
            merged[key] = value
        end
    end

    return merged
end

return Params
