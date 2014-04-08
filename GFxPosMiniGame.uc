class GFxPosMiniGame extends GFxMoviePlayer;

//stores the value of the mouse from the Xbox
var float CurrentMouseY;
var float CurrentMouseX;

//cursor object
var GFxObject Cursor;

// Initializes the HUD
function Init(optional LocalPlayer localP) 
{
	Start();
	Advance(0.f);
	Cursor = GetVariableObject("_root.Cursor");
}

// Receives from the HUD whether the possession ghost is captured or not
function isCaptured(bool bCaptured)
{
	if(bCaptured)
	{
		bCaptureInput = false;
		bCaptureMouseInput = false;
		PR0PlayerController(GetPC()).SuccessPossess();
	}
	else
	{
		bCaptureInput = false;
		bCaptureMouseInput = false;
		PR0PlayerController(GetPC()).myHUD.ToggleHUD();
		Close(True);
	}
}

function tick()
{
	if(PR0PlayerController(GetPC()).PlayerInput.bUsingGamepad == true)
	{
		CurrentMouseY = CurrentMouseY + PR0PlayerController(GetPC()).returnMouseY();
		CurrentMouseX = CurrentMouseX + PR0PlayerController(GetPC()).returnMouseX();
		Cursor.SetBool("bUsingXbox", true);
		Cursor.SetFloat("_y", CurrentMouseY);
		Cursor.SetFloat("_x", CurrentMouseX);
	}
	else
	{
		Cursor.SetBool("bUsingXbox", false);
	}
}


defaultproperties
{
	//bPauseGameWhileActive=TRUE
	//bCaptureMouseInput = true
	bCaptureInput=false
	MovieInfo = swfMovie'PRAsset.PosMiniGame.PR0-PosMiniGame'
}