///////////////////
//  Skullflamer  //
///////////////////

class HDSkullFlamer:HDWeapon{
	default{
		+inventory.invbar
		+inventory.undroppable  //it's implanted in your head
	  //+INVENTORY.UNTOSSABLE   //this makes it impossible to remove with console cheats
		-HDWeapon.FitsInBackpack
		+HDWeapon.NoRandomBackpackSpawn
		
		inventory.pickupmessage ""; //this shouldn't even be picked up
		inventory.icon "SKGNB0";    //will make a special graphic for this
		scale 0.4;
		
		tag "Skull Flamer";
		hdweapon.refid "skf";//SKull Flamer
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
		WEPHELP_FIRE.."  Shoot fireball volley\n"
	//	..WEPHELP_ALTFIRE.."  Shoot shield ball volley\n"
	//	..WEPHELP_RELOAD.."  Shoot homing ball"
		;
	}
	
	states{
	spawn:
        SKGN A -1;
		stop;
	fire:
	fireball:
	    #### A 0 {
	            hdplayerpawn(self).damagemobj(invoker,self,5,"internal",DMG_FORCED);//uses health as ammo
		          //hdplayerpawn(self).damagemobj(invoker,self,1,"electrical",DMG_FORCED);
		          //flamer causes mild burn damage when fired
		          givebody(3);}
		#### AAA 2 {A_SpawnProjectile("HDImpBall",hdplayerpawn(self).height*0.88,0,frandom(-3,4),CMF_AIMDIRECTION,pitch);
                    A_ZoomRecoil(0.995);
                    A_GiveInventory("Heat",random(8,12));//take it easy, or you'll set your head on fire lmao
                   }
		#### A 1{
			if(hdplayerpawn(self)){
				hdplayerpawn(self).gunbraced=false;
			}
		}
		#### A 3 A_WeaponReady(WRF_NOFIRE);
		goto nope;
		
/*  too impractical to be useful, doesn't offer enough cover
	altfire:
	shieldball:
	    #### A 0 {
	            hdplayerpawn(self).damagemobj(invoker,self,7,"internal",DMG_FORCED);//uses health as ammo
		          hdplayerpawn(self).damagemobj(invoker,self,1,"electrical",DMG_FORCED);
		          //shield ball causes a bit more self-damage due to extra bio-energy cost
		          givebody(3);}
		 //shoot a spread for better cover
		#### A 6 {A_SpawnProjectile("ShieldImpBall",hdplayerpawn(self).height*0.88,0,frandom(-3,-3),CMF_AIMDIRECTION,pitch);
                  A_ZoomRecoil(0.995);
                  A_GiveInventory("Heat",random(10,15));
                 }
		#### A 2 {A_SpawnProjectile("ShieldImpBall",hdplayerpawn(self).height*0.88,26,frandom(-10,-5),CMF_AIMDIRECTION,pitch);
                  A_SpawnProjectile("ShieldImpBall",hdplayerpawn(self).height*0.88,-26,frandom(5,10),CMF_AIMDIRECTION,pitch);
                  A_ZoomRecoil(0.995);
                  A_GiveInventory("Heat",random(10,15));
                 }
		#### A 1{
			if(hdplayerpawn(self)){
				hdplayerpawn(self).gunbraced=false;
			}
		}
		#### A 5 A_WeaponReady(WRF_NOFIRE);
		goto nope;
*/

	/*	unused homing attack, not sure how to make it target enemies
	reload:
	homerball:
	    #### A 0 {
	            hdplayerpawn(self).damagemobj(invoker,self,9,"internal",DMG_FORCED);//uses health as ammo
		          hdplayerpawn(self).damagemobj(invoker,self,2,"electrical",DMG_FORCED);
		          //a homing ball costs about twice as much as a volley
		          givebody(3);}
		          
		#### A 2 {A_SpawnProjectile("MageImpBall",hdplayerpawn(self).height*0.88,2,frandom(-3,4),CMF_AIMDIRECTION,pitch);
                    A_ZoomRecoil(0.995);
                    A_GiveInventory("Heat",random(30,40));}
		#### A 1{
			if(hdplayerpawn(self)){
				hdplayerpawn(self).gunbraced=false;
			}
		}
		#### A 5 A_WeaponReady(WRF_NOFIRE);
		goto nope;
	*/
    }
}