class PR0GoblinMace extends UTWeapon;

var bool IsInMeleeSwing;
var array<Actor> SwingHurtList;//Array of pawns that have been hit
var int osmeleedamage; // Damage done by the weapon

simulated function StartFire(byte FireModeNum)
{
	//Clear hurtlist
	SwingHurtList.Remove(0,SwingHurtList.Length);
	if (IsInMeleeSwing == false)
	{
		if(FireModeNum==0)//Primary attack
		{
			PR0EnemyGoblin(Owner).AttackAnim.PlayCustomAnim('MeleeAttack1', 1.0);
			IsInMeleeSwing = true;
			if (Owner.IsA('PR0EnemyOrc'))
			{
				// Play orc sound effect
				PlaySound(SoundCue'PRAsset.EnemySFX.Orc_attack1_Cue');
			}
			else
			{
				// Play goblin sound effect
				PlaySound(SoundCue'PRAsset.EnemySFX.Goblin_attack1_Cue');
			}

			SetTimer(0.5, false, 'DoMeleeSwingTrace');
			SetTimer(1.0, false, 'setMeleeBool');
		}
	}
}

function setMeleeBool()
{
	IsInMeleeSwing = false;
}

//simulated function tick(float DeltaTime)
//{
//	super.Tick(DeltaTime);

//	//check for melee-swing trace damage every frame while we're undergoing a melee swing as initiated by the Pawn's animation
//	if(IsInMeleeSwing)
//	{
//		DoMeleeSwingTrace();
//	}
//}

function DoMeleeSwingTrace()
{
	local PR0PlayerPawn PlayerPawn;
	local float Distance;

	PlayerPawn = PR0PlayerPawn(WorldInfo.GetALocalPlayerController().Pawn);
	Distance = VSize(PlayerPawn.Location - Owner.Location);
	if ( Distance < WeaponRange)
	{
		WorldInfo.Game.Broadcast(self, "TAKING DAMAGE");
		PlayerPawn.TakeDamage(osmeleedamage, Controller(Owner), PlayerPawn.Location, Vect(0,0,0), class'DmgType_Crushed');
	}

}

function bool AddToSwingHurtList(Actor newEntry)
{
	local int i;

	//no friendly fire on melee attacks! if the potential damagee is on the same team as us, then just ignore them.
	//if(DunDefTargetableInterface(newEntry) != none && DunDefTargetableInterface(newEntry).GetTargetingTeam() == DunDefTargetableInterface(Pawn).GetTargetingTeam())
		//return false;

	for(i=0; i < SwingHurtList.Length;i++)
	{
		if(SwingHurtList[i] == newEntry) // if pawn is in array
			return false;
	}

	SwingHurtList.AddItem(newEntry); // add pawn to array

	return true;
}

DefaultProperties
{
	osmeleedamage = 25
	ShotCost(0) = 0
	WeaponRange = 150
}
