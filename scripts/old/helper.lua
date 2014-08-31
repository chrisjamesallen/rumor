
-- Notes !

-- [for loop] for k,v in pairs(_ENV) do print(k) end
for k,v in pairs(gl) do print(k) end

-- [maths]

-- [function]

-- [meta tables]

-- [strings]
 concat uses ..

--local data = array.new({1.0, -1.0, 1.0,  1.0, -1.0, 1.0,  1.0, 1.0, 1.0,  -1.0, 1.0, 1,  0}, 50);


-- long string
local test_str = [[
    stuff
    and
    stuff
]]
test_str = "Or with escape formatting \t "



assert ( v [, message] )
This function is similar to the assert function used with C; it returns an error if the value of the argument v is false (either nil or false);. The message, if present, is displayed as an error; if absent, the default text “assertion failed!” is displayed.
    assert(money>0,"you need to have some money to buy something")

error ( message [,level] )
This function terminates the last protected function and returns the message as the error message.
    error("This operations is invalid")
    
    collectgarbage ( [opt [,arg]] )
    This function is a generic interface to the garbagecollector. The function acts differently depending on the parameter opt. The options that you can pass to this function as opt are
 
        ￼ collect: Performs a full garbage-collection cycle. This is the default option.
         stop: Stops the garbage collector.
         restart: Restarts the garbage collector.
         count: Returns the total memory in use by Lua.
         step: Performs a garbage-collection step. The step size is governed by arg.
         setpause: Sets arg as the new value for pause and returns the previous value of
        pause.
         setstepmul: Sets arg as the new value for the step multiplier and returns the
        previous value for step.
        Tip If you want to know the memory usage of your app and clear up the memory and objects, you can force the garbagecollector to free up and reclaim the memory allocated and then print the amount of memory used after a cleanup by using the print(collectgarbage("count")) command.
        
        
_G
This is not exactly a function, but a global variable. Lua does not use this variable, but it holds all the global variables and function.









