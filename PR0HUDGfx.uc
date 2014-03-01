class PR0HUDGfx extends UTHUDBase;

//Reference the actual SWF container
var GFxHUD HudMovie;

//Called when this is destroyed
singular event Destroyed() {
 if (HudMovie != none) {
 //Get rid of the memory usage of HudMovie
    HudMovie.Close(true);
    HudMovie = none;
 }

     super.Destroy();
}

//Called after game loaded - initialise things
simulated function PostBeginPlay()
 {
 super.PostBeginPlay();

 //Create a GFxHUD for HudMovie
     HudMovie = new class'GFxHUD';
 //Set the HudMovie's PlayerOwner
 HudMovie.PlayerController = PR0PlayerController;
 //Set the timing mode to TM_Real - otherwide things get paused in menus
     HudMovie.SetTimingMode(TM_Real);
 //Call HudMovie's Initialise function
 HudMovie.Init(HudMovie.PlayerController);
}

//Called every tick the HUD should be updated
event PostRender()
{
    HudMovie.TickHUD();
}

DefaultProperties
{
}