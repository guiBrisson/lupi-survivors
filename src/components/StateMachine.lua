local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine:new()
    local instance = setmetatable({}, self)
    instance.states = {}
    instance.current = nil
    instance.params = nil
    instance.transitions = {}
    return instance
end

function StateMachine:add_state(name, callbacks)
    self.states[name] = callbacks or {}
end

function StateMachine:add_transition(from, to)
    self.transitions[from] = to
end

function StateMachine:change_state(name, params)
    if not self.states[name] then
        error("State '" .. name .. "' does not exist")
    end

    if self.current and self.states[self.current].exit then
        self.states[self.current].exit()
    end

    self.previous = self.current
    self.current = name
    self.params = params

    if self.states[name].enter then
        self.states[name].enter(params)
    end
end

--- Transition to next state (if defined)
function StateMachine:go_to_next()
    if self.current and self.transitions[self.current] then
        self:change_state(self.transitions[self.current])
    end
end

function StateMachine:update(dt)
    if self.current and self.states[self.current].update then
        self.states[self.current].update(dt)
    end
end

function StateMachine:draw()
    if self.current and self.states[self.current].draw then
        self.states[self.current].draw()
    end
end

function StateMachine:current_state()
    return self.current
end

return StateMachine
