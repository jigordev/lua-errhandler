local class = require("middleclass")
local errhandler = require("errhandler")

local function testSuccessCreation()
    local success = errhandler.Success:new("Test Result")
    assert(success:is_success(), "Success object should indicate success")
    assert(success:get_result() == "Test Result", "Success result should match")
end

local function testErrorCreation()
    local error = errhandler.Error:new("Test Error", "Error Message", 500)
    assert(error:is_error(), "Error object should indicate error")
    assert(error:get_message() == "Error Message", "Error message should match")
    assert(error:get_code() == 500, "Error code should match")
end

local function testSuccessMethods()
    local success = errhandler.Success:new("Test Result")
    assert(success:get_or_else("Default") == "Test Result", "get_or_else should return result")
    assert(success:get_or_default("Default") == "Test Result", "get_or_default should return result")
end

local function testErrorMethods()
    local error = errhandler.Error:new("Test Error", "Error Message", 500)
    assert(error:get_or_else("Default") == "Default", "get_or_else should return default")
end

local function testResultSuccess()
    local success = errhandler.Success:new("Test Result")
    local resultFunc = success:to_result(function(result)
        return "Processed " .. result
    end)
    local result = resultFunc()
    assert(result:is_success(), "Result should be Success")
    assert(result:get_result() == "Processed Test Result", "Processed result should match")
end

local function testResultError()
    local error = errhandler.Error:new("Test Error", "Error Message", 500)
    local resultFunc = error:to_result(function(err)
        err:raise()
    end)
    local result = resultFunc()
    assert(result:is_error(), "Result should be Error")
    assert(result:get_message() == "Test Error: Error Message", "Processed error message should match")
end

local function testResultMatch()
    local success = errhandler.Success:new("Test Result")
    local resultFunc = success:to_result(function(result)
        return "Processed " .. result
    end)
    local matchedResult = resultFunc:match(
        function(success)
            return success:get_result()
        end,
        function(error)
            return error:get_message()
        end
    )
    assert(matchedResult == "Processed Test Result", "Matched result should be processed success")
end

local function runtests()
    testSuccessCreation()
    testErrorCreation()
    testSuccessMethods()
    testErrorMethods()
    testResultSuccess()
    testResultError()
    testResultMatch()
    print("All tests passed successfully!")
end

runtests()
