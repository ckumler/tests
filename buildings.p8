pico-8 cartridge // http://www.pico-8.com
version 16
__lua__


function drawbuildings()
	rectfill(0,0,127,127,12)
	rectfill(0,0,36,127,5)
	rectfill(82,0,127,127,5)
	rectfill(0,0,35,127,6)
	rectfill(83,0,127,127,6)
	rectfill(0,0,5,127,5)
	rectfill(9,0,14,127,5)
	rectfill(18,0,23,127,5)
	rectfill(27,0,32,127,5)
	rectfill(122,0,127,127,5)
	rectfill(113,0,118,127,5)
	rectfill(104,0,109,127,5)
	rectfill(95,0,100,127,5)
	rectfill(86,0,91,127,5)

	for i=20,140,20 do
		line(0,i,36,i-3,5)
		line(82,i-4,124,i,5)
	end
end

local clouds{}

function getcloud()
	
end

function _init()
end


function _draw()
cls()

end
