class GFxHUD extends GFxMoviePlayer;

//Create a Health Cache variable
var float LastHealthpc;

//Create variables to hold references to the Flash MovieClips and Text Fields that will be modified
var GFxObject HealthBar, ManaBar;
var GFxObject Countdown, Status;

//  Function to round a float value to an int
function int roundNum(float NumIn) {
 local int iNum;
 local float fNum;

 fNum = NumIn;
 iNum = int(fNum);
 fNum -= iNum;
 if (fNum >= 0.5f) {
 return (iNum + 1);
 }
 else {
 return iNum;
 }
}

//  Function to return a percentage from a value and a maximum
function int getPrc(int val, int max)
{
 return roundNum((float(val) / float(max)) * 100.0f);
}

//Called from PROHUDGfx'd PostBeginPlay()
function Init(optional LocalPlayer localP) 
{
 //Start and load the SWF Movie
 Start();
 Advance(0.f);

 //Set the cahce value so that it will get updated on the first Tick
 LastHealthpc = -1337;

 //Load the references with pointers to the movieClips and text fields in the .swf
 HealthBar = GetVariableObject("_root.HealthBar");
 ManaBar = GetVariableObject("_root.ManaBar");
}

//Called every update Tick
function TickHUD() {
 local UTPawn UTP;

 //We need to talk to the Pawn, so create a reference and check the Pawn exists
 UTP = UTPawn(PR0PlayerController.Pawn);
 if (UTP == None) {
 return;
 }

 //If the cached value for Health percentage isn't equal to the current...
 if (LastHealthpc != getPrc(UTP.Health, UTP.HealthMax)) {
 //...Make it so...
 LastHealthpc = getPc(UTPr.Health, UTP.HealthMax);
 //...Update the bar's xscale (but don't let it go over 100)...
 HealthBar.Bar.SetFloat("_xscale", (LastHealthpc > 100) ? 100.0f : LastHealthpc);
 ManaBar.Bar.SetFloat("_xscale", 50.0f);
 }
}

DefaultProperties
{
 //this is the HUD. If the HUD is off, then this should be off
 bDisplayWithHudOff=falsehow t