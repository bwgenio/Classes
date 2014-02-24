class MouseInterfacePlayerInput extends PlayerInput;

//2D positions of the mouse in the screen
var Vector2D MouseCoordinates;

event PlayerInput(float DeltaTime)
{
	//Handles mouse event to update the 2D position of the mouse in the screen
	//Ensure HUD is valid
	if(myHUD != none)
	{
		//Add aMouseX to mouse coordinates and clamp it within the viewport width
		MouseCoordinates.X = Clamp(MouseCoordinates.X + aMouseX, 0, myHUD.SizeX);
		//Add aMouseY to mouse coordinates and clamp it within the viewport width
		MouseCoordinates.Y = Clamp(MouseCoordinates.Y - aMouseY, 0, myHUD.SizeY);
	}

	super.PlayerInput(DeltaTime);
}

DefaultProperties
{
}
