class GFxPosMiniGame extends GFxMoviePlayer;

// Initializes the HUD
function Init(optional LocalPlayer localP) 
{
	Start();
	Advance(0);
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
		Close(True);
	}
}

defaultproperties
{
    bDisplayWithHudOff=TRUE
    TimingMode=TM_Real
	bPauseGameWhileActive=TRUE
	bCaptureMouseInput = true;
	bCaptureInput=false;
	MovieInfo = swfMovie'PRAsset.PosMiniGame.PR0-PosMiniGame'
}