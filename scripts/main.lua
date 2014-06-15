-- so here we are going to require all the relevant libraries...
package.path = "/Users/chrisallen/projects/desky/scripts/?.lua;" .. package.path
-- require some stuff
require "base"
require "emma"
require "emma/app"




-- Main
 


function main()
    --called from c..
    print("main")
    emma = Emma();
    collect()
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







