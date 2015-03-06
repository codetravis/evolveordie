Import evolveordie

Class EvolveOrDieGame Extends App
	
	Field starting_pos:Vec2D
	Field player:Player
	
	Method OnCreate()
		SetUpdateRate(60)
		starting_pos = New Vec2D(10, 10)
		player = New Player("Me", starting_pos, 4.0)
	End
	
	Method OnUpdate()
		If TouchDown(0)
			player.SetTarget(TouchX(0), TouchY(0))
		End
		player.Update()
	End
	
	Method OnRender()
		Cls(255, 255, 255)
		player.Draw()
	End
End

Function Main()
	New EvolveOrDieGame()
End