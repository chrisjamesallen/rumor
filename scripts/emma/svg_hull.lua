SVGHull = SVGShape:extend()
local pattern = "(%D)(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*),?%s?(-?[0-9]*%.?[0-9]*)%s?"



function SVGHull:extract(svgStr)
    print("\n\nSvg:Extract Hull:\n", svgStr, "\n")
    local operations = {}
    self:openSubPath()
    for command, x1, y1, x2, y2, x3, y3 in string.gmatch(svgStr, pattern) do
        if (command == "z" or command == "Z") then
            self:closeSubPath(operations)
            self:openSubPath()
        end
        local op = {}
        op = { tonumber(x1) or 0, tonumber(y1) or 0, tonumber(x2) or 0, tonumber(y2) or 0, tonumber(x3) or 0, tonumber(y3) or 0 }
        op["command"] = command;
        _.push(operations, op)
    end
    self.data_index = self.data_index - 1
    _.pop(self.paths) --will always have an extra path redundant due to loop
    self:triangulate()
    return self
end


function SVGHull:convertSvgToPoints(operations)
    _.each(operations, function(i)
        if i.command == 'M' then
            _.push(self.data_, { i[1], i[2], 0 })
            self.pos.x = i[1]
            self.pos.y = i[2]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        --lineto
        if i.command == 'L' then
            self.pos.x = i[1]
            self.pos.y = i[2]
            _.push(self.data_, { i[1], i[2], 0 })
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        if i.command == 'l' then
            self.pos.x = self.pos.x + i[1]
            self.pos.y = self.pos.y + i[2]
            _.push(self.data_, { self.pos.x , self.pos.y, 0 })
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        --h line
        if i.command == 'h' then
            _.push(self.data_, { self.pos.x + i[1], self.pos.y, 0 })
            self.pos.x = self.pos.x + i[1]
            self.pos.y = self.pos.y
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        if i.command == 'H' then
            _.push(self.data_, { i[1], self.pos.y, 0 })
            self.pos.x = i[1]
            self.pos.y = self.pos.y
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end -- y param
        -- v line
        if i.command == 'v' then
            _.push(self.data_, { self.pos.x, self.pos.y + i[1], 0 })
            self.pos.x = self.pos.x
            self.pos.y = self.pos.y + i[1]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        if i.command == 'V' then
            _.push(self.data_, { self.pos.x, i[1], 0 })
            self.pos.x = self.pos.x
            self.pos.y = i[1]
            self.pos.cx = self.pos.x
            self.pos.cy = self.pos.y
        end
        -- Cubic curveto C (c)
        if i.command == 'c' then
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(self.pos.x + i[1], self.pos.y + i[2], 0)
            local cp2 = vec3(self.pos.x + i[3], self.pos.y + i[4], 0)
            local ep = vec3(self.pos.x + i[5], self.pos.y + i[6], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2)
            _.push(self.data_, { ep.x, ep.y, 0 })
            self.pos.x = i[5] + self.pos.x
            self.pos.y = i[6] + self.pos.y
            self.pos.cx = i[3]  + self.pos.x
            self.pos.cy = i[4] + self.pos.y
        end
        if i.command == 'C' then
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(i[1], i[2], 0)
            local cp2 = vec3(i[3], i[4], 0)
            local ep = vec3(i[5], i[6], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2)
            _.push(self.data_, { ep.x, ep.y, 0 })
            self.pos.x = i[5]
            self.pos.y = i[6]
            self.pos.cx = i[3]
            self.pos.cy = i[4]
        end
        -- Cubic shorthand curveto S (s)
        if i.command == 's' then
            -- take the previous control point and mirror
            local c1x, c1y
            c1x = ((self.pos.cx - self.pos.x) * -1) + self.pos.x
            c1y = ((self.pos.cy - self.pos.y) * -1) + self.pos.y
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(c1x, c1y, 0)
            local cp2 = vec3(self.pos.x + i[1], self.pos.y + i[2], 0)
            local ep = vec3(self.pos.x + i[3], self.pos.y + i[4], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2)
            _.push(self.data_, { ep.x, ep.y, 0 })
            self.pos.x = self.pos.x + i[3]
            self.pos.y = self.pos.y + i[4]
            self.pos.cx = self.pos.x + i[1]
            self.pos.cy = self.pos.y + i[2]
        end
        if i.command == 'S' then
            local c1x = ((self.pos.cx - self.pos.x) * -1) + self.pos.x
            local c1y = ((self.pos.cy - self.pos.y) * -1) + self.pos.y
            local sp = vec3(self.pos.x, self.pos.y, 0)
            local cp1 = vec3(c1x, c1y, 0)
            local cp2 = vec3(i[1], i[2], 0)
            local ep = vec3(i[3], i[4], 0)
            local a = self:cubicBezier(sp, cp1, cp2, ep, 0.5)
            self:determineCurveRightSide(a, sp, cp1, cp2)
            _.push(self.data_, { ep.x, ep.y, 0 })
            self.pos.x = i[3]
            self.pos.y = i[4]
            self.pos.cx = i[1]
            self.pos.cy = i[2]
        end
    end)

    return operations
end


function SVGHull:determineCurveRightSide(midCurve, sp, cp1, cp2)
    -- take the curve and determine from the mid point if curve is concave or convex
    local i = midCurve
    if (i.x < sp.x) then
        --convex (outside)
        --use midpoint
        print('convex')
        _.push(self.data_, { i.x, i.y, i.z })
    else
        --concave (inside
        --use two cps
        print("concave")
        _.push(self.data_, { cp1.x, cp1.y, cp1.z })
        _.push(self.data_, { cp2.x, cp2.y, cp2.z })
    end
end
return SVGHull;
