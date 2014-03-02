class GFxHUD extends GFxMoviePlayer;

//Mouse Location Variables. Will be assigned from the actionscript
var float MouseX;
var float MouseY;

//Create a Health Cache variable
var float LastHealthpc;

//Current Frame of the Countdown
var int CurrentFrame;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject HealthBar, ManaBar;
var GFxObject Pos_Indicator, Cursor;
var GFxObject Pos_Countdown;

//  Function to round a float value to an int
function int roundNum(float NumIn) 
{
	local int iNum;
	local float fNum;

	fNum = NumIn;
	iNum = int(fNum);
	fNum -= iNum;
	if (fNum >= 0.5f) 
	{
		return (iNum + 1);
	}
	else 
	{
		return iNum;
	}
}

//presets the mouse location to 0,0
function CaptureMouse(bool IsEnabled)
{
	local Vector2D screensize;
	GetGameViewportClient().GetViewportSize(screensize);
	GetGameViewportClient().SetMouse(0, 0);
	//bCaptureMouseInput = IsEnabled;
}

//  Function to return a percentage from a value and a maximum
function int getPrc(int val, int max)
{
	return roundNum((float(val) / float(max)) * 100.0f);
}

//Called from PROHUDGfx'd PostBeginPlay()
function Init(optional LocalPlayer localP) 
{
	//Start and load the SWF Movie
	Start();
	Advance(0.f);
	CaptureMouse(True);

	//Set the cahce value so that it will get updated on the first Tick
	LastHealthpc = -1337;
	
	//Load the references with pointers to the movieClips and text fields in the .swf
	HealthBar = GetVariableObject("_root.HealthBar.Bar");
	ManaBar = GetVariableObject("_root.ManaBar.Bar");
	Cursor = GetVariableObject("_root.Cursor");
	Pos_Indicator = GetVariableObject("_root.Pos_Indicator");
	Pos_Countdown = GetVariableObject("_root.Pos_Indicator.Countdown");
}

// This is called from Flash. Gets the x and y coordinates from the mouse location
function ReceiveMouseCoords(float x, float y)
{
	MouseX = x;
	MouseY = y;
}
//Called every update Tick
function TickHUD() 
{
	local UTPawn UTP;
	//We need to talk to the Pawn, so create a reference and check the Pawn exists
	UTP = UTPawn(GetPC().Pawn);
	if (UTP == None) 
	{
		return;
	}

	//checkes whether the cursor is aiming at an enemy, and changes to the approperiate cursor image
	if(PR0PlayerController(getPC()).IsCursorOnEnemy() == True)
	{
		Cursor.GotoAndStop("2");	
	}
	else
	{
		Cursor.GotoAndStop("1");
	}


	//If the cached value for Health percentage isn't equal to the current...
	if (LastHealthpc != getPrc(UTP.Health, UTP.HealthMax)) 
	{
		//...Make it so...
		LastHealthpc = getPrc(UTP.Health, UTP.HealthMax);
		//...Update the bar's xscale (but don't let it go over 100)...
		HealthBar.SetFloat("_xscale", (LastHealthpc > 100) ? 100.0f : LastHealthpc);
		ManaBar.SetFloat("_xscale", 50.0f);
	}
}


//Checks whether the player is currently possessing a Pawn
//If True, displays the the Countdown and Pos_Indicator
//Displays the countdown and changes a frame every second.
function PosCountdown()
{
	local string CurrentFrameString;
	if(CurrentFrame > 0 && PR0PlayerController(getPC()).possessed==True)
	{
		Pos_Indicator.GotoAndStop("2");
		CurrentFrameString = string(CurrentFrame);
		Pos_Countdown.GotoAndStop(CurrentFrameString);
		CurrentFrame = CurrentFrame - 1;
	}
}

function EndPosCountdown()
{
	Pos_Indicator.GotoAndStop("1");
	Pos_Countdown.GotoAndStop("1");
	CurrentFrame = 6;
}

DefaultProperties
{
	//this is the HUD. If the HUD is off, then this should be off
	CurrentFrame=6
	bDisplayWithHudOff=false
	MovieInfo = swfMovie'PRAsset.HUD.PR-HUD'
}