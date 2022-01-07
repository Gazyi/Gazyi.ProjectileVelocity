untyped

global function OnWeaponActivate_weapon_smart_pistol_proj

void function OnWeaponActivate_weapon_smart_pistol_proj( entity weapon )
{
	if ( !( "initialized" in weapon.s ) )
	{
		weapon.s.damageValue <- weapon.GetWeaponInfoFileKeyField( "damage_near_value" )
		SmartAmmo_SetAllowUnlockedFiring( weapon, true )
		SmartAmmo_SetUnlockAfterBurst( weapon, (SMART_AMMO_PLAYER_MAX_LOCKS > 1) )
		SmartAmmo_SetWarningIndicatorDelay( weapon, 0.0 )

		weapon.s.initialized <- true

#if SERVER
		weapon.s.lockStartTime <- Time()
		weapon.s.locking <- true
#endif
	}
	
	int bulletSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
	
	SmartAmmo_SetMissileSpeed( weapon, bulletSpeed )
	SmartAmmo_SetMissileHomingSpeed( weapon, 12000 )
	SmartAmmo_SetMissileSpeedLimit( weapon, 12000 )
	SmartAmmo_SetMissileShouldDropKick( weapon, false )
	
#if SERVER
	weapon.s.locking = true
	weapon.s.lockStartTime = Time()
#endif

	entity weaponOwner = weapon.GetWeaponOwner()
}