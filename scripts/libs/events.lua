
Event={}

-- Call to post a notification, the arg is optional but will be forwarded along
function postEvent(notificationName,arg)
	local l=Event[notificationName]	or {};
	for i,v in ipairs(l) do
		if (v ~=nil) then
			v(arg);
		end
	end

end

-- call this to be notified, with the function to be called
-- here is a trick -- you can use lambdas for quick and easy functions
-- e.g. addListener("COUNTER_FOCUS_OBTAINED",function (arg) print "focused";end);
-- of course you can always just put a predefined fucntion in
function addListener(notificationName,func)
	Event[notificationName]=Event[notificationName] or {}; -- set it up
	local l=Event[notificationName]
	
	l[#l+1]=func;
	
end

-- call this to stop receiving notifications for a given function
function removeListener(notificationName,func)
		local l=Event[notificationName];
		for i = 1,#l do
			if (l[i] == func) then
				l[i]=nil;
			end
		end
end


--[[
addListener("A_NOTIFICATION",a)
addListener("B_NOTIFICATION",b)
addListener("C_NOTIFICAITON",c)
addListener("ABC_NOTIFICATION",a)
addListener("ABC_NOTIFICATION",b)
addListener("ABC_NOTIFICATION",c)


postEvent("A_NOTIFICATION") -- print a
postEvent("ABC_NOTIFICATION") -- print abc

print ("removing a from a notification")
removeListener("A_NOTIFICATION",a)


postEvent("A_NOTIFICATION") -- print a
postEvent("ABC_NOTIFICATION") -- print abc
--]]