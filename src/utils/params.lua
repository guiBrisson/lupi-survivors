local Params = {}

function Params.Merge(default, params)
    local merged = {}
    for key, value in pairs(default) do
        merged[key] = (params and params[key]) or value
    end
    return merged
end

return Params
