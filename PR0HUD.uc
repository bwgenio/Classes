class PR0HUD extends HUD
	config(Game);


//Vector in 3D where player cursor is
var Vector WorldCursorOrigin;
//Directional vector in 3D (not really useful, just a dummy)
var Vector WorldDirection;

var FontRenderInfo TextRenderInfo;

var Texture2D    CursorTexture;

/** Various colors */
var const color GoldColor;

var Vector2D    MousePosition;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	PostRender();
}

//Canvas is only valid during PostRender phase
event PostRender()
{
    //MousePosition = MouseInterfacePlayerInput(PlayerOwner.PlayerInput).MouseCoordinates;
    //Deproject the mouse from screen coordinate to world coordinate and store World Origin and Dir.
    //Canvas.DeProject(MousePosition, WorldCursorOrigin, WorldDirection);

	WorldCursorOrigin = GetMouseWorldLocation();
    //DrawHUD();
	super.PostRender();
}

function Vector GetMouseWorldLocation()
{
	local MouseInterfacePlayerInput MouseInterfacePlayerInput;
	local Vector HitLocation, HitNormal;
	local string StringMessage;

	// Ensure that we have a valid canvas and player owner
	if (Canvas == None || PlayerOwner == None)
	{
		return Vect(0, 0, 0);
	}

	// Type cast to get the new player input
	MouseInterfacePlayerInput = MouseInterfacePlayerInput(PlayerOwner.PlayerInput);

	// Ensure that the player input is valid
	if (MouseInterfacePlayerInput == None)
	{
		return Vect(0, 0, 0);
	}

	// We stored the mouse position as an IntPoint, but it's needed as a Vector2D
	MousePosition.X = MouseInterfacePlayerInput.MouseCoordinates.X;
	MousePosition.Y = MouseInterfacePlayerInput.MouseCoordinates.Y;
	// Deproject the mouse position and store it in the cached vectors
	Canvas.DeProject(MousePosition, WorldCursorOrigin, WorldDirection);
	
    StringMessage = "MouseX" @ WorldCursorOrigin.X @ "MouseZ" @ WorldCursorOrigin.Z @ "Direction" @ WorldDirection;
    // now draw string with GoldColor color
    Canvas.DrawColor = GoldColor;
    Canvas.SetPos( 10, 100 );
    Canvas.DrawText( StringMessage, false, , , TextRenderInfo );

	// Perform a trace to get the actual mouse world location.
	Trace(HitLocation, HitNormal, WorldCursorOrigin + WorldDirection * 1000, WorldCursorOrigin , false,,, TRACEFLAG_Bullet);

	return HitLocation;
}

/**
 * This is the main drawing pump.  It will determine which hud we need to draw (Game or PostGame).  Any drawing that should occur
 * regardless of the game state should go here.
 */
function DrawHUD()
{
    local string StringMessage;
    StringMessage = "MouseX" @ WorldCursorOrigin.X @ "MouseY" @ WorldCursorOrigin.Z @ "Direction" @ WorldDirection;
    // now draw string with GoldColor color
    Canvas.DrawColor = GoldColor;
    Canvas.SetPos( 10, 10 );
    Canvas.DrawText( StringMessage, false, , , TextRenderInfo );

    //Set position for mouse and plot the 2d texture.
    Canvas.SetPos(MousePosition.X, MousePosition.Y);
    Canvas.DrawTile(CursorTexture, 26 , 26, 380, 320, 26,26);
}

DefaultProperties
{
	CursorTexture=Texture2D'UI_HUD.HUD.UTCrossHairs'
    GoldColor=(R=255,G=183,B=11,A=255)
    TextRenderInfo=(bClipText=true)
}
