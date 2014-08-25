

function sleep(n)
    os.execute("sleep " .. tonumber(n))
end

function wait(n)  -- seconds
    local t0 = clock()
    while clock() - t0 <= n do end
end
