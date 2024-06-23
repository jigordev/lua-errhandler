local class = require("middleclass")

local errhandler = {}

local Result = class("Result")
local Success = class("Success")
local Error = class("Error")

function Success:initialize(result)
    self.result = result
end

function Success:map(func)
    return Result(function()
        return func(self.result)
    end)
end

function Success:get_result()
    return self.result
end

function Success:get_or_default(default)
    return self.result or default
end

function Success:is_success()
    return true
end

function Success:is_error()
    return false
end

function Error:initialize(name, message)
    self.name = name or "Error"
    self.message = message
end

function Error:is_success()
    return false
end

function Error:is_error()
    return true
end

function Error:raise()
    local message = self.message:gsub("^.-%d+: ", "")
    error(self.name .. ": " .. message, 2)
end

function Result:initialize(func)
    self.func = func
end

function Result:__call(...)
    local success, result = pcall(self.func, ...)
    if success then
        if result.isInstanceOf and result:isInstanceOf(Success) then return result else return Success(result) end
    else
        if result.isInstanceOf and result:isInstanceOf(Error) then return result else return Error(nil, result) end
    end
end

function Result:is_success(instance)
    if instance.isInstanceOf and instance:isInstanceOf(Success) or instance:isInstanceOf(Error) then
        return instance:is_success()
    else
        error("The value is not an instance of 'Success' or 'Error'.")
    end
end

errhandler.Result = Result
errhandler.Success = Success
errhandler.Error = Error

return errhandler
