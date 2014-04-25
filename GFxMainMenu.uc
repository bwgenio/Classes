class GFxMainMenu extends GFxMoviePlayer;

//stores the value of the mouse from the Xbox
var float CurrentMouseY;
var float CurrentMouseX;

//cursor object
var GFxObject Cursor;

function Begin() 
{
	Start();
	Advance(0.f);
	AddCaptureKey('XboxTypeS_A');
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

defaultproperties
{
	TimingMode=TM_Real
	bCaptureInput=true
    bCaptureMouseInput = true;
}