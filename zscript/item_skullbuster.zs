///////////////////
//  Skull Buster  //
///////////////////

class HDSkullBuster:HDWeapon{
	default{
		+inventory.invbar
		+inventory.undroppable  //it's implanted in your head
	  //+INVENTORY.UNTOSSABLE   //this makes it impossible to remove with console cheats
		-HDWeapon.FitsInBackpack
		+HDWeapon.NoRandomBackpackSpawn
		
		inventory.pickupmessage ""; //this shouldn't even be picked up
		inventory.icon "SKGNC0";    //will make a special graphic for this
		scale 0.4;
		
		tag "Skull Buster";
		hdweapon.refid "skb";//SKull Buster
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
	
	//copied from Thunderbuster
	action void A_SkullZap(){
		if(invoker.weaponstatus[TBS_HEAT]>10)return;
		//don't use actual battery, just set power as low as possible
		int battery=1;//invoker.weaponstatus[TBS_BATTERY];
	
	    //ignore battery check
		/*
		if(battery<1){
			setweaponstate("nope");
			return;
		}
		*/

		//preliminary effects
		A_ZoomRecoil(0.99);
		A_StartSound("weapons/plasidle");
		if(IsMoving.Count(self)>9)A_MuzzleClimb(frandom(-0.8,0.8),frandom(-0.8,0.8));

		//the actual call
		ThunderBuster.ThunderZap(
			self,
			gunheight(),
			true,//invoker.weaponstatus[0]&TBF_ALT,
			battery
		);//don't use charge blast attack, it's too OP

		//aftereffects
		
		/* don't actually drain battery yet, need to give it a way to recharge
		if(invoker.weaponstatus[0]&TBF_ALT){
			if(!random(0,4))invoker.weaponstatus[TBS_BATTERY]--;
			A_MuzzleClimb(
				frandom(0.05,0.2),frandom(-0.2,-0.4),
				frandom(0.1,0.3),frandom(-0.2,-0.6),
				frandom(0.04,0.12),frandom(-0.1,-0.3),
				frandom(0.01,0.03),frandom(-0.1,-0.2)
			);
			invoker.weaponstatus[TBS_HEAT]+=6;
		}else if(!random(0,6))invoker.weaponstatus[TBS_BATTERY]--;
	    */
	    
	    //don't use heat mechanic, just add a "recharge" delay after each burst for now
		//invoker.weaponstatus[TBS_HEAT]+=random(0,3);

//altfire isn't used, so we don't need this
/*
		//update range thingy
		invoker.weaponstatus[TBS_MAXRANGEDISPLAY]=int(
			(battery>0?battery*200+8000:0)/HDCONST_ONEMETRE
		);
*/

	}
	
	override string gethelptext(){
		return
		WEPHELP_FIRE.."  Shoot plasma volley\n"
	//	..WEPHELP_ALTFIRE.."  Shoot shield ball volley\n"
	//	..WEPHELP_RELOAD.."  Shoot homing ball"
		;
	}
	
	states{
	spawn:
        SKGN A -1;
		stop;
	fire:
	buster://
	    #### A 0 {
	            hdplayerpawn(self).damagemobj(invoker,self,5,"internal",DMG_FORCED);//uses health as ammo
		  //        hdplayerpawn(self).damagemobj(invoker,self,1,"electrical",DMG_FORCED);
		          //buster causes some burn damage when fired
		          givebody(3);}
		#### AAA 2 {A_SkullZap();
                    A_ZoomRecoil(0.995);
                    A_GiveInventory("Heat",random(10,15));//don't let it overheat!
                   }
		#### A 1{
			if(hdplayerpawn(self)){
				hdplayerpawn(self).gunbraced=false;
			}
		}
				#### A 0{
			if(invoker.weaponstatus[TBS_BATTERY]<1){
				A_StartSound("weapons/plasmas",CHAN_WEAPON);
				A_GunFlash();
				setweaponstate("nope");
			}else{
				A_Refire();
			}
		}
		#### AAA 4{
			A_WeaponReady(WRF_NOFIRE);
			A_GunFlash();
		}goto nope;
		
	flash:
		TNT1 A 0;
	//	#### A 0 A_CheckIdSprite("THBFA0","PLSFA0",PSP_FLASH);
		#### A 1 bright{
			HDFlashAlpha(64);
			A_Light2();
		}
		#### AA 1 bright;
		#### A 1 bright A_Light1();
		#### AA 1 bright;
		#### A 0 bright A_Light0();
		stop;
    }
    
    //leaving this here in case i need it later
    /*
    override void initializewepstats(bool idfa){
		weaponstatus[TBS_BATTERY]=5;
	}
	*/
}