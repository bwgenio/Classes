class GFxHUD extends GFxMoviePlayer;

//Mouse Location Variables. Will be assigned from the actionscript
var float MouseX;
var float MouseY;

//Create a Health Cache variable
var float LastHealthpc;

//Create a Luminosity cache variable
var float LastLumosPoints;

//Current DangerLevel of the player
var int CurrentDangerLevel;

//Current Displayed Tutorial message
var int CurrentTutorialMessage;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject HealthBar, LumosBar;
var GFxObject Pos_CountDown, Cursor;
Var GFxObject Detection_Eye, Tut_Text;
var GFxObject RootMC;

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
	//RootMC.GotoAndStop("Main");
	Advance(0.f);

	CaptureMouse(True);

	//Set the cahce value so that it will get updated on the first Tick
	LastHealthpc = -1337;
	
	//Load the references with pointers to the movieClips and text fields in the .swf
	HealthBar = GetVariableObject("_root.InfBack.HealthBar");
	LumosBar = GetVariableObject("_root.InfBack.LumosBar");
	Cursor = GetVariableObject("_root.Cursor");
	Pos_CountDown = GetVariableObject("_root.PosCircle.CountDown");
	Detection_Eye = GetVariableObject("_root.PosCircle.TheEye");
	Tut_Text = GetVariableObject("_root.TutText");
	RootMC = GetVariableObject("_root");
}

//Hides the mouse when other swf files are opened
function ToggleMainCursor(bool state)
{
	Cursor.SetVisible(state);
}

// Goto a certain Labeled frame in Root
function GotoLabel(String label)
{
	RootMC.GotoAndStop(label);
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
	local PR0PlayerController PC;
	//We need to talk to the Pawn, so create a reference and check the Pawn exists
	UTP = UTPawn(GetPC().Pawn);
	PC = PR0PlayerController(GetPC());

	if (UTP == None) 
	{
		return;
	}

	//checkes whether the cursor is aiming at an enemy, and changes to the approperiate cursor image
	if(PC.IsCursorOnEnemy() == True)
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
		HealthBar.SetFloat("_xscale", (LastHealthpc > 100) ? 100.0f : ((LastHealthpc <= 0) ? 0.0f : (100.0 * float(UTP.Health)) / float(UTP.HealthMax)));
	}

	// Updates the Lumos Bar according to how much Lumos points are available.
	if(LastLumosPoints != PC.LuminosityPoints)
	{
		LastLumosPoints = PC.LuminosityPoints;
		LumosBar.SetFloat("_xscale", (LastLumosPoints > (class'PR0PlayerController'.Default.LuminosityPoints)) ? 100.0f : ((LastLumosPoints <= 0) ? 0.0f : (100.0 * float(PC.LuminosityPoints) / float(class'PR0PlayerController'.Default.LuminosityPoints))));
	}
	
	// Checks whether the tutorial HUD trigger has been set on
	// Captures player Inputs and makes sure it is the proper one for the tutorial
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
	if(PR0PlayerController(getPC()).possessed==True)
	{
		Pos_CountDown.GotoAndPlay("2");
	}
	else
	{
		Pos_CountDown.GotoAndStop("1");
	}
}

//Hides the PossessioncountDown. Gets called from Flash at the end of the function
function EndPosCountdown()
{
	PR0PlayerController(getPC()).ReturnToNormal();
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
				Detection_Eye.GotoAndStop("`91");
				break;
		}
	}
}

/**
 * Displays the Tutorial Messages. 
 * Gets Called by TutDisplay in PC, when that is called by the kismet triggers.
 * Increases by one for now.
 */
function TutDisplay()
{

	local string frame;
	CurrentTutorialMessage = CurrentTutorialMessage + 1;
	frame = string(CurrentTutorialMessage);
	Tut_Text.gotoAndStop(frame);

	if(CurrentTutorialMessage == 3 || CurrentTutorialMessage == 4)
	{
		Cursor.SetBool("bCaptureMouse", true);
	}
	else
	{
		RootMC.SetBool("bCaptureKeyboard", true);
	}
	
	bCaptureInput = true;
}

/**
 * Checks whether the proper key was pressed for each required tutorial message
 * allows the player to proceed only if the proper key is pressed
 */
function KeyPressed(float Key)
{
	`log("Key issss: " $Key $". FRAME IS : " $CurrentTutorialMessage); 
	if(bCaptureInput == false)
		return;
	switch(CurrentTutorialMessage)
	{
		case 2:
			if(Key == 65 || key == 68)
			{
				RootMC.SetBool("bCaptureKeyboard", false);
				bCaptureInput = false;
				Tut_Text.GotoAndStop("1");
			}
			break;
		case 3:
			if(Key == 999)
			{
				Cursor.SetBool("bCaptureMouse", false);
				bCaptureInput = false;
				Tut_Text.GotoAndStop("1");
			}
			break;
		case 4:
			if(Key == 888)
			{
				Cursor.SetBool("bCaptureMouse", false);
				bCaptureInput = false;
				Tut_Text.GotoAndStop("1");
			}
			break;
		case 5:
			if(Key == 69)
			{
				RootMC.SetBool("bCaptureKeyboard", false);
				bCaptureInput = false;
				Tut_Text.GotoAndStop("1");
			}
			break;
		case 8:
			if(Key == 32)
			{
				RootMC.SetBool("bCaptureKeyboard", false);
				bCaptureInput = false;
				Tut_Text.GotoAndStop("1");
			}
			break;
	}
}

// Retrieves the current Frame of the stage
function int getCurrentFrame()
{
	return RootMC.GetFloat("_currentFrame");
}

DefaultProperties
{
	//this is the HUD. If the HUD is off, then this should be off
	CurrentDangerLevel=0
	CurrentTutorialMessage = 1
	bCaptureInput = false
	bDisplayWithHudOff=false
	MovieInfo = swfMovie'PRAsset.HUD.PR-HUD'
}