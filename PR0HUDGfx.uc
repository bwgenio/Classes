class PR0HUDGfx extends HUD
	config(Game);

//Reference the actual SWF container
var GFxHUD HudMovie;

//Refrence to the Pause Menu
var GFxPauseMenu PauseMenuMovie;

var FontRenderInfo TextRenderInfo;

/** Various colors */
var const color GoldColor;

//Vector in 3D where player cursor is
var Vector WorldCursorOrigin;
//Directional vector in 3D (not really useful, just a dummy)
var Vector WorldDirection;

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
	//Set the timing mode to TM_Real - otherwise things get paused in menus
	HudMovie.SetTimingMode(TM_Real);
	//Set the ViewScaleMode
	//NoBorder: The SWF is always displayed at the original AR, but it is scaled depending on the resolution; clipping will occur at game resolutions smaller than the Flash document size.
	//HudMovie.SetViewScaleMode(SM_NoScale);
	//Set the Alignmnet of the Gfx movie
	HudMovie.SetAlignment(Align_TopLeft);
	//Call HudMovie's Initialise function
	HudMovie.Init();

}

//Gets the X and Y coordinates of the mouse from GFxHUD.uc
function Vector GetMouseCoords()
{
	local Vector HitLocation, HitNormal;
	local Vector2D MousePos;
	local string StringMessage;

	mousePos.X = HudMovie.MouseX;
	mousePos.Y = HudMovie.MouseY;
	
	Canvas.DeProject(MousePos, WorldCursorOrigin, WorldDirection);

	StringMessage = "MouseX" @ MousePos.X @ "MouseY" @ MousePos.Y @ "Direction" @ WorldDirection;
    // now draw string with GoldColor color
    Canvas.DrawColor = GoldColor;
    Canvas.SetPos( 10, 300 );
    Canvas.DrawText( StringMessage, false, , , TextRenderInfo );

	// Perform a trace to get the actual mouse world location.
	Trace(HitLocation, HitNormal, WorldCursorOrigin + WorldDirection * 1000, WorldCursorOrigin , false,,, TRACEFLAG_PhysicsVolumes);

	return HitLocation;
}

//Called every tick the HUD should be updated
event PostRender()
{
	WorldCursorOrigin = GetMouseCoords();
	HudMovie.TickHUD();
	if(PauseMenuMovie != none)
	{
		PauseMenuMovie.tick();
	}
	//if(KnightMiniGame.bMovieIsOpen)
	//	KnightMenuMovie.tick();
	super.PostRender();
}

function DisplayLocalMessages()
{
	//STUB to prevent local messages
}

//toggles the pause menu
//calls on Esc
exec function TogglePauseMenu()
{
	local GFxPauseMenu Movie;
    if (PauseMenuMovie != none)
	{
		//PauseMenuMovie.Cursor.SetBool("bUsingXbox", false);
		PauseMenuMovie.Close(true);
		PauseMenuMovie = none;
		PR0PlayerController(GetALocalPlayerController()).SetPause(false);
		ToggleHUD();
	}
	else
    {
		ToggleHUD();
		Movie = new class'GFxPauseMenu';
		//Movie.SetAlignment(Align_TopLeft);
		PauseMenuMovie = Movie;

		// Play Parchment sound effect
		PlaySound(SoundCue'PRAsset.Music.Paper_Rustle_Cue');

		Movie.Begin();
		PR0PlayerController(GetALocalPlayerController()).SetPause(true);
    }
}

DefaultProperties
{
	SizeX = 1280.0f;
	SizeY = 720.0f; 
}