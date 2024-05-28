////////////////
//  Skullgun  //
////////////////

class HDTinyExplosion:IdleDummy{
	default{
    +forcexybillboard 
    +bright
	
	alpha 0.9;
    renderstyle "add";
	deathsound "world/explode";
    xscale 0.15;
    yscale 0.15;
	}

	states{
	spawn:
	death:
		MISL B 0 nodelay{
			if(max(abs(pos.x),abs(pos.y),abs(pos.z))>=32000){destroy();return;}
			vel.z+=4;
			A_StartSound(deathsound,CHAN_BODY,volume:0.5);

    A_SpawnChunksFrags("HDB_scrap",10,1);
    A_SpawnChunksFrags("HDB_frag",5,1);

			let xxx=spawn("HDExplosionLight",pos);
			xxx.target=self;
		}

		MISL B 0 A_SpawnItemEx("ParticleWhiteSmall", 0,0,0, vel.x+random(-2,2),vel.y+random(-2,2),vel.z,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		MISL B 0 A_SpawnItemEx("HDSmoke", 0,0,0, vel.x+frandom(-2,2),vel.y+frandom(-2,2),vel.z,0,SXF_ABSOLUTEMOMENTUM|SXF_NOCHECKPOSITION|SXF_TRANSFERPOINTERS);
		MISL B 0 A_Jump(256,"fade");
	fade:
		MISL B 1 A_FadeOut(0.1);
		MISL C 1 A_FadeOut(0.2);
		MISL DD 1 A_FadeOut(0.2);
		TNT1 A 20;
		stop;
	}
}


class HDB_SkullShot:HDBulletActor{//mirco-caliber HE rounds, can destroy doors and thin walls
	default{
		pushfactor 0.4;
		mass 25;//2.5 grams
		speed HDCONST_MPSTODUPT*300;//subsonic
		accuracy 300;
		stamina 570;//.22 caliber
		woundhealth 10;
		hdbulletactor.hardness 3;
	}
	//copied from HDB_bronto
	override void Detonate(){
		if(max(abs(pos.x),abs(pos.y))>=32768)return;

		vector2 facingpoint=(cos(angle),sin(angle));
		setorigin(pos-(2*facingpoint,0),false);

		A_SprayDecal("BrontoScorch",2);
		if(vel==(0,0,0))A_ChangeVelocity(cos(pitch),0,-sin(pitch),CVF_RELATIVE|CVF_REPLACE);
		else vel*=0.01;
		
		doordestroyer.destroydoor(self,32,frandom(4,6),6,dedicated:true);
		A_HDBlast(
			//fragradius:256,fragtype:"HDB_fragBronto",
			immolateradius:8,immolateamount:random(2,10),immolatechance:16,
			source:target
		);
		
		actor aaa=Spawn("BigWallChunk",pos,ALLOW_REPLACE);
		A_SpawnChunks("BigWallChunk",1,1,1);
		A_SpawnChunks("HDSmoke",1,1,1);
		aaa=spawn("HDTinyExplosion",pos,ALLOW_REPLACE);aaa.vel.z=2;
	//	distantnoise.make(aaa,"world/rocketfar");
		A_SpawnChunks("HDSmokeChunk",1,1,1);
	//	HDMobAI.HDNoiseAlert(target,self);

		bmissile=false;
		bnointeraction=true;
		vel=(0,0,0);
		if(!instatesequence(curstate,findstate("death")))setstatelabel("death");
	}
}

class HDSkullGun:HDWeapon{
	default{
		+inventory.invbar
		+inventory.undroppable  //it's implanted in your head
	  //+INVENTORY.UNTOSSABLE   //this makes it impossible to remove with console cheats
		-HDWeapon.FitsInBackpack
		+HDWeapon.NoRandomBackpackSpawn
		
		inventory.pickupmessage ""; //this shouldn't even be picked up
		inventory.icon "SKGNA0";    //will make a special graphic for this
		scale 0.4;
		
		tag "Skullgun";
		hdweapon.refid "skg";//SKull Gun
	}
	
	//disabling this because i don't know how to make it not suck
	/*
	override void doeffect(){
	    Super.DoEffect();
		
		let hdp=hdplayerpawn(owner);
		if(!owner)return;
		
		int implants=(hdp.CountInv("HDSkullGun"))+(hdp.CountInv("HDSkullFlamer"))+(hdp.CountInv("HDSkullBuster")); //track how many skullgun modules the player has
		
		int maxhp=100-5*implants; //each implant removes 5hp from your max health
		
		if(hdp.health<=maxhp)return;
		
		if(hdp.health>maxhp && GetAge() % TICRATE == 0){
		    owner.damagemobj(owner,
		                        self,1,
		                        "maxhpdrain",
		                        DMG_FORCED|DMG_NO_PAIN); 
		                        //decrease health if higher than max for whatever reason
            }
	}
	*/
	
	override string gethelptext(){
		return
		WEPHELP_FIRE.."  Fire 3-round burst";
	}
	
	states{
	spawn:
        SKGN A -1;
		stop;
	fire:
	shoot:
	    #### A 0 {hdplayerpawn(self).damagemobj(invoker,self,5,"internal",DMG_FORCED);//uses health as ammo
		          //hdplayerpawn(self).damagemobj(invoker,self,0,"bashing",DMG_FORCED);
		          givebody(3);}
		#### AAA 2 A_GunFlash();
		#### A 1{
			if(hdplayerpawn(self)){
				hdplayerpawn(self).gunbraced=false;
			}
			A_MuzzleClimb(
				-frandom(0.8,1.),-frandom(1.2,1.6),
				frandom(0.4,0.5),frandom(0.6,0.8)
			);
		}
		#### A 1 A_WeaponReady(WRF_NOFIRE);
		goto nope;
		
	flash:
		TNT1 A 1 bright{
			HDFlashAlpha(64);
			A_Light1();
			let bbb=HDBulletActor.FireBullet(self,"HDB_SkullShot",spread:2.,speedfactor:frandom(0.97,1.03));

			A_ZoomRecoil(0.995);
			A_MuzzleClimb(-frandom(0.4,1.2),-frandom(0.4,1.6));
		}
		---- A 0 A_StartSound("weapons/smg",CHAN_WEAPON);//has a built-in supressor
		---- A 0 A_Light0();
		stop;
    }
}