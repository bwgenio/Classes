class PR0HUDGfx extends UTHUDBase;

//Reference the actual SWF container
var GFxHUD HudMovie;

//Called when this is destroyed
singular event Destroyed() 
{
	if (HudMovie != none) 
	{
		//Get rid of the memory usage of HudMovie
		HudMovie.Close(true);
		HudMovie = none;
	}

    super.Destroyed();
}

//Called after game loaded - initialise things
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	//Create a GFxHUD for HudMovie
	HudMovie = new class'GFxHUD';
	//Set the timing mode to TM_Real - otherwide things get paused in menus
	HudMovie.SetTimingMode(TM_Real);
	//Call HudMovie's Initialise function
	HudMovie.Init();
}

//Called every tick the HUD should be updated
event PostRender()
{
	HudMovie.TickHUD();
}

DefaultProperties
{
}