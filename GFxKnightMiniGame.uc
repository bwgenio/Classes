class GFxKnightMiniGame extends GFxMoviePlayer;

function Begin(float level) 
{
	Start();
	Advance(level);
	//CaptureMouse(True);
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
	bCaptureMouseInput = true
	MovieInfo = swfMovie'PRAsset.KnightMiniGame.PR0-KnightMiniGame'
}