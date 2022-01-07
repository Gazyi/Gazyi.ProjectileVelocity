
global function OnWeaponPrimaryAttack_weapon_shotgun_proj

#if SERVER
global function OnWeaponNpcPrimaryAttack_weapon_shotgun_proj
#endif // #if SERVER

const SHOTGUN_MAX_BOLTS = 8 // this is the code limit for bolts per frame... do not increase.

var function OnWeaponPrimaryAttack_weapon_shotgun_proj( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( attackParams, true, weapon )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_weapon_shotgun_proj( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( attackParams, false, weapon )
}
#endif // #if SERVER

int function FireWeaponPlayerAndNPC( WeaponPrimaryAttackParams attackParams, bool playerFired, entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	
	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true
	#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
	#endif
	
	int numBlasts = expect int( weapon.GetWeaponInfoFileKeyField( "projectiles_per_shot" ) )
	
	vector attackAngles = VectorToAngles( attackParams.dir )
	vector baseUpVec = AnglesToUp( attackAngles )
	vector baseRightVec = AnglesToRight( attackAngles )
	
	if ( shouldCreateProjectile )
	{
		int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
		weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
		for ( int index = 0; index < minint( numBlasts, SHOTGUN_MAX_BOLTS ); index++ )
		{
			vector upVec = baseUpVec * RandomFloatRange( -0.8, 0.8 ) * 0.05
			vector rightVec = baseRightVec * RandomFloatRange( -0.8, 0.8 ) * 0.05
			
			vector attackDir = attackParams.dir + upVec + rightVec
			int damageFlags = weapon.GetWeaponDamageFlags()
			
			entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackDir, boltSpeed, damageFlags, damageFlags, playerFired, index )
			if ( bolt != null )
			{
				bolt.kv.gravity = expect float( weapon.GetWeaponInfoFileKeyField( "bolt_gravity_amount" ) )
				
				#if SERVER
					EmitSoundOnEntity( bolt, "weapon_mastiff_projectile_crackle" )
				#endif
			}
		}
	}
	
	return 1
}