class SeqCond_IsWhatState extends SequenceCondition;

//The Bot we are trying to get the state from
var Pawn BotPawn;
//The Name of the state
var Name StateName;

event Activated()
{
	local array<Object> ObjectVars;

	GetObjectVars(ObjectVars);

	BotPawn = Pawn(ObjectVars[0]);
	`log("BotController is "$BotPawn);

	if(BotPawn != none)
	{
		StateName = BotPawn.Controller.GetStateName();
		`log("BOTCONTROLLER STATE IS "$BotPawn.Controller.GetStateName());

		switch(StateName)
		{
		case 'Hostile':
			OutputLinks[0].bHasImpulse = true;
			break;
		case 'Suspicion':
			OutputLinks[1].bHasImpulse = true;
			break;
		case 'Attack':
			OutputLinks[2].bHasImpulse = true;
			break;
		case 'ChasePlayer':
			OutputLinks[3].bHasImpulse = true;
			break;
		case 'PathFinding':
			OutputLinks[4].bHasImpulse = true;
			break;
		case 'ScriptedMove':
			OutputLinks[5].bHasImpulse = true;
		}
	}
}

defaultproperties
{
	ObjName="Is What State?"
	ObjCategory="PR0"
	
	VariableLinks.Add((ExpectedType=Class'SeqVar_Object',LinkDesc="Bot",PropertyName=Bot,MaxVars=1))
	OutputLinks(0) = (LinkDesc="Hostile")
	OutputLinks(1) = (LinkDesc="Suspicion")
	OutputLinks(2) = (LinkDesc="Attack")
	OutputLinks(3) = (LinkDesc="ChasePlayer")
	OutputLinks(4) = (LinkDesc="PathFinding")
	OutputLinks(5) = (LinkDesc="ScriptedMove")
}
