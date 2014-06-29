-- so here we are going to require all the relevant libraries...
package.path = "/Users/chrisallen/projects/desky/scripts/?.lua;" .. package.path
require "base"
Tween = require "libs/tween"
_ = require "libs/underscore"

require "emma/app"

-- Main
runtime = 0;
starttime = 0;
drawtime = 0;
fps = 60;
SCREEN = {}

function main()
    SCREEN = System.screen()
    app = App:new()
end

function update (delta,runTime,pos)
    if(starttime <=0) then
        starttime = runTime
        RUNTIME = starttime
    end
    if(app~=nil and destroying ~= true) then
        RUNTIME = runTime - starttime  --Store game time
        app:update(delta)
        mouse = System.mouse()
        --print("Move::", mouse.pressed, mouse.dragging)
    end
end

function draw()
    if(app~=nil and destroying ~= true) then
        --local b = System.time()
        app:draw()
        --local a = System.time()
        --drawtime = a - b
    end
end

function destroy()
    if(app~=nil) then
        destroying = true;
        app:destroy()
        app = nil
        collect()
        destroying = false;
    end
end

function reload()
    print('reload')
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







