Import evolveordie

Class EvolveOrDieGame Extends App
	
	Field player:Player
	Field cam:Camera
	Field plants:List<PlantLife>
	Field max_plants:Int
	
	Method OnCreate()
		SetUpdateRate(60)
		max_plants = 10
		plants = New List<PlantLife>()
		player = New Player("Me", 320, 240, 4.0)
		cam = New Camera( )
		GeneratePlants()
		' Set the random seed for this instance of the game
		Seed = Millisecs()
	End
	
	Method OnUpdate()
		If TouchDown(0)
			player.SetTarget(TouchX(0) - cam.position.x, TouchY(0) - cam.position.y)
		End
		cam.Update(player.velocity)
		player.Update()
		EatPlant()
		GeneratePlants()
	End
	
	Method OnRender()
		Cls(255, 255, 255)
		PushMatrix()
		Translate(cam.position.x, cam.position.y)
		player.Draw()
		
		For Local plant:PlantLife = Eachin plants
			plant.Draw()
		End
		PopMatrix()
	End
	
	Method GeneratePlants()
		Local plant_count:Int = plants.Count()
		If plant_count < max_plants
			For Local i:Int = plant_count Until max_plants
				Local xpos:Float = Rnd(25.0, 615.0)
				Local ypos:Float = Rnd(25.0, 455.0)
				Local poison_chance:Float = Rnd(1.0, 11.0)
				Local poisonous:Int = 0
				If poison_chance > 9.0
					poisonous = 1
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
					End
				Else
					player.exp += plant.exp
				End
			End
		End
	End
End

Function Main()
	New EvolveOrDieGame()
End