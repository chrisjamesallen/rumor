-- so here we are going to require all the relevant libraries...
package.path = "/Users/chrisallen/projects/desky/scripts/?.lua;" .. package.path
require "base"
require "emma"
require "emma/app"
require "emma/shader"

-- Main

runtime = 0;
starttime = 0;
drawtime = 0;
fps = 60;
screen = {}

function main()
    --called from c..
    print("main ~ start")
    app = App:new()
    screen = System.screen()
    print("Screen Dimensions::", screen.width, screen.height)
end

function update (delta,runTime,pos)
    if(starttime <=0) then
        starttime = runTime
        runtime = starttime
    end
    if(app~=nil) then
        runtime = runTime - starttime  --Store game time
        app:update(delta)
        mouse = System.mouse()
        --print("Move::", mouse.pressed, mouse.dragging)
    end
end

function draw()
    if(app~=nil) then
        --local b = System.time()
        app:draw()
        --local a = System.time()
        --drawtime = a - b
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







