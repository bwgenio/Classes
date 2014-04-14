class GFxRespawnMovie extends GFxMoviePlayer;

function Begin() 
{
	Start();
	Advance(0.f);
}

function Respawn()
{
	PR0PlayerController(GetPC()).SetPause(false);
	ConsoleCommand("open ?restart");
	Close();
}

defaultproperties
{
    TimingMode=TM_Real
	bCaptureInput = true
	bCaptureMouseInput = true
	MovieInfo = SwfMovie'PRAsset.RespawnMovie.PR0-RespwanMovie'

}