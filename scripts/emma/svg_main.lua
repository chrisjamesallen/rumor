SVG = Class()
local pattern = "(%D)(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*)%s?"

function SVG:init()
    self.hull = SVGHull:new()
    self.curves = {}
    self.curves.concave = SVGCurves:new()
    return self;
end

function SVG:extract(str)
    self.hullData = self.hull:extract(str)
    self.curveData = self.curves.concave:extract(str)
    print("finish extract baby")
    return data;
end


SVGShape = Class()

function SVGShape:init()
    self.data_ = {};
    self.pos = {x=0,y=0,cx=0,cy=0};
    self.startPos = {};
    self.paths = {};
    self.texData = {}
    return self; --
end

function SVGShape:openSubPath(operations)
    local path = {}
    _.push(self.paths, path)
    self.data_ = path
    self.data_index = #self.paths
end

function SVGShape:closeSubPath(operations)
    if (#operations == 0) then
        return nil
    end
    self:convertSvgToPoints(operations)
   -- inspect(self.data_)
    self.data_ = _.flatten(self.data_)
    self:normalizeData(self.data_)
    self.paths[self.data_index] = self.data_
    return self.data_
end

function SVGShape:convertSvgToPoints(operations)
    return operations
end

function SVGShape:normalizeData(data)
    local maxX = 500
    local maxY = 500
    local min = 0
    for k, v in pairs(data) do
        local n = v --between 0 and 1
        if (k % 3 == 1) then
            n = (v - min) / (maxX - min)
            n = ((n * 2) - 1)
            -- so zero x should be -1
        end
        if (k % 3 == 2) then
            n = (v - min) / (maxY - min)
            n = -((n * 2) - 1)
            -- so zero y should be -1
        end

        data[k] = n
        --print(k,self.data_[k])
    end
end



function SVGShape:triangulate()
    local subPath = 0
    local subPaths = {}
    local t
    _.each(self.paths, function(data)
        local data_ = _.flatten(data)
        subPath = subPath + 1
        if (_.is_empty(data) == false) then
            local a = 0
            data_ = _.select(data_, function(i) a = a + 1; return a % 3 ~= 0 end)
            t = gpc.new():add(data_)
            _.push(subPaths, t)
        end
    end)

    local pool = {};
    local p = _.first(subPaths)
    _.each(_.rest(subPaths), function(path)
        p = p * path;
    end)
    self:plottri(pool, p:strip(), 0, 0, 0, 0);
    self.data_ = pool
    self.count = math.ceil(#pool / 3) -- this is cause there are three points to each vertex
    self.points = #self.data_
    self.vertices = self.data_
end


function SVGShape:output(data, x, y, command)
    _.push(data, x)
    _.push(data, y)
    _.push(data, 0)
end

function SVGShape:plottri(f, p, r, g, b)
    --if command=="stroke" then output(f,0,"setlinewidth") end
    for c = 1, p:get() do
        local n = p:get(c)
        local x1, y1 = p:get(c, 1)
        local x2, y2 = p:get(c, 2)
        for i = 3, n do
            local x, y = p:get(c, i)
            self:output(f, x1, y1)
            self:output(f, x2, y2)
            self:output(f, x, y)
            x1, y1, x2, y2 = x2, y2, x, y
        end
    end
end

-- formula helpers

function SVGShape:cubicBezier(A, B, C, D, t)
    local E = A:mix(B, t)
    local F = B:mix(C, t)
    local G = C:mix(D, t)
    return self:quadBezier(E, F, G, t)
end


function SVGShape:quadBezier(A, B, C, t)
    local D = A:mix(B, t)
    local E = B:mix(C, t)
    local P = D:mix(E, t)
    return P
end

function SVGShape:normalizeOutput(data, w, h)
    -- normalize here
    local maxX = w or 500
    local maxY = h or 500
    local min = 0
    -- inverse to follow top left origin
    for k, v in pairs(data) do
        local n = v --between 0 and 1
        if (k % 3 == 1) then
            n = (v - min) / (maxX - min)
            n = ((n * 2) - 1)
            -- so zero x should be -1
        end
        if (k % 3 == 2) then
            n = (v - min) / (maxY - min)
            n = -((n * 2) - 1)
            -- so zero y should be -1
        end

        data[k] = n
    end
end

return SVG  ;

