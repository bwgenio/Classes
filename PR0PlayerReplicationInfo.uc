/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */
class PR0PlayerReplicationInfo extends UTPlayerReplicationInfo;
 
simulated event PostBeginPlay(){
	super.PostBeginPlay();
}
 
function SetCharacter(class<UTFamilyInfo> CharacterClass)
{
     	CharClassInfo=CharacterClass;
}
 
defaultproperties
{
    	LastKillTime=-3.0
	CharClassInfo=class'PR0.PR0FamilyInfo_Human'
}
