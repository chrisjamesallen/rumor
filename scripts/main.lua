-- so here we are going to require all the relevant libraries...
package.path = "/Users/chrisallen/projects/desky/scripts/?.lua;" .. package.path
-- require some stuff
require "base"
require "emma"
require "emma/app"
-- Main
main = Class:extend()

function main:init()
    --called from c
    self.__super:init()
    self.name = "main"
    print("running main...")
    --app:ready()
end

function main:update ()
    return "update"
end

function main:draw()
    print(self)
end

function main:touchStarted(x,y)
end

function main:touchMoved(x,y)
end

function main:touchEnded(x,y)
end






