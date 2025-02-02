local class = require("middleclass")

-- Module for handling errors and results
local errhandler = {}

-- Class for representing a Result which can be either Success or Error
local Result = class("Result")
-- Class for successful outcomes
local Success = class("Success")
-- Class for error outcomes
local Error = class("Error")

-- Initialize the Success object with the result
function Success:initialize(result)
    self.result = result
end

-- Convert Success to Result by applying a function to the result
function Success:to_result(func)
    return Result(function()
        return func(self.result)
    end)
end

-- Apply a function directly to the success result
function Success:to_func(func)
    return func(self.result)
end

-- Return the result or a default if no result is present (but in this case, always return the result)
function Success:get_or_else(default)
    return self.result
end

-- Get the result of the success
function Success:get()
    return self.result
end

-- Get the result or return a default if result is nil
function Success:get_or_default(default)
    return self.result or default
end

-- Check if this is a success case
function Success:is_success()
    return true
end

-- Check if this is an error case (always false for Success)
function Success:is_error()
    return false
end

-- Initialize the Error object with name, message, and optional code
function Error:initialize(name, message, code)
    self.name = name or "Error"  -- Default error name if not provided
    self.message = message:gsub("^.-%d+: ", "")  -- Clean up the message from stack trace
    self.code = code or 0  -- Default error code if not provided
end

-- Retrieve the error code
function Error:get_code()
    return self.code
end

-- Retrieve the error message
function Error:get_message()
    return self.message
end

-- Convert Error to Result by applying a function to this error
function Error:to_result(func)
    return Result(function()
        return func(self)
    end)
end

-- Apply a function directly to the error
function Error:to_func(func)
    return func(self)
end

-- Return a default value since there's an error
function Error:get_or_else(default)
    return default
end

-- Attempt to get the result, but since this is an Error, return nil
function Error:get()
    return nil    
end

-- Check if this is a success case (always false for Error)
function Error:is_success()
    return false
end

-- Check if this is an error case
function Error:is_error()
    return true
end

-- Raise this error
function Error:raise()
    error(self.name .. ": " .. self.message, 2)
end

-- Initialize Result with a function that will be executed later
function Result:initialize(func)
    self.func = func
end

-- Call the Result, which will return either a Success or Error object
function Result:__call(...)
    local success, result = pcall(self.func, ...)
    if success then
        -- If the result is already a Success object, return it; otherwise, wrap in Success
        return (result.isInstanceOf and result:isInstanceOf(Success)) and result or Success(result)
    else
        -- If an error occurred during execution, return an Error object
        return (result.isInstanceOf and result:isInstanceOf(Error)) and result or Error(nil, result)
    end
end

-- Check if the given instance is a Success or return an error if it's neither Success nor Error
function Result:is_success(instance)
    if instance.isInstanceOf and (instance:isInstanceOf(Success) or instance:isInstanceOf(Error)) then
        return instance:is_success()
    else
        error("The value is not an instance of 'Success' or 'Error'.")
    end
end

-- Match pattern to handle Success or Error cases
function Result:match(success_func, error_func)
    local success, result = pcall(self)
    if success then
        if result:is_success() then
            return success_func(result)
        else
            -- If we get an unexpected result, treat it as an error
            return error_func(errhandler.Error("UnexpectedResult", "Unexpected non-success result"))
        end
    else
        -- If pcall failed, pass the error to the error handler
        return error_func(errhandler.Error("ExecutionError", result))
    end
end

-- Attach the classes to the errhandler module
errhandler.Result = Result
errhandler.Success = Success
errhandler.Error = Error

-- Return the module
return errhandler