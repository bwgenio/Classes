class GFxPauseMenu extends GFxMoviePlayer;

//stores the value of the mouse from the Xbox
var float CurrentMouseY;
var float CurrentMouseX;

//cursor object
var GFxObject Cursor;

function Init(optional LocalPlayer localP) 
{
	Start();
	Advance(0.f);
	Cursor = GetVariableObject("_root.Cursor");
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

//Gets Called When game is exited from the pause menu
//starts main menu map
function ExitGame()
{
	ConsoleCommand("start Pr0-MainMenu");
}

//toggles the pause menu
//called on pressing resume
function TogglePauseMenu()
{
	PR0HUDGFx(PR0PlayerController(getPC()).MyHud).TogglePauseMenu();
}

defaultproperties
{
    TimingMode=TM_Real
	bCaptureInput=false
	MovieInfo = swfMovie'PRAsset.PauseMenu.PR0-PauseMenu'
}