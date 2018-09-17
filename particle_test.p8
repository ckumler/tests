pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

local levelfloor = 115


--colortables
--{7,12,13,1,13,12,7,12,13,1,13,12,7,12,13,1,13,12,7}
--{7,7,7,10,10,9,10,9,10,9,9,8,9,8,9,8,8,9,8,9,9,6,9,6,9,6,5,5,5,5,5}

--spritetables
--{64,65,66,67,66,65,64,65,66,67,66,65,64,65,66,67,66,65,64,65,66,67,66,65,64}

--use particles:newcparticle(nx,ny,nxvol,nyvol,nframe,ngravity) for colored particles
--use particles:newsparticle(nx,ny,nxvol,nyvol,nframe,ngravity) for sprited particles

--need to figure out how to pass tables in to functions. :(




player = {
	x=64,
	y=110,
	xvol=0,
	yvol=0,
	grav=.25,
	friction=.25, -- default=.25
	maxfallspd=6,
	maxxspd=3,
	jumpforce=-4, --negative number
	isjumping=false,
	updatepos=function(self)
		--movex
		if (btn(0) and self.xvol > (self.maxxspd*-1)) then
			self.xvol -= .25
		elseif (btn(1) and self.xvol < self.maxxspd) then
		 	self.xvol += .25
		end

		--friction
		if (self.xvol != 0 and self.y == 110 and (btn(0) == false and btn(1) == false)) then
			if(self.xvol < 0) then
				self.xvol += self.friction
			elseif (self.xvol > 0) then
				self.xvol -= self.friction
			end
		end

		--movey
 		if (btn(2) and self.isjumping == false) then 
 			self.yvol = self.jumpforce
 			self.isjumping = true
 		elseif (btn(2) and self.isjumping==true) then
 			self.yvol -= self.grav/2
  		elseif btn(3) then
  			self.yvol += .25
  		end

		self.x += flr(self.xvol)
		self.y += flr(self.yvol)

		--y collision + grav
		if (self.y<110 and self.yvol < self.maxfallspd) then
			self.yvol+=self.grav
		end

		if (self.y < 10) then
			self.y = 10
			self.yvol = 1	
		elseif (self.y>110) then
			self.y=110
			self.yvol=0
		end

		--x collision
		if (self.x>120) then
			self.x=120
			self.xvol=0
		elseif (self.x<0) then
			self.x=0
			self.xvol=0
		end

		if (self.y==110) then
			self.isjumping = false
		end
	end,

	draw = function(self)
		spr(1,self.x, self.y)
	end
} -- end player




particles = {
	--levelfloor needs to be set up as a global for this demo (value = y value of "floor")
	colorparticles = {},
	spriteparticles= {},

	update=function(self)
		--update cparticles
		for n_particle in all(self.colorparticles) do
			if(n_particle.gravity == true) then
				n_particle.yvol += .25
			end
			n_particle.x += n_particle.xvol
			n_particle.y += n_particle.yvol

			--add bounce at floor
			if(n_particle.y >= levelfloor) then
				n_particle.y = levelfloor
				n_particle.yvol = (n_particle.yvol/2)*-1
				--n_particle.xvol = n_particle.xvol/2
			end

		end

		--update sparticles
		for n_particle in all(self.spriteparticles) do
			if(n_particle.gravity == true) then
				n_particle.yvol += .25
			end
			n_particle.x += n_particle.xvol
			n_particle.y += n_particle.yvol

			--add bounce at floor
			if(n_particle.y >= levelfloor) then
				n_particle.y = levelfloor
				n_particle.yvol = (n_particle.yvol/2)*-1
				--n_particle.xvol = n_particle.xvol/2
			end

		end
		--printh("update particles")
	end,

	drawcparticles=function(self)
		--draw cparticles
		for c_particle in all(self.colorparticles) do
			pset(c_particle.x,c_particle.y,c_particle.colortable[c_particle.frame])
			c_particle.frame+=1
		end
		--draw sparticles
		for s_particle in all(self.spriteparticles) do
			spr(s_particle.spritetable[s_particle.frame],s_particle.x,s_particle.y)
			s_particle.frame+=1
		end
		--printh("draw particles")
	end,

	cleanup=function(self) -- clean up
		--cleanup cparticles
		for n_particle in all(self.colorparticles) do
			if(abs(n_particle.xvol) < 1 and abs(n_particle.yvol) < 1) then
				del(self.colorparticles, n_particle)
			elseif(n_particle.frame == n_particle.decay) then
				del(self.colorparticles, n_particle)
				--printh("particle frame = decay")
			elseif(n_particle.x < 0 or n_particle.x > 127 or n_particle.y < 0 or n_particle.y > 127) then
				del(self.colorparticles, n_particle)
				--printh("particle out of bounds")
			end	
		end

		--cleanup sparticles
		for n_particle in all(self.spriteparticles) do
			if(abs(n_particle.xvol) < 1 and abs(n_particle.yvol) < 1) then
				del(self.spriteparticles, n_particle)
			elseif(n_particle.frame == n_particle.decay) then
				del(self.spriteparticles, n_particle)
				--printh("particle frame = decay")
			elseif(n_particle.x < 0 or n_particle.x > 127 or n_particle.y < 0 or n_particle.y > 127) then
				del(self.spriteparticles, n_particle)
				--printh("particle out of bounds")
			end	
		end
	end
} -- end particles

function particles:newcparticle(nx,ny,nxvol,nyvol,nframe,ngravity)
	--printh("start new particle")
	if not ncolortable then
		ncolortable = {7,12,13,1,13,12,7,12,13,1,13,12,7,12,13,1,13,12,7}
	end
	if not nxvol then
		nxvol = rand(2)-1
	end
	if not nyvol then
		nyvol = rand(2)-1
	end
	if not nframe then
		nframe = 1
	end
	if not nframe then
		nframe = 1
	end
	if not ngravity then
		ngravity = true
	end
	local particle = {
		x=nx,
		y=ny,
		xvol=nxvol,
		yvol=nyvol,
		frame=nframe,
		decay=#ncolortable,
		gravity = ngravity,
		colortable = ncolortable
		
	}
	add(self.colorparticles,particle)
	printh(particle.x .. ", " .. particle.y .. ", " .. particle.xvol .. ", " .. particle.yvol .. ", " .. particle.frame .. ", " .. particle.decay .. ", " .. particle.colortable[1])
end

function particles:newsparticle(nx,ny,nxvol,nyvol,nframe,ngravity)
	--printh("start new particle")
	if not nspritetable then
		nspritetable = {64,65,66,67,66,65,64,65,66,67,66,65,64,65,66,67,66,65,64,65,66,67,66,65,64}
	end
	if not nxvol then
		nxvol = rand(2)-1
	end
	if not nyvol then
		nyvol = rand(2)-1
	end
	if not nframe then
		nframe = 1
	end
	if not nframe then
		nframe = 1
	end
	if not ngravity then
		ngravity = true
	end
	local particle = {
		x=nx,
		y=ny,
		xvol=nxvol,
		yvol=nyvol,
		frame=nframe,
		decay=#nspritetable,
		gravity = ngravity,
		spritetable = nspritetable
		
	}
	add(self.spriteparticles,particle)
	printh(particle.x .. ", " .. particle.y .. ", " .. particle.xvol .. ", " .. particle.yvol .. ", " .. particle.frame .. ", " .. particle.decay .. ", " .. particle.spritetable[1])
end

function testcparticle()
  local x = player.x
  local y = player.y
  local random1 = ((flr(rnd(4))+1)*(flr(rnd(3))-1))
  local random2 = ((flr(rnd(4))+1)*(flr(rnd(3))-1))
  local random3 = (flr(rnd(3+1)))
  local randombool
  if (rnd(1) == 0 ) then
  	randombool = false
  else
  	randombool = true
  end
  printh(random1 .. ", " .. random2 .. ", " .. random3 .. ", ")
  particles:newcparticle(x+4,y,random1, random2, random3)
end

function testsparticle()
  local x = player.x
  local y = player.y
  local random1 = ((flr(rnd(4))+1)*(flr(rnd(3))-1))
  local random2 = ((flr(rnd(4))+1)*(flr(rnd(3))-1))
  local random3 = (flr(rnd(3+1)))
  local randombool
  if (rnd(1) == 0 ) then
  	randombool = false
  else
  	randombool = true
  end
  printh(random1 .. ", " .. random2 .. ", " .. random3 .. ", ")
  particles:newsparticle(x+4,y,random1, random2, random3)
end

function testcparticlefountain()
  local x = player.x
  local y = player.y
  local random1 = ((flr(rnd(1))+1)*(flr(rnd(3))-1))
  local random2 = (flr(rnd(3))+1)*-1
  local random3 = (flr(rnd(3+1)))
  local randombool
  if (rnd(1) == 0 ) then
  	randombool = false
  else
  	randombool = true
  end
  printh(random1 .. ", " .. random2 .. ", " .. random3 .. ", ")
  particles:newcparticle(94,110,random1, random2, random3, false)
end





function _init()
	
end
 

function _update()
  player:updatepos()
  particles:update()
  particles:cleanup()
if btn(5) then
	testsparticle()
	testsparticle()
	testsparticle()
	testsparticle()
	testsparticle()
	testsparticle()
	testsparticle()
end

testcparticlefountain()
testcparticlefountain()
testcparticlefountain()


end
 

function _draw()
	cls()
	rectfill(0,118,128,127,3)
	player:draw()
	particles:drawcparticles()
	spr(2,90,110)

  	print("x = " .. player.x,0,5,7)
  	print("y = " .. player.y,0,15,7)
  	print("xvol = " .. player.xvol,0,25,7)
  	print("yvol = " .. player.yvol,0,35,7)
  	print("#cp = " .. #particles.colorparticles,0,45,7)
  	print("#sp = " .. #particles.spriteparticles,0,55,7)
end





__gfx__
00000000099999900006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000091991900000600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700091991900055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000091991900055555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000099999900006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700099999900006660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999900555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099999900555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c00000070700000c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00c000000c7c000000c0000070707000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000c00000070700000c0c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
