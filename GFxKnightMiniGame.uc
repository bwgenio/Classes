class GFxKnightMiniGame extends GFxMoviePlayer;

//stores the value of the mouse from the Xbox
var float CurrentMouseY;
var float CurrentMouseX;

//cursor object
var GFxObject Cursor;

function Begin(float level) 
{
	Start();
	Advance(level-1);
	AddCaptureKey('XboxTypeS_A');
	Cursor = GetVariableObject("_root.Cursor");
	//CaptureMouse(True);
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

function isOver(bool isWinning)
{
	if(isWinning)
	{
		//Activate Kismet event to open the door
		PR0PlayerController(GetPC()).EndChessGame();
	}
}

defaultproperties
{
    TimingMode=TM_Real
	//bCaptureMouseInput = true
	bCaptureInput = false
	MovieInfo = swfMovie'PRAsset.KnightMiniGame.PR0-KnightMiniGame'
}