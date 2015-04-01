Import evolveordie

Const STATE_MENU:Int = 0
Const STATE_GAME:Int = 1
Const STATE_DEATH:Int = 2
Const STATE_HELP:Int = 3
Const STATE_WIN:Int = 4

Class EvolveOrDieGame Extends App
	
	Field game_state:Int
	
	Field menu_img:Image
	Field help_img:Image
	Field last_touch:Float
	Field last_plants:Float
	
	Field player:Player
	Field cam:Camera
	
	Field plants:List<PlantLife>
	Field max_plants:Int
	Field max_poison:Int
	Field poison_count:Int
	
	Field enemies:List<Player>
	Field max_enemies:Int
	
	Field map_width:Float
	Field map_height:Float
	
	Method OnCreate()
		SetUpdateRate(60)
		game_state = STATE_MENU
		menu_img = LoadImage("main_screen.png")
		help_img = LoadImage("instructions.png")
		
		map_width = 1000
		map_height = 1000
		
		max_plants = 100
		max_poison = 10
		poison_count = 0
		plants = New List<PlantLife>()
		
		max_enemies = 4
		enemies = New List<Player>()
		player = New Player("Me", 320, 240, 4.0)
		' Create some enemies
		GenerateEnemies()
		cam = New Camera( )
		GeneratePlants()
		' Set the random seed for this instance of the game
		Seed = Millisecs()
	End
	
	Method OnUpdate()
		Select game_state
			Case STATE_MENU
				If (TouchDown(0) And TouchX(0) < 425 And TouchX(0) > 185 And
					TouchY(0) > 365 And TouchY(0) < 445)
					game_state = STATE_HELP
					last_touch = Millisecs()
				End
			Case STATE_HELP
				If (TouchDown(0) And Millisecs() - last_touch > 300)
					game_state = STATE_GAME
				End
			Case STATE_GAME 
				If TouchDown(0)
					player.SetTarget(TouchX(0) - cam.position.x, TouchY(0) - cam.position.y)
				End
				' Player update needs to happen first so the camera will behave with the world boundaries
				player.Update(map_width, map_height)
				
				For Local enemy:Player = Eachin enemies
					FindTarget(enemy)
					enemy.Update(map_width, map_height)
				End
				
				cam.Update(player.velocity)
				EatPlant()
				EatPlayer()
				If Millisecs() - last_plants > 2000
					GeneratePlants()
				End
				If (player.size >= 11 Or enemies.Count = 0)
					game_state = STATE_WIN
					last_touch = Millisecs()
				End
		End
	End
	
	Method OnRender()
		Cls(128, 128, 128)
		Select game_state
			Case STATE_MENU
				DrawImage(menu_img, 0, 0)
			Case STATE_HELP
				DrawImage(help_img, 0, 0)
			Case STATE_GAME
				PushMatrix()
				Translate(cam.position.x, cam.position.y)
				player.Draw()
				
				For Local enemy:Player = Eachin enemies
					enemy.Draw()
				End
				
				For Local plant:PlantLife = Eachin plants
					plant.Draw()
				End
				PopMatrix()
			Case STATE_DEATH
				DrawText("Only the strong survive. You were not strong enough.", 220, 220, 0.5)
				If (TouchDown(0) And Millisecs() - last_touch > 700)
					GenerateEnemies()
					player.size = 2
					player.exp = 0
					game_state = STATE_GAME
				End 
			Case STATE_WIN
				DrawText("The species will live on. Congratulations", 220, 220, 0.5)
				If (TouchDown(0) And Millisecs() - last_touch > 700)
					GenerateEnemies()
					player.size = 2
					player.exp = 0
					game_state = STATE_GAME
				End
		End
	End
	
	Method GenerateEnemies()
		For Local i:Int = 0 Until max_enemies
			Local xpos:Float = Rnd(50.0, map_width - 50)
			Local ypos:Float = Rnd(50.0, map_height - 50)
			' start enemies a little bigger and slower
			enemies.AddLast(New Player("enemy_" + i, xpos, ypos, 3.8, 3, true))
		End
	End
	
	Method FindTarget(enemy:Player)
		' if the enemy is not moving, give them a new target
		If (enemy.velocity.x = 0 And enemy.velocity.y = 0)
			Local targetx = Rnd(0, map_width)
			Local targety = Rnd(0, map_height)
			enemy.SetTarget(targetx, targety)
		End
	End
	
	Method GeneratePlants()
		Local plant_count:Int = plants.Count()
		If plant_count < max_plants
			For Local i:Int = plant_count Until max_plants
				Local xpos:Float = Rnd(25.0, map_width - 20)
				Local ypos:Float = Rnd(25.0, map_height - 20)
				Local poison_chance:Float = Rnd(1.0, 10.0)
				Local poisonous:Int = 0
				If (poison_chance > 9.0) And (poison_count < max_poison)
					poisonous = 1
					poison_count += 1
				End
				
				plants.AddLast(New PlantLife("plant", xpos, ypos, 1, 1, poisonous))
			End
		End
		last_plants = Millisecs()
	End
	
	Method EatPlant()
		For Local plant:PlantLife = Eachin plants
			If player.box.Collide(plant.box)
				plants.Remove(plant)
				If plant.poisonous
					If player.size > 1
						player.size -= 1
						poison_count -= 1
					End
				Else
					player.exp += plant.exp
				End
			Else
				For Local enemy:Player = Eachin enemies
					If enemy.box.Collide(plant.box)
						plants.Remove(plant)
						If plant.poisonous
							If enemy.size > 1
								enemy.size -= 1
								poison_count -= 1
							End
						Else
							enemy.exp += plant.exp
						End
					End
				End
			End
		End
	End
	
	Method EatPlayer()
		For Local enemy:Player = Eachin enemies
			If enemy.box.Collide(player.box)
				If (enemy.size - player.size) >= 3
					game_state = STATE_DEATH
					last_touch = Millisecs()
				Else
					enemy.size -= 1
					player.size -= 1
					player.exp = 0
					If player.size = 0
						game_state = STATE_DEATH
						last_touch = Millisecs()
					End
					If enemy.size = 0
						enemies.Remove(enemy)
					End
				End
			End
		End	
	End
	
End

Function Main()
	New EvolveOrDieGame()
End