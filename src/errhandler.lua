local class = require("middleclass")

local errhandler = {}

local Result = class("Result")
local Success = class("Success")
local Error = class("Error")

function Success:initialize(result)
    self.result = result
end

function Success:to_result(func)
    return Result(function()
        return func(self.result)
    end)
end

function Success:to_func(func)
    return func(self.result)
end

function Success:get_or_else(default)
    return self.result
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

function Error:initialize(name, message, code)
    self.name = name or "Error"
    self.message = message:gsub("^.-%d+: ", "")
    self.code = code or 0
end

function Error:get_code()
    return self.code
end

function Error:get_message()
    return self.message
end

function Error:to_result(func)
    return Result(function()
        return func(self)
    end)
end

function Error:to_func(func)
    return func(self)
end

function Error:get_or_else(default)
    return default
end

function Error:is_success()
    return false
end

function Error:is_error()
    return true
end

function Error:raise()
    error(self.name .. ": " .. self.message, 2)
end

function Result:initialize(func)
    self.func = func
end

function Result:__call(...)
    local success, result = pcall(self.func, ...)
    if success then
        return (result.isInstanceOf and result:isInstanceOf(Success)) and result or Success(result)
    else
        return (result.isInstanceOf and result:isInstanceOf(Error)) and result or Error(nil, result)
    end
end

function Result:is_success(instance)
    if instance.isInstanceOf and instance:isInstanceOf(Success) or instance:isInstanceOf(Error) then
        return instance:is_success()
    else
        error("The value is not an instance of 'Success' or 'Error'.")
    end
end

function Result:match(success_func, error_func)
    local success, result = pcall(self.func)
    if success then
        return success_func(result)
    else
        return error_func(result)
    end
end

errhandler.Result = Result
errhandler.Success = Success
errhandler.Error = Error

return errhandler
