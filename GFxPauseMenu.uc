class GFxPauseMenu extends GFxMoviePlayer;

function Init(optional LocalPlayer localP) 
{
	Start();
	Advance(0.f);
	//CaptureMouse(True);
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