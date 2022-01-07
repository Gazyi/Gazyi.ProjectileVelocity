untyped

global function OnWeaponActivate_titanweapon_predator_cannon_proj
global function OnWeaponPrimaryAttack_titanweapon_predator_cannon_proj

#if SERVER
global function OnWeaponNpcPrimaryAttack_titanweapon_predator_cannon_proj
#endif

const SPIN_EFFECT_1P = $"P_predator_barrel_blur_FP"
const SPIN_EFFECT_3P = $"P_predator_barrel_blur"

const int MAX_BOLTS = 12 //16 // Every vscript says code limit per frame is 8, but looks like it works fine with higher numbers.

void function OnWeaponActivate_titanweapon_predator_cannon_proj( entity weapon )
{
	StopSpinSounds( weapon )
	if ( !( "initialized" in weapon.s ) )
	{
		weapon.s.damageValue <- weapon.GetWeaponInfoFileKeyField( "damage_near_value" )
		SmartAmmo_SetAllowUnlockedFiring( weapon, true )
		SmartAmmo_SetUnlockAfterBurst( weapon, false )
		SmartAmmo_SetWarningIndicatorDelay( weapon, 9999.0 )

		weapon.s.initialized <- true
		#if SERVER
			weapon.s.lockStartTime <- Time()
			weapon.s.locking <- true
		#endif
	}

	int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
	
	SmartAmmo_SetMissileSpeed( weapon, boltSpeed )
	SmartAmmo_SetMissileHomingSpeed( weapon, 12000 )
	SmartAmmo_SetMissileSpeedLimit( weapon, 12000 )
	SmartAmmo_SetMissileShouldDropKick( weapon, false )
	
	#if SERVER
	weapon.s.locking = true
	weapon.s.lockStartTime = Time()
	#endif
	
	entity weaponOwner = weapon.GetWeaponOwner()
}

var function OnWeaponPrimaryAttack_titanweapon_predator_cannon_proj( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	var needsZoom = weapon.GetWeaponInfoFileKeyField( "attack_button_presses_ads" )

	if ( owner.IsPlayer() && needsZoom )
	{
		float zoomFrac = owner.GetZoomFrac()
		if ( zoomFrac < 1 )
			return 0
	}

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	bool bPlayerFired = owner.IsPlayer()
	
	bool hasLongRangePowerShot = weapon.HasMod( "LongRangePowerShot" )
	bool hasCloseRangePowerShot = weapon.HasMod( "CloseRangePowerShot" )
	if ( hasLongRangePowerShot || hasCloseRangePowerShot )
	{
		#if SERVER
		if ( owner.IsPlayer() && IsMultiplayer() )
		{
			owner.Anim_PlayGesture( "ACT_SCRIPT_CUSTOM_ATTACK2", 0.2, 0.2, -1.0 )
		}
		else if ( owner.IsNPC() )
		{
			string anim = "ACT_RANGE_ATTACK1_SINGLE"
			if ( owner.IsCrouching() )
				anim = "ACT_RANGE_ATTACK1_LOW_SINGLE"
			owner.Anim_ScriptedPlayActivityByName( anim, true, 0.0 )
		}
		#endif
		if ( hasCloseRangePowerShot )
		{
			if ( owner.IsPlayer() )
				weapon.EmitWeaponSound_1p3p( "Weapon_Predator_Powershot_ShortRange_1P", "Weapon_Predator_Powershot_ShortRange_3P" )
			else
				EmitSoundAtPosition( TEAM_UNASSIGNED, attackParams.pos, "Weapon_Predator_Powershot_ShortRange_3P" )

			int damageType
			if ( weapon.HasMod( "fd_CloseRangePowerShot" ) )
				damageType = DF_SHOTGUN | DF_GIB | DF_EXPLOSION | DF_KNOCK_BACK | DF_SKIPS_DOOMED_STATE
			else
				damageType = DF_SHOTGUN | DF_GIB | DF_EXPLOSION | DF_KNOCK_BACK

			//ShotgunBlast( weapon, attackParams.pos, attackParams.dir, 16, damageType, 1.0, 10.0 )
			// Hitting wall usually spawns 12 impacts.
			entity owner = weapon.GetWeaponOwner()
			bool shouldCreateProjectile = false
			if ( IsServer() || weapon.ShouldPredictProjectiles() )
				shouldCreateProjectile = true
			//#if CLIENT
			//if ( weapon.ShouldPredictProjectiles() )
			//#endif
			
			vector attackAngles = VectorToAngles( attackParams.dir )
			vector baseUpVec = AnglesToUp( attackAngles )
			vector baseRightVec = AnglesToRight( attackAngles )
			
			if ( shouldCreateProjectile )
			{
				weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
				for ( int index = 0; index < MAX_BOLTS; index++ )
				{
					vector upVec = baseUpVec * RandomFloatRange( -0.8, 0.8 ) * 0.05
					vector rightVec = baseRightVec * RandomFloatRange( -0.8, 0.8 ) * 0.05
					
					vector attackDir = attackParams.dir + upVec + rightVec
					//int damageFlags = weapon.GetWeaponDamageFlags()
					
					entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackDir, 6000, damageType, damageType, PROJECTILE_NOT_PREDICTED, index )
					if ( bolt != null )
					{
						bolt.SetModel($"models/dev/empty_model.mdl")
						bolt.kv.gravity = expect float( weapon.GetWeaponInfoFileKeyField( "bolt_gravity_amount" ) )
						bolt.SetProjectileLifetime( RandomFloatRange( 0.30, 0.35 ) )
						EmitSoundOnEntity( bolt, "wpn_leadwall_projectile_crackle" )
						#if SERVER
						bolt.e.onlyDamageEntitiesOnce = true
						#endif
					}
				}
			}
			
			PowerShotCleanup( owner, weapon, ["CloseRangePowerShot","fd_CloseRangePowerShot","pas_CloseRangePowerShot"] , [] )

			return 1
		}
		else
		{
			if ( owner.IsPlayer() )
				weapon.EmitWeaponSound_1p3p( "Weapon_Predator_Powershot_LongRange_1P", "Weapon_Predator_Powershot_LongRange_3P" )
			else
				EmitSoundAtPosition( TEAM_UNASSIGNED, attackParams.pos, "Weapon_Predator_Powershot_LongRange_3P" )

			entity bolt
			#if CLIENT
			if ( weapon.ShouldPredictProjectiles() )
			#endif
			bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, 10000, damageTypes.gibBullet | DF_IMPACT | DF_EXPLOSION , DF_EXPLOSION | DF_RAGDOLL , PROJECTILE_NOT_PREDICTED, 0 )
			if ( bolt )
			{
				// Weapon mods can't have custom projectile models.
				bolt.SetModel($"models/weapons/bullets/projectile_40mm.mdl")
				bolt.kv.gravity = -0.1
				#if SERVER
				bolt.e.onlyDamageEntitiesOnce = true
				#endif
			}
		}

		PowerShotCleanup( owner, weapon, ["LongRangePowerShot","fd_LongRangePowerShot","pas_LongRangePowerShot"], [ "LongRangeAmmo" ] )

		return 1
	}
	else
	{	
		if ( bPlayerFired )
			return FireWeaponPlayerAndNPC( weapon, attackParams, true )
		else
			return FireWeaponPlayerAndNPC( weapon, attackParams, false )
	}
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_titanweapon_predator_cannon_proj( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	OnWeaponPrimaryAttack_titanweapon_predator_cannon_proj( weapon, attackParams )
}
#endif

int function FireWeaponPlayerAndNPC( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	int damageType = DF_BULLET | DF_STOPS_TITAN_REGEN | DF_GIB
	if ( weapon.HasMod( "Smart_Core" ) )
	{
		return SmartAmmo_FireWeapon( weapon, attackParams, damageType, damageTypes.largeCaliber | DF_STOPS_TITAN_REGEN )
	}
	else
	{
		//weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, damageType )
		entity owner = weapon.GetWeaponOwner()
		bool shouldCreateProjectile = false
		if ( IsServer() || weapon.ShouldPredictProjectiles() )
			shouldCreateProjectile = true
		#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
		#endif
		
		if ( shouldCreateProjectile )
		{
			int boltSpeed = expect int( weapon.GetWeaponInfoFileKeyField( "bolt_speed" ) )
			int damageFlags = weapon.GetWeaponDamageFlags()
			entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, boltSpeed, damageFlags, damageFlags, playerFired, 0 )
			
			if ( bolt != null )
			{
				bolt.kv.gravity = expect float( weapon.GetWeaponInfoFileKeyField( "bolt_gravity_amount" ) )
				
				#if CLIENT
				StartParticleEffectOnEntity( bolt, GetParticleSystemIndex( $"Rocket_Smoke_SMR_Glow" ), FX_PATTACH_ABSORIGIN_FOLLOW, -1 )
				#endif // #if CLIENT
			}
		}
		if ( weapon.HasMod( "LongRangeAmmo" ) )
			return 2
		else
			return 1
	}
	unreachable
}

void function StopSpinSounds( entity weapon )
{
		weapon.StopWeaponSound( "Weapon_Predator_MotorLoop_1P" )
		weapon.StopWeaponSound( "Weapon_Predator_MotorLoop_3P" )
		StopSoundOnEntity( weapon, "weapon_predator_windup_1p" )
		StopSoundOnEntity( weapon, "weapon_predator_windup_3p" )
		weapon.StopWeaponEffect( SPIN_EFFECT_1P, SPIN_EFFECT_3P )
		#if CLIENT
			entity weaponOwner = weapon.GetWeaponOwner()
			if ( !IsValid( weaponOwner ) )
				return
			StopSoundOnEntity( weaponOwner, "wpn_predator_cannon_ads_out_mech_fr00_1p" )
			StopSoundOnEntity( weaponOwner, "wpn_predator_cannon_ads_in_mech_fr00_1p" )
		#endif
}