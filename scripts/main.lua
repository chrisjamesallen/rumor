package.path = "/Users/chrisallen/projects/desky/scripts/?.lua;" .. package.path
require "base"
Tween = require "libs/tween"
_ = require "libs/underscore"
inspect = require "libs/inspect"
require "emma/app"

-- Main
runtime = 0;
starttime = 0;
drawtime = 0;
fps = 60;
SCREEN = {}


function main()
    app = App:new()

end

function update (delta,runTime,pos)
    if(starttime <=0) then
        starttime = runTime
        app.system.runTime = starttime
    end
    if(app~=nil and destroying ~= true) then
        app.system.runTime = runTime - starttime  --Store game time
        app:update(delta)
    end
end

function draw()
    if(app~=nil and destroying ~= true) then
        app:draw()
    end
end

function destroy()
    if(app~=nil) then
        destroying = true;
        app:destroy()
        app = nil
        package.loaded['emma/app']  = nil
        collect()
        destroying = false;
    end
end

function collect()
    collectgarbage('collect')
end

function reload()
    print('reload')
    app = App:new()
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







