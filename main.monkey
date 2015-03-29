Import evolveordie

Class EvolveOrDieGame Extends App
	
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
		
		map_width = 1000
		map_height = 1000
		
		max_plants = 100
		max_poison = 1
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
		GeneratePlants()
	End
	
	Method OnRender()
		Cls(128, 128, 128)
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
		' For debugging purposes
		DrawText("position: " + player.position.x + " " + player.position.y, 10, 10)
		DrawText("Velocity: " + player.velocity.x + " " + player.velocity.y, 10, 450)
	End
	
	Method GenerateEnemies()
		For Local i:Int = 0 Until max_enemies
			Local xpos:Float = Rnd(50.0, map_width - 50)
			Local ypos:Float = Rnd(50.0, map_height - 50)
			' start enemies a little bigger and slower
			enemies.AddLast(New Player("enemy_" + i, xpos, ypos, 3.8, 3, true))
			Print "made enemy " + i
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
	
End

Function Main()
	New EvolveOrDieGame()
End