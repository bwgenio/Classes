class GFxHUD extends GFxMoviePlayer;

//Mouse Location Variables. Will be assigned from the actionscript
var float MouseX;
var float MouseY;

//Create a Health Cache variable
var float LastHealthpc;

//Current Frame of the Countdown
var int CurrentFrame;

//Current DangerLevel of the player
var int CurrentDangerLevel;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject HealthBar, ManaBar;
var GFxObject Pos_Indicator, Cursor;
Var GFxObject Detection_Eye;

//presets the mouse location to 0,0
function CaptureMouse(bool IsEnabled)
{
	local Vector2D screensize;
	GetGameViewportClient().GetViewportSize(screensize);
	GetGameViewportClient().SetMouse(0, 0);
	//bCaptureMouseInput = IsEnabled;
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
	Pos_Indicator = GetVariableObject("_root.PosCircle");
	Detection_Eye = GetVariableObject("_root.TheEye");
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
		if(Cursor.GetFloat("_currentFrame") < 20)
		Cursor.GotoAndPlay("25");	
	}
	else
	{
		if(Cursor.GetFloat("_currentFrame") > 20) 
			Cursor.GotoAndPlay("1");
	}


	//If the cached value for Health percentage isn't equal to the current...
	if (LastHealthpc != UTP.Health) 
	{
		//...Update the bar's xscale (but don't let it go over 100 or lower than 0)...
		LastHealthpc = UTP.Health;
		HealthBar.SetFloat("_xscale", (LastHealthpc > 100) ? 100.0f : ((LastHealthpc <= 0) ? 0.0f :(100.0 * float(UTP.Health)) / float(UTP.HealthMax)));
	}	
}

/**
 * Calls The ActionScript Function for closing the Eye.
 * @param = The minimum frame to reach.
 */
function CallAsFunction(float arg1)
{
	
	local ASValue Param0;
	local array<ASValue> args;
    local string FunctionPath, InvokeFunction;

	//Set the type of arguemnt to Number (float) as specified inside the actionscript function
	Param0.Type = AS_Number;
	Param0.n = arg1;
	//add the argument to the array of arguments
	args.Length = 1;
    args[0] = Param0;
	//creates a reference to the function which is located on the main frame hence _root
	FunctionPath = "_root";
	InvokeFunction = "playInReverse";
	//calls the function
	GetVariableObject(FunctionPath).Invoke(InvokeFunction, args);
}

//Checks whether the player is currently possessing a Pawn
//If True, displays the the Countdown and Pos_Indicator
//Displays the countdown and changes a frame every second.
function PosCountdown()
{
	local string CurrentFrameString;
	if(CurrentFrame < 7 && PR0PlayerController(getPC()).possessed==True)
	{
		CurrentFrameString = string(CurrentFrame);
		Pos_Indicator.GotoAndStop(CurrentFrameString);
		CurrentFrame = CurrentFrame + 1;
	}
	else
	{
		Pos_Indicator.GotoAndStop("1");
	}
}

//Hides the PossessioncountDown
function EndPosCountdown()
{
	Pos_Indicator.GotoAndStop("1");
	CurrentFrame = 2;
}



/**
* Rotates between the different stages of the eye opening degrees
* @Param=DangerLevel, int between 0 and 5. 
*/

function gotoFrame(int DangerLevel)
{
	//Reference to each Bot in the level
	local PR0Bot TempBot;
	//Reference to the highest alertness
	local int HighestAlertnessFrame;

	HighestAlertnessFrame = 0;

	//Loop each bot and find the highest alertness frame among every bots
	foreach class'WorldInfo'.static.GetWorldInfo().AllControllers(class'PR0Bot', TempBot)
	{
		if(HighestAlertnessFrame < TempBot.CurrentAlertnessFrame)
		{
			HighestAlertnessFrame = TempBot.CurrentAlertnessFrame;
		}
	}

	//Compare HighestAlertnessFrame and CurrentDangerLevel of the HUD
	//if (HighestAlertnessFrame == DangerLevel)
	if(HighestAlertnessFrame == CurrentDangerLevel)
	{
		return;
	}
	//else if(CurrentDangerLevel > DangerLevel)
	else if(HighestAlertnessFrame < CurrentDangerLevel)
	{
		`log("DECREASE FROM "$CurrentDangerLevel$" TO "$HighestAlertnessFrame);
		//CallAsFunction(DangerLevel*25);
		CallAsFunction(HighestAlertnessFrame*25);
		//CurrentDangerLevel = DangerLevel;
		CurrentDangerLevel = HighestAlertnessFrame;
	}
	else
	{
		//CurrentDangerLevel = DangerLevel;
		CurrentDangerLevel = HighestAlertnessFrame;
		switch(DangerLevel)
		{
			Case 0: //Alertness 0
				Detection_Eye.GotoAndStop("1");
				break;
			Case 1: //Alertness 1-24
				Detection_Eye.GotoAndPlay("2");
				break;
			Case 2: //Alertness 25-49
				Detection_Eye.GotoAndPlay("27");
				break;
			Case 3: //Alertness 50-74
				Detection_Eye.GotoAndPlay("52");
				break;
			Case 4: //Alertness 75-99
				Detection_Eye.GotoAndPlay("77");
				break;
			Case 5: //Only when alertness == 100
				Detection_Eye.GotoAndStop("91");
				break;
		}
	}
}

DefaultProperties
{
	//this is the HUD. If the HUD is off, then this should be off
	CurrentFrame=2
	CurrentDangerLevel=0
	bDisplayWithHudOff=false
	MovieInfo = swfMovie'PRAsset.HUD.PR-HUD'
}
