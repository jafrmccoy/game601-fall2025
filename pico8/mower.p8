pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
 --tells game which screen
 --to draw
	screen=0
	nextlvl=false

	--sets delay for btnp
	poke(0x5f5c,255)
	
	--player
	make_player()
	init_atk()	
	init_life()
	
	--enemy
	init_enemy()
	spawn_enemy()
end

function _update()

	if (screen==0 and btnp(❎)) then
		next_level()
	end
	
	update_player()
	update_enemy()
	update_pickup()
	
end

function _draw()
	cls()
	map(screen*16,0,0,0,16,16)
	if screen==0 then
		print("mower",center_text("mower"),72,8)
		print("press ❎ to start",center_text("press xx to start"),78,8)
		draw_enemy()
	else
		map(screen*16,0,0,0,16,16)
		draw_enemy()
		if p.alive then
			draw_player()
		else
			draw_gameover()
		end
		draw_life()
		draw_pickup()
		draw_atk()
	end
	
end
-->8
function make_player()
	p={}
	p.x=64 --position
	p.y=16
	p.state=0 --current player state
	p.spr=0 --sprite
	p.dir=1 --direction
	p.sprdir=0 --sprite direction
	p.pat=0 --player state timer
	p.bndx1=-1 --player bounds
	p.bndx2=121
	p.bndy1=15
	p.bndy2=121
	p.tilex=0 --player map tile
	p.tiley=0
	p.atk=false
	p.atkhoriz=true --atk horiz (true) or vert (false)
	p.alive=true
	p.score=0
	p.tilesmowed=0
	--pickups
	--pup = pickup
	p.pups=0
	
	p.col=false
end

function change_state(s)
	p.state=s
	p.pat=0
end

function die_player()
	--take a life
	life-=1
	if life<0 then
		--game over
		p.alive=false
	else
		--reset player
		p.spr=0
		p.atkhoriz=true
		p.x=64
		p.y=16
		p.dir=1
		p.sprdir=0
		
		change_state(4)
	end

end

function update_player()
	b0=btn(0)
	b1=btn(1)
	b2=btn(2)
	b3=btn(3)
	bx=btn(❎)
	
	--player map tiles
	p.tilex=((p.x+7)\8)+(16*screen)
	p.tiley=(p.y+7)\8

	p.pat+=1 --inc state clock
	
	if p.alive then
	
		if p.state==4 then
			--after death
			if p.pat==15 then
				change_state(0)
			end
		elseif (not p.atk) then
			--idle state
			if p.state==0 then
				p.spr=0
				p.atkhoriz=true
				--replace tile
				if map_collision(p.tilex,p.tiley,0) then
					map_replace(p.tilex,p.tiley,17)
					p.score+=10
					p.tilesmowed+=1
				end
				if (b0 or b1) change_state(1)
				if (b2)  change_state(2)
				if (b3) change_state(3)
			end
			
			--walk state horiz
			if p.state==1 then
				p.atkhoriz=true
				if (b0) then
					p.dir=-1
					p.sprdir=-1
					p.tilex=((p.x+7)\8)+(16*screen)
				end
				if (b1) then
					p.dir=1
				 p.sprdir=1
				 p.tilex=((p.x)\8)+(16*screen)
				end
				
				--if tile is dirt left
				if b0 and map_collision(p.tilex+p.dir,p.tiley,0) then
					p.col=true
					--check bounds
					if (p.x+p.dir>p.bndx1 and p.x+p.dir<p.bndx2) then
						--move
						p.x+=p.dir			
					end
				--if tile is dirt right
				elseif b1 and map_collision(p.tilex+p.dir,p.tiley,0) then
					p.col=true
					--check bounds
					if (p.x+p.dir>p.bndx1 and p.x+p.dir<p.bndx2) then
						--move
						p.x+=p.dir			
					end							
				else --if tile is not dirt
					p.col=false
					--check bounds
					if (p.x+(p.dir*2)>p.bndx1 and p.x+(p.dir*2)<p.bndx2) then
						--move
						if (not((p.x+(p.dir*2))%8==1)) then
							p.x+=p.dir*2
						else
							p.x+=p.dir
						end
					elseif (p.x+p.dir>p.bndx1 and p.x+p.dir<p.bndx2) then
						p.x+=p.dir
					end
				end
				
				--replace
				if map_collision(p.tilex,p.tiley,0) then
					map_replace(p.tilex,p.tiley,17)			
					p.score+=10
					p.tilesmowed+=1
				end
				
				p.spr=flr(p.pat/2)%2
				
				--check if sprite on whole tile
				if ((p.x)%8==0) then		
					if (not (b0 or b1)) change_state(0)
					if b2 and not (b0 or b1) then
					 change_state(2)
					end
					if b3 and not (b0 or b1) then
					 change_state(3)
					end
				end
			end
			
			--walk state up
			if p.state==2 then
					p.atkhoriz=false
					p.dir=-1
				 p.sprdir=1
					p.tiley=(p.y+7)\8
				
				--if tile is dirt
				if map_collision(p.tilex,p.tiley+p.dir,0) then
					p.col=true
					--check bounds
					if (p.y+p.dir>p.bndy1 and p.y+p.dir<p.bndy2) then
						--move
						p.y+=p.dir
					end
				else --if tile is not dirt
					p.col=false
					--check bounds
					if (p.y+(p.dir*2)>p.bndy1 and p.y+(p.dir*2)<p.bndy2) then
						--move
						p.y+=p.dir*2
					elseif (p.y+p.dir>p.bndy1 and p.y+p.dir<p.bndy2) then
						p.y+=p.dir
					end	
				end
				
				--replace
				if map_collision(p.tilex,p.tiley,0) then
					map_replace(p.tilex,p.tiley,17)
					p.score+=10
					p.tilesmowed+=1
				end
				
				p.spr=(flr(p.pat/2)%2)+2
				
				--check if sprite on whole tile
				if ((p.y)%8==0) then
					if (not b2) then
						p.sprdir=-1
						change_state(0)
					end
					if (b0 or b1) and not b2 then
						change_state(1)
					end
					if b3 and not b2 then
						change_state(3)
					end
				end
			end
			
			--walk state down
			if p.state==3 then
					p.atkhoriz=false
					p.dir=1
				 p.sprdir=1
				 p.tilex=(p.x\8)+(16*screen)
					p.tiley=p.y\8
				
				--if tile is dirt
				if map_collision(p.tilex,p.tiley+p.dir,0) then
					p.col=true
					--check bounds
					if (p.y+p.dir>p.bndy1 and p.y+p.dir<p.bndy2) then
						--move
						p.y+=p.dir
					end
				else --if tile is not dirt
					p.col=false
					--check bounds
					if (p.y+(p.dir*2)>p.bndy1 and p.y+(p.dir*2)<p.bndy2) then
						--move
						p.y+=p.dir*2
					elseif (p.y+p.dir>p.bndy1 and p.y+p.dir<p.bndy2) then
						p.y+=p.dir
					end	
				end
				
				--replace
				if map_collision(p.tilex,p.tiley,0) then
					map_replace(p.tilex,p.tiley,17)
					p.score+=10
					p.tilesmowed+=1
				end
				
				p.spr=(flr(p.pat/2)%2)+4
				
				--check if sprite on whole tile
				if ((p.y)%8==0) then
					if (not b3) change_state(0)
					if (b0 or b1) and not b3 then
						change_state(1)
					end
					if b2 and not b3 then
						change_state(2)
					end
				end
			end
		end
		
		--attack
		if bx then
			p.atk=true
			update_atk()
		else
			p.atk=false
		end
	end
end

function draw_player()
	if screen>0 then
		spr(p.spr,p.x,p.y,1,1,p.sprdir==-1)
	end
	print("score:"..p.score,80,0)
	
	--print("p.tilex:"..p.tilex,0,32)
	--print("p.tiley:"..p.tiley)
	
	--if p.col then
	--	print("col detected",64,64)
	--else
	--	print("no col",64,64)
	--end
	
	--print("p.x="..p.x)
	--print("p.x%8="..(p.x%8))
end

function draw_gameover()

	print("game over",center_text("game over"),64,8)
	print("final score:",center_text("final score:"),70,8)
	print(p.score,center_text(tostr(p.score)),76,8)

end

function center_text(s)
	return 64-(#s*2)
end
-->8
function map_collision(tile_x, tile_y, flag)
	map_x1=16*screen
	map_x2=map_x1+15
	map_y1=0
	map_y2=map_y1+15
	
	if (tile_x<map_x1 or tile_x>map_x2 or
		tile_y<map_y1 or tile_y>map_y2) then
		return false
	else
	 return fget( mget(tile_x,tile_y), flag)
	end
end

function map_replace(tile_x, tile_y, sprite)
	mset(tile_x,tile_y,sprite)
end
-->8
function init_atk()
	atk={}
	atk.spr=9
	atk.x=0
	atk.y=0
	atk.range=16
end

function update_atk()
 
 --update attack location
 --based on player pos & dir
 if p.atkhoriz then
 	atk.x=p.x+(p.dir*8)
 	atk.y=p.y
 	atk.spr=9
 else
		atk.x=p.x
		atk.y=p.y+(p.dir*8)
		atk.spr=10
	end
	
	--hit enemy
	foreach(enem,hit_enemy)
end

function draw_atk()
	if screen>0 then
		if (p.atk) then
			if p.atkhoriz then
				--draw horiz
			
				spr(atk.spr,atk.x,atk.y,1,1,p.dir==-1,false)
			else
				--draw vert
				spr(atk.spr,atk.x,atk.y,1,1,false,p.dir==-1)
			end
		end
	end
end

function hit_enemy(enemy)

	if (enemy.x<p.x+atk.range and enemy.x>=p.x and enemy.y==p.y and p.dir==1 and p.atkhoriz==true) then
	--enemy right, atk right
		del(enem,enemy)
		p.score+=50
	elseif (enemy.x>p.x-atk.range and enemy.x<=p.x and enemy.y==p.y and p.dir==-1 and p.atkhoriz==true) then
	--enemy left, atk left
		del(enem,enemy)
		p.score+=50
	
	elseif (enemy.y<p.y+atk.range and enemy.y>=p.y and enemy.x==p.x and p.dir==1 and p.atkhoriz==false) then
	--enemy down, atk down
		del(enem,enemy)
		p.score+=50
	
	elseif (enemy.y>p.y-atk.range and enemy.y<=p.y and enemy.x==p.x and p.dir==-1 and p.atkhoriz==false) then
	--enemy up, atk up
		del(enem,enemy)
		p.score+=50
	
	end
	
	--check if all enems gone
	if #enem==0 then
		--go to next level
		nextlvl=false
		next_level()
		--pts for beating level
		p.score+=100
	end

end
-->8
function init_enemy()
	enem={}
end

function spawn_enemy()

	for ix=0+(16*screen),15+(16*screen),1 do
		for iy=0,15,1 do
		
			--spawn red boys
			if map_collision(ix,iy,2) then
				
				red={}
				red.type=1
				red.x=(ix*8)-(128*screen)
				red.y=(iy*8)
				red.dir=1
				red.spr=6
				red.sprdir=1
				red.tilex=ix
				red.tiley=iy
				red.exist=true
				red.tag=(ix*1000)+iy
				add(enem,red)
				map_replace(red.tilex,red.tiley,49)
			
			--spawn green boys
			elseif map_collision(ix,iy,3) then
			
				green={}
				green={}
				green.type=2
				green.x=(ix*8)-(128*screen)
				green.y=(iy*8)
				green.dir=1
				green.spr=8
				green.sprdir=1
				green.atkspr=13
				green.atkdir=1
				green.flipy=false
				green.atk=false
				green.atkx=0
				green.atky=0
				green.atktime=0
				green.tilex=ix
				green.tiley=iy
				green.exist=true
				green.tag=(ix*1000)+iy
				add(enem,green)
				map_replace(green.tilex,green.tiley,49)
			end
		
		end
	end

end

function update_enemy()

	--go over all enemies
	foreach(enem,update_enem)
	

end

function update_enem(enemy)

	
	
	--red boys
	if enemy.type==1 then
	
		
			--right
			if enemy.dir==1 then
				enemy.sprdir=1
				
				if (not map_collision((enemy.x+8)\8+(16*screen),
				(enemy.y)\8,0)) and (enemy.x+7<127) then
					enemy.x+=0.5
				elseif not (enemy.x%8==0) then
					enemy.x+=0.5				
				else
					pick_dir(enemy)
				end
			
			--down
			elseif enemy.dir==2 then
			
				if (not map_collision((enemy.x)\8+(16*screen),
				(enemy.y+8)\8,0)) and (enemy.y+7<127) then
					enemy.y+=0.5
				elseif not (enemy.y%8==0) then
					enemy.y+=0.5				
				else
					pick_dir(enemy)
				end
			
			--left
			elseif enemy.dir==3 then
				enemy.sprdir=-1
			
				if (not map_collision((enemy.x-8)\8+(16*screen),
				(enemy.y)\8,0)) and (enemy.x-7>0) then
					enemy.x-=0.5
				elseif not (enemy.x%8==0) then
					enemy.x-=0.5				
				else
					pick_dir(enemy)
				end
			
			--up
			elseif enemy.dir==4 then
			
				if (not map_collision((enemy.x)\8+(16*screen),
				(enemy.y-8)\8,0)) and (enemy.y-7>16) then
					enemy.y-=0.5
				elseif not (enemy.y%8==0) then
					enemy.y-=0.5				
				else
					pick_dir(enemy)
				end
			
			end

			--player contact			
			if (abs(enemy.x-p.x)<8 and abs(enemy.y-p.y)<8) then
				--death buffer
				if not (p.x==64 and p.y==16) then
					die_player()
				end
			end
	
	end
	
	--green boys
	if enemy.type==2 then
	
		--player in range
		if (enemy.dir==1 and ((p.y==enemy.y and p.x>enemy.x and p.x<enemy.x+15) or enemy.atk==true)) then
			--right
			enemy.atkx=enemy.x+8
			enemy.atky=enemy.y
			enemy.atk=true
			enemy.atkdir=1
			enemy.flipy=false
			enemy.atkspr=13
			
		elseif (enemy.dir==2 and ((p.x==enemy.x and p.y>enemy.y and p.y<enemy.y+15) or enemy.atk==true)) then
			--down
			enemy.atkx=enemy.x
			enemy.atky=enemy.y+8
			enemy.atk=true
			enemy.atkdir=-1
			enemy.flipy=true
			enemy.atkspr=14
			
		elseif (enemy.dir==3 and ((p.y==enemy.y and p.x<enemy.x and p.x>enemy.x-15) or enemy.atk==true)) then
			--left
			enemy.atkx=enemy.x-8
			enemy.atky=enemy.y
			enemy.atk=true
			enemy.atkdir=-1
			enemy.flipy=false
			enemy.atkspr=13
			
		elseif (enemy.dir==4 and ((p.x==enemy.x and p.y<enemy.y and p.y>enemy.y-15) or enemy.atk==true)) then
			--up
			enemy.atkx=enemy.x
			enemy.atky=enemy.y-8
			enemy.atk=true
			enemy.atkdir=1
			enemy.flipy=false
			enemy.atkspr=14
		else
			enemy.atk=false
		end
		
		--atk timer
		if enemy.atk then
			enemy.atktimer+=1
			if enemy.atktimer==45 then	
				--player in range
				if (enemy.dir==1 and (p.y==enemy.y and p.x>enemy.x and p.x<enemy.x+15)) then
					--right
					enemy.atktimer=0
				elseif (enemy.dir==2 and (p.x==enemy.x and p.y>enemy.y and p.y<enemy.y+15)) then
					--down
					enemy.atktimer=0
				elseif (enemy.dir==3 and (p.y==enemy.y and p.x<enemy.x and p.x>enemy.x-15)) then
					--left
					enemy.atktimer=0
				elseif (enemy.dir==4 and (p.x==enemy.x and p.y<enemy.y and p.y>enemy.y-15)) then
					--up
					enemy.atktimer=0
				else				
					enemy.atk=false
				end
			end
		else
			enemy.atktimer=0
		end
		
		--movement
		if enemy.atk==false then
		
				--right
				if enemy.dir==1 then
					enemy.sprdir=1
					enemy.atkdir=1
					enemy.atkspr=13
					
					if (not map_collision((enemy.x+8)\8+(16*screen),
					(enemy.y)\8,0)) and (enemy.x+7<127) then
						enemy.x+=0.5
					elseif not (enemy.x%8==0) then
						enemy.x+=0.5				
					else
						pick_dir(enemy)
					end
				
				--down
				elseif enemy.dir==2 then
					enemy.sprdir=1
					enemy.atkdir=1
					enemy.atkspr=14
					
					if (not map_collision((enemy.x)\8+(16*screen),
					(enemy.y+8)\8,0)) and (enemy.y+7<127) then
						enemy.y+=0.5
					elseif not (enemy.y%8==0) then
						enemy.y+=0.5				
					else
						pick_dir(enemy)
					end
				
				--left
				elseif enemy.dir==3 then
					enemy.sprdir=-1
					enemy.atkdir=-1
					enemy.atkspr=13
					
					if (not map_collision((enemy.x-8)\8+(16*screen),
					(enemy.y)\8,0)) and (enemy.x-7>0) then
						enemy.x-=0.5
					elseif not (enemy.x%8==0) then
						enemy.x-=0.5				
					else
						pick_dir(enemy)
					end
				
				--up
				elseif enemy.dir==4 then
					enemy.sprdir=-1
					enemy.atkdir=-1
					enemy.atkspr=14
					
					if (not map_collision((enemy.x)\8+(16*screen),
					(enemy.y-8)\8,0)) and (enemy.y-7>16) then
						enemy.y-=0.5
					elseif not (enemy.y%8==0) then
						enemy.y-=0.5				
					else
						pick_dir(enemy)
					end
				
				end
		

		
		end
	
	end 
end

function pick_dir(enemy)

	if (abs((enemy.x+8-p.x))<abs(enemy.x-p.x)) and (not map_collision((enemy.x+8)\8+(16*screen),
		(enemy.y)\8,0)) then
		--right
		enemy.dir=1
	elseif (abs((enemy.y+8-p.y))<abs(enemy.y-p.y)) and (not map_collision((enemy.x)\8+(16*screen),
		(enemy.y+8)\8,0)) then
		--down
		enemy.dir=2
	elseif (abs((enemy.x-8-p.x))<abs(enemy.x-p.x)) and (not map_collision((enemy.x-8)\8+(16*screen),
		(enemy.y)\8,0)) then
		--left
		enemy.dir=3
	elseif (not map_collision((enemy.x)\8+(16*screen),
		(enemy.y-8)\8,0)) then
		--up
		enemy.dir=4
	elseif (not map_collision((enemy.x+8)\8+(16*screen),
		(enemy.y)\8,0)) then
		--right
		enemy.dir=1
	elseif (not map_collision((enemy.x)\8+(16*screen),
		(enemy.y+8)\8,0)) then
		--down
		enemy.dir=2
	elseif (not map_collision((enemy.x-8)\8+(16*screen),
		(enemy.y)\8,0)) then
		--left
		enemy.dir=3
	elseif (not map_collision((enemy.x)\8+(16*screen),
		(enemy.y-8)\8,0)) then
		--up
		enemy.dir=4
	end

end

function draw_enemy()
	foreach(enem,draw_enem)
end

function draw_enem(enemy)
	
	if enemy.exist then
		spr(enemy.spr,enemy.x,enemy.y,1,1,enemy.sprdir==-1)
		
		if enemy.type==2 then
			
		end
		
		if (enemy.atk==true and enemy.atktimer<15) then
			spr(enemy.atkspr,enemy.atkx,enemy.atky,1,1,enemy.atkdir==-1,enemy.flipy)
		end
	else
		del(enem,enemy)
	end
end
-->8
function init_life()
	life=2
	
	--for pickups
	pup={}
	pup.real=false --show pup?
	pup.spr=26
	pup.x=64
	pup.y=80
end

function draw_life()
	for i=0,life,1 do
		spr(0,8*i,0)
	end
end

function next_level()
	if nextlvl!=true then
		nextlvl=true
		if screen==0 then
			foreach(enem,del_all)
		end
		--reset player pos
		p.x=64
		p.y=16
		screen+=1
		spawn_enemy()
	end
end

function del_all(enemy)
	del(enem,enemy)
end

function update_pickup()
	if p.tilesmowed==10 then
		pup.real=true
	end
	
	if (pup.real and (p.x==pup.x and p.y==pup.y)) then
		pup.real=false
		p.score+=25
		p.pups+=1
		p.tilesmowed=-10
	end
end

function draw_pickup()
	if pup.real then
		spr(pup.spr,pup.x,pup.y)
	end
end
__gfx__
00000000000000000000000005888850006666000000000000000000000000000000000000000000000040000000000000000000000555500055550000000000
600000006000000005888850088ee88006000060006666000000099900000000022000000000000000004000000000888880000005566665056776500d050d05
6600000066000000088ee88008eeee800608806006000060000098980000000026000202000000000000900000008888888800905667776556777765dd55dd55
066000000660000008eeee80088ee880088ee88006088060900099990979979026000828000000000000900000088888898880905667776556777765dd55dd55
006eeee0006eeee0088ee8800608806008eeee80088ee880900099000979979022666222000007600006760000888888998889900056776556777760dd55dd55
00888888008888880608806006000060088ee88008eeee80999999000090090022222220000076760067676000888889798889900005666505677650dd55dd55
0065886500568856060000600066660005888850088ee880099990000000000002222220449967670076767008888899778888000000555000566500dd55dd55
005600560065006500666600000000000000000005888850000000000000000002202020000000000007670008888977988888000000000000055000dd55dd55
33333333bbbbbbbb0000000000333330000000000000000000000000000000000000000000000000a990000008889997888888000000000000000000dd55dd55
33333b33bbbbbbbb00888800033333330000000000000000000000000000000000000000000000000a90000000888888888880000000000000000000dd55dd55
33133333bbbbbbbb08888880303330300000000000000000000000000000000000000000000000000e88880000888888888880000000000000000000dd55dd55
33333333bbbbbbbb80000008033300000000000000000000000000000000000000000000000000000e81118000088888888800000000000000000000dd55dd55
33333333bbbbbbbb80088008333333330000000000000000000000000000000000000000000000000e18888000000888880000000000000000000000dd55dd55
33b33313bbbbbbbb08888880333333300000000000000000000000000000000000000000000000000e18118000000009900000000000000000000000dd55dd55
33333333bbbbbbbb00888800333333330000000000000000000000000000000000000000000000000e18818000000999900000000000000000000000dd55dd55
33333333bbbbbbbb08800880033003300000000000000000000000000000000000000000000000000e81118000000000000000000000000000000000dd55dd55
08000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0a411100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00141610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111161000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00511110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00055100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888444444442333333333333332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888888884434444423333b3333333b32000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888444444442313333333133332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888444444342333333333333332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888444444442333333333333332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
888888884434444423b3331333b33312000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888444444442333333333333332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
88888888444444442333333333333332000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000088ee0000000088ee000088eeeeee000088ee0000000088ee0088eeeeeeee0088eeeeee000000000000000000000000000000000000000000000000000000
000088ee0000000088ee000088eeeeee000088ee0000000088ee0088eeeeeeee0088eeeeee000000000000000000000000000000000000000000000000000000
000088eeee000088eeee0088ee000088ee0088ee0000000088ee0088ee0000000088ee0088ee0000000000000000000000000000000000000000000000000000
000088eeee000088eeee0088ee000088ee0088ee0000000088ee0088ee0000000088ee0088ee0000000000000000000000000000000000000000000000000000
000088ee88ee88ee88ee0088ee000088ee0088ee0000000088ee0088ee0000000088ee0088ee0000000000000000000000000000000000000000000000000000
000088ee88ee88ee88ee0088ee000088ee0088ee0000000088ee0088ee0000000088ee0088ee0000000000000000000000000000000000000000000000000000
000088ee0088ee0088ee0088ee000088ee0088ee0088ee0088ee0088eeeeee000088eeeeee000000000000000000000000000000000000000000000000000000
000088ee0088ee0088ee0088ee000088ee0088ee0088ee0088ee0088eeeeee000088eeeeee000000000000000000000000000000000000000000000000000000
000088ee0000000088ee0088ee000088ee0088ee88ee88ee88ee0088ee0000000088ee0088ee0000000000000000000000000000000000000000000000000000
000088ee0000000088ee0088ee000088ee0088ee88ee88ee88ee0088ee0000000088ee0088ee0000000000000000000000000000000000000000000000000000
000088ee0000000088ee0088ee000088ee0088eeee000088eeee0088ee0000000088ee0088ee0000000000000000000000000000000000000000000000000000
000088ee0000000088ee0088ee000088ee0088eeee000088eeee0088ee0000000088ee0088ee0000000000000000000000000000000000000000000000000000
000088ee0000000088ee000088eeeeee000088ee0000000088ee0088eeeeeeee0088ee0088ee0000000000000000000000000000000000000000000000000000
000088ee0000000088ee000088eeeeee000088ee0000000088ee0088eeeeeeee0088ee0088ee0000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000088ee000088ee00088eeeeee000088ee000088ee000088ee0000000088ee088ee088ee000088ee088ee000000000000000000000000000000000000000000
000088ee000088ee00088eeeeee000088ee000088ee000088ee0000000088ee088ee088ee000088ee088ee000000000000000000000000000000000000000000
000088ee000088ee088ee000088ee0088ee000088ee000088ee0000000088ee088ee088eeee0088ee088ee000000000000000000000000000000000000000000
000088ee000088ee088ee000088ee0088ee000088ee000088ee0000000088ee088ee088eeee0088ee088ee000000000000000000000000000000000000000000
00000088ee88ee00088ee000088ee0088ee000088ee000088ee0000000088ee088ee088ee88ee88ee088ee000000000000000000000000000000000000000000
00000088ee88ee00088ee000088ee0088ee000088ee000088ee0088ee0088ee088ee088ee88ee88ee088ee000000000000000000000000000000000000000000
0000000088ee0000088ee000088ee0088ee000088ee000088ee0088ee0088ee088ee088ee0088eeee088ee000000000000000000000000000000000000000000
0000000088ee0000088ee000088ee0088ee000088ee000088ee88ee88ee88ee088ee088ee0088eeee088ee000000000000000000000000000000000000000000
0000000088ee0000088ee000088ee0088ee000088ee000088ee88ee88ee88ee088ee088ee000088ee088ee000000000000000000000000000000000000000000
0000000088ee0000088ee000088ee0088ee000088ee000088eeee000088eeee088ee088ee000088ee00000000000000000000000000000000000000000000000
0000000088ee0000088ee000088ee0088ee000088ee000088eeee000088eeee088ee088ee000088ee00000000000000000000000000000000000000000000000
0000000088ee0000088ee000088ee0088ee000088ee000088ee0000000088ee088ee088ee000088ee088ee000000000000000000000000000000000000000000
0000000088ee000000088eeeeee00000088eeeeee00000088ee0000000088ee088ee088ee000088ee088ee000000000000000000000000000000000000000000
000000000000000000088eeeeee00000088eeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000404000000000001000408000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f1f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101010101010101010101033321010101010101010101010101010333210101010101010101010101010103311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
321010404142434445464748491010333210101010101010101010101010103332101010101010101010101010311033321010101010101010101010101010331111606162636465666768696a001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
321010505152535455565758591010333210101010101010101010101010103332101012313131313110101010121033321010101010101010101010101010331111007172737475767778797a001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101031101010101031311333321010311010101031101010103110333210101010101010101010101010103311111111000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101012101010101010101033321010311010101031101010101010333210101010313131313113101010103311111111000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3231311231101010101010133131313332101010101010101010101010101033321010311010101031101010101010333210101010311010101031101010103311111111000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101010101010101010101033321010313131313113313131313110333210101010311010101031101010103311111111000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101010101010101010101033321010101010101031101010103110333210101010133131313131101010103311111111000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101010101031123131101033321010101010101031101010103110333210101010101010101010101010103311111111000000000000000011111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101010101010101010101033321010101010101031101010103110333210101010101010101010101010103311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101010101010101010101033321010101010101031313131311210333231311231311231311231311231313311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101010101010101010101033321031123110101010101010101010333210101010101010101010101010103311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3210101010101010101010101010103332101010101010101010101010101033321010101010101010101010101010333210101010101010101010101010103311111111111111111111111111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
