-- libraries
package.path = "/Users/chrisallen/projects/desky/scripts/?.lua;" .. package.path
require "base"
dbg = require "libs/debugger"
require "libs/helper"
Tween = require "libs/tween"
_ = require "libs/underscore"
inspect = require "libs/inspect"
require "emma/app"



-- constants
runtime = 0;
starttime = 0;
drawtime = 0;
clock = os.clock

-- main functions

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
    AppDestroy();
    if(app~=nil) then
        destroying = true;
        app:destroy()
        collect()
        app = nil
        destroying = false;
    end
end

function collect()
    collectgarbage('collect')
end

function reload()
    print('main:reload', app)
    app = App:new()
end






-- touch

function  touchStarted(x,y)
end

function  touchMoved(x,y)
end

function  touchEnded(x,y)
end

