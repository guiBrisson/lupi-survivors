local EventBus = {}
EventBus.__index = EventBus

function EventBus:new()
    local instance = setmetatable({}, self)
    instance.listeners = {}
    return instance
end

function EventBus:on(event, callback)
    self.listeners[event] = self.listeners[event] or {}
    table.insert(self.listeners[event], callback)
end

function EventBus:emit(event, ...)
    local callbacks = self.listeners[event]
    if callbacks then
        for _, callback in ipairs(callbacks) do
            callback(...)
        end
    end
end

return EventBus
