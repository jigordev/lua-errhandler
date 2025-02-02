# Lua-ErrHandler Library

A simple Lua library for handling success and error results using classes and method chaining.

## Features

- **Success Class (`Success`)**: Represents a successful result with methods to retrieve the result, handle default values, and check its success status.
- **Error Class (`Error`)**: Represents an error result with methods to handle error propagation and check its error status.
- **Result Class (`Result`)**: Facilitates calling a function that might succeed or fail, returning either `Success` or `Error`.

## Installation

To use this library, simply include the `errhandler.lua` file in your project and require it:

```lua
local errhandler = require("errhandler")
```

## Usage

### Creating Success and Error Instances

#### Creating a Success Instance

```lua
local successInstance = errhandler.Success("Some result data")
```

#### Creating an Error Instance

```lua
local errorInstance = errhandler.Error("CustomError", "Something went wrong")
```

### Handling Results with Result Class

#### Creating a Result Instance

To execute a function that may succeed or fail, create a `Result` instance:

```lua
local function divide(a, b)
    if b == 0 then
        return errhandler.Error("DivisionError", "Cannot divide by zero")
    else
        return errhandler.Success(a / b)
    end
end

local result = errhandler.Result(function()
    return divide(10, 2)
end)
```

#### Calling the Result Instance

```lua
local outcome = result()
if outcome:is_success() then
    print("Result:", outcome:get())
else
    outcome:raise()
end
```

### Success Class Methods

#### Get Result

```lua
local resultValue = successInstance:get()
```

#### Get Result or Default

```lua
local defaultValue = successInstance:get_or_default("Default value")
```

#### To Result

```lua
local newResult = successInstance:to_result(function(result)
    return result * 2
end)
```

#### To Function

```lua
successInstance:to_func(function(result)
    print("Received result:", result)
end)
```

### Error Class Methods

#### Raise an Error

```lua
errorInstance:raise()
```

#### To Result

```lua
local newResult = errorInstance:to_result(function(error)
    return error:get_message()
end)
```

#### To Function

```lua
errorInstance:to_func(function(error)
    print("Error occurred:", error:get_message())
end)
```

### Checking Success or Error

#### Check if Success

```lua
if successInstance:is_success() then
    -- Handle success
end
```

#### Check if Error

```lua
if errorInstance:is_error() then
    -- Handle error
end
```

### Utility Methods (Result Class)

#### Check Instance Type

```lua
local instance = errhandler.Success("Example")
if errhandler.Result:is_success(instance) then
    -- Instance is a Success instance
else
    -- Instance is not a Success or Error instance
end
```

#### Calling the Result Instance with `match`

```lua
result:match(
    function(successResult)
        print("Division successful. Result:", successResult:get())
    end,
    function(errorResult)
        print("Division failed. Error:", errorResult:get_message())
    end
)
```

In this example:
- `match` is used to handle both success (`Success` instance) and error (`Error` instance) cases returned by `result`.
- If the division succeeds (`Success`), it prints the result.
- If the division fails (`Error`), it prints the error message.

## License

This library is licensed under the MIT License. See the LICENSE file for more details.
