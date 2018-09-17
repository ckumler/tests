pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

poke(0x5f2d, 1) --set dev toolkit
local mx = stat(32) -- read x coord
local my = stat(33) -- read y coord
local levelfloor = 115
local particle_max = 600


particles = {
	--levelfloor needs to be set up as a global for this demo (value = y value of "floor")
	colorparticles = {},
	waterparticles = {},

	update=function(self)
		--update cparticles
		cls()
		rectfill(0,118,128,127,4)
		line(80,80,110,80,4)

		--sand particles
		for n_particle in all(self.colorparticles) do
			pset(n_particle.x,n_particle.y,0)

			if pget(n_particle.x,n_particle.y+1)==0 then
				n_particle.y += 1
			elseif pget(n_particle.x-1,n_particle.y+1)==0 then
				n_particle.x -= 1
			elseif pget(n_particle.x+1,n_particle.y+1)==0 then
				n_particle.x += 1
			elseif pget(n_particle.x-1,n_particle.y-1)==10 and pget(n_particle.x+1,n_particle.y)==0 and pget(n_particle.x,n_particle.y+1)==4  then
				n_particle.x += 1
			elseif pget(n_particle.x+1,n_particle.y-1)==10 and pget(n_particle.x-1,n_particle.y)==0 and pget(n_particle.x,n_particle.y+1)==4 then
				n_particle.x -= 1
			end

			pset(n_particle.x,n_particle.y,10)

		end


		--water particles
		for n_particle in all(self.waterparticles) do
			
			if pget(n_particle.x,n_particle.y)!=12 then
				while pget(n_particle.x,n_particle.y) != 0 do
					n_particle.y -= 1
					if pget(n_particle.x-1,n_particle.y) == 0 then
						n_particle.x -=1
					elseif pget(n_particle.x+1,n_particle.y) == 0 then
						n_particle.x +=1
					end
					n_particle.moving = "none"
					printh("going up")
				end
			end
			pset(n_particle.x,n_particle.y,0)
			if pget(n_particle.x,n_particle.y+1)==0 then
				n_particle.y += 1
				n_particle.moving = "none"
				printh("falling")
			elseif pget(n_particle.x-1,n_particle.y+1)==0 then
				n_particle.x -= 1
				n_particle.y += 1
				n_particle.moving = "none"
				printh("moving left down")
			elseif pget(n_particle.x+1,n_particle.y+1)==0 then
				n_particle.x += 1
				n_particle.y += 1
				n_particle.moving = "none"
				printh("moving right down")
			elseif n_particle.moving == "left" and pget(n_particle.x-1,n_particle.y)!=0 and (pget(n_particle.x,n_particle.y+1)==12 or pget(n_particle.x,n_particle.y+1)==10) then
				--was moving left, now blocked
				n_particle.moving = "none"
			elseif n_particle.moving == "right" and  pget(n_particle.x+1,n_particle.y)!=0 and (pget(n_particle.x,n_particle.y+1)==12 or pget(n_particle.x,n_particle.y+1)==10) then
				--was moving right, now blocked
				n_particle.moving = "none"
			elseif n_particle.moving == "left" and pget(n_particle.x-1,n_particle.y)==0 and (pget(n_particle.x,n_particle.y+1)==12 or pget(n_particle.x,n_particle.y+1)==10) then
				n_particle.x-=1
				n_particle.moving = "left"
				printh("moving left")
			elseif n_particle.moving == "right" and  pget(n_particle.x+1,n_particle.y)==0 and (pget(n_particle.x,n_particle.y+1)==12 or pget(n_particle.x,n_particle.y+1)==10) then
				n_particle.x+=1
				n_particle.moving = "right"
				printh("moving right")
			elseif pget(n_particle.x-1,n_particle.y)==0 and (pget(n_particle.x,n_particle.y+1)==12 or pget(n_particle.x,n_particle.y+1)==10) then
				n_particle.x-=1
				n_particle.moving = "left"
				printh("moving left")
			elseif pget(n_particle.x+1,n_particle.y)==0 and (pget(n_particle.x,n_particle.y+1)==12 or pget(n_particle.x,n_particle.y+1)==10) then
				n_particle.x+=1
				n_particle.moving = "right"
				printh("moving right")
			end

			pset(n_particle.x,n_particle.y,12)

		end
	end, -- end update

	drawcparticles=function(self)
		--draw cparticles
		for c_particle in all(self.colorparticles) do
			--pset(c_particle.x,c_particle.y,c_particle.colortable[c_particle.frame])
			pset(c_particle.x,c_particle.y,10)
			c_particle.frame+=1
		end

		for w_particle in all(self.waterparticles) do
			--pset(w_particle.x,w_particle.y,w_particle.colortable[w_particle.frame])
			pset(w_particle.x,w_particle.y,12)
			w_particle.frame+=1
		end
		
		if(#self.colorparticles >= particle_max) then
			print("too many sand particles!",18,50,7)
		end
		if(#self.waterparticles >= particle_max) then
			print("too many water particles!",15,60,7)
		end
	end,

	cleanup=function(self) -- clean up
		--cleanup cparticles
		for n_particle in all(self.colorparticles) do
			if(n_particle.frame == n_particle.decay) then
				n_particle.frame = 1
				--printh("particle frame = decay")
			elseif(n_particle.x < 0 or n_particle.x > 127 or n_particle.y < 0 or n_particle.y > 127) then
				del(self.colorparticles, n_particle)
				--printh("particle out of bounds")
			end	
		end
		for n_particle in all(self.waterparticles) do
			if(n_particle.frame == n_particle.decay) then
				n_particle.frame = 1
				--printh("particle frame = decay")
			elseif(n_particle.x < 0 or n_particle.x > 127 or n_particle.y < 0 or n_particle.y > 127) then
				del(self.waterparticles, n_particle)
				--printh("particle out of bounds")
			end	
		end
	end
} -- end particles

function particles:newcparticle(nx,ny)
	--printh("start new particle")
	if not ncolortable then
		ncolortable = {10,10,10}
	end
	local particle = {
		x=nx,
		y=ny,
		frame=1,
		decay=#ncolortable,
		colortable = ncolortable
		
	}

	if(#self.colorparticles < particle_max) then
		add(self.colorparticles,particle)
	end
end

function particles:newwparticle(nx,ny)
	--printh("start new particle")
	if not ncolortable then
		ncolortable = {12,12,12}
	end
	local particle = {
		x=nx,
		y=ny,
		moving=none, --none, left, right
		frame=1,
		decay=#ncolortable,
		colortable = ncolortable 
		
	}

	if(#self.waterparticles < particle_max) then
		add(self.waterparticles,particle)
	end
end


function update_m()
	mx = stat(32) -- read x coord
	my = stat(33) -- read y coord
end




function _init()
	
end
 

function _update60()
	update_m()


	if stat(34)==1 then
		particles:newcparticle(mx,my)
	end

	if stat(34)==2 then
		--del(particles.colorparticles, particles.colorparticles[#particles.colorparticles])
		particles:newwparticle(mx,my)
	end


	
  	particles:update()
  	particles:cleanup()




end
 

function _draw()
	--cls()
	--rectfill(0,118,128,127,4)
	--line(80,80,110,80,4)
	spr(1,mx-1,my-1)
	--particles:drawcparticles()
	print("mx = " .. mx,0,5,7)
	print("my = " .. my,0,15,7)
  	print("#cp = " .. #particles.colorparticles,0,25,7)
  	print("#wp = " .. #particles.waterparticles,0,35,7)
end
__gfx__
00000000070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700070000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
