-- so here we are going to require all the relevant libraries...
package.path = "/Users/chrisallen/projects/desky/scripts/?.lua;" .. package.path
require "base"
require "emma"

 

-- Main


function main()
    --called from c..
    print("main ~ start")
    require "emma/app"
    app = App:new()
end

function update ()
    if(app~=nil) then
        app:update()
    end
end

function draw()
    if(app~=nil) then
        app:draw()
    end
end

function destroy()
    if(app~=nil) then
        app:destroy()
        app = nil
        App = nil
        collect()
    end
end

function reload()
    app = App:new()
end


function collect()
   collectgarbage('collect')
end

function  touchStarted(x,y)
end

function  touchMoved(x,y)
end

function  touchEnded(x,y)
end

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end
local clock = os.clock

function wait(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end







