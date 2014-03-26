class GFxPauseMenu extends GFxMoviePlayer;

function Init(optional LocalPlayer localP) 
{
	Start();
	Advance(0.f);
	//CaptureMouse(True);
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
    bDisplayWithHudOff=TRUE
    TimingMode=TM_Real
	bPauseGameWhileActive=TRUE
	bCaptureInput=false
	bCaptureMouseInput = true
	MovieInfo = swfMovie'PRAsset.PauseMenu.PR0-PauseMenu'
}