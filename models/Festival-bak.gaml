/**
* Name: Festival Simulation
* Author: Federico Yuyang 
*/


model MusicParty

global{
		//Configuring the values
	
	int guest_num<- 3;
	int InfoCenter_num<-1;
	int Stage_num<-1;
	int store_num<-2;
	int water_num<-2;
	int stepCounterVariable <- 0 max: 360 update: stepCounterVariable+1; // simulating 360 minutes or 6 hrs
	point InfoCent_Loc <- {50,80};
	int InfoCenter_sz<- 20;
	point Stage_Loc <- {80,50};   // Stage Area 
	point moshpit_Loc <- {40,40};   // moshpit Area 
	point guest_Loc <- {80,40};  //Dancing Area next to the stage 
	point store_Loc <- {30,10};  //Stores with food
	point water_Loc <- {20,10};  //Stores with water
	int Stage_sz<- 15;
	float guestSpeed <- 0.5;
	point previousLocation <- {50,80};
	
	/*There are 5 types of guests
	 * 
	 * 1-guest_rock_fan
	 * 2-guest_moshpit_dancer
	 * 3-guest_moshpit_dancer
	 * 4-guest_drunk
	 * 5-guest_bullies
	 * 
	 * Each Guest has 1 set of rules on how to interact with others ** perhaps the switch function could be used here
	 */
	
	
	/*3 Personal Traits for each one 
	 * 
	 * 
	 * 
	 */
	
	
	
	init 
	{
		create guest number: guest_num
		{location <- guest_Loc;}
		
		create guest_rock_fan number: 1
		{location <- guest_Loc;}
		
		create guest_moshpit_dancer number: 1
		{location <- guest_Loc;}
		
		create guest_bullies number: 1
		{location <- guest_Loc;}
		
		create guest_drunk number: 1
		{location <- guest_Loc;}
		
		create Stores number: store_num
		{location <- store_Loc;}
		
		create Water number: water_num
		{location <- water_Loc;	}
		
		create Info_Center number: InfoCenter_num
		{location <- InfoCent_Loc;}
		
		create Stage number: Stage_num
		{location <- Stage_Loc;}

		
			}

		}

species guest skills:[moving,fipa]
{

	// Three (3) personal Traits used for the Guests 
	
	float I <- rnd(50)+50.0; // Social (used for Introvert or Extrovert)
	float G <- rnd(50)+50.0; // Genorisity Used for selfish or generous
	float E <- rnd(50)+50.0; // Emotional or Not Emotional 
	
	float Happiness <- rnd(50)+50.0;	// We are measuring this value according to ageints interactions 
	float energy <- 100.0 max 100.0; // It will decrease every second and restock after drinking or eating
	float drunkness <- 0; // It will decrease every second and restock after drinking or eating  
	//float thirst<- rnd(50)+50.0;   // To have them Drink or not 
//	float hunger<- rnd(50)+50.0;	// Maybe not needed 
	
	// Base values ofr personality Traits 
	bool isIntrovert <- false;
	bool isExtrovert <- false;
	bool isGenerous <- false;
	bool isSelfish <- false;
	bool isHappy <- false;
	bool isNotHappy <- false;
	
	// To flip desition on eating or drinking to get more energy and move
	bool flippingFoodDrinkVariable <- true update: flip(0.5);
	
	
	rgb color<- #red;
	
	building target<- nil;
	
	aspect default
	{
		draw sphere(2) at: location color:color;
		draw name at: location + {1,1} color: #black font: font('Default', 10, #bold);
		
	}
	
	
	
/*All the guests are given 100 % of energy, the concert last 6 hrs, 
 * and depending of their activities they lose energy levels by the minute. 
 * If they moshpit energy increases more than if they are just dancing or somewhere else.
 * The energy level will be used to go to eat or drink to restock their energy levels.
 */ 
 
reflex updateEnergy
{
    if location = Stage_Loc
    {
      energy <- energy - 0.5 * 2;  // reduces by a factor of 2x
    }
    else if location = moshpit_Loc
    {
      energy <- energy - 0.5 * 4; // reduces by a factor of 4x
    }
    else
    {
      energy <- energy - 0.5; // reduces at a normal rate
   }
}

 /* This reflex prints out the current energy level of each guest to the console
 * This could be a readable value together with happiness.
 */ 

   reflex fromToLoop {
    	loop counter from: 1 to: stepCounterVariable {
    		write "Time elapsed: " + counter + " minutes, and the energy level of " + name + " is " + energy + "%" ;
    	}
    }


reflex restockEnergy
{
  previousLocation  <- location;  // store current location as previous location

  if (energy < 20  and flippingFoodDrinkVariable)
  {
    do goto target:water_Loc speed: guestSpeed;
    energy <- energy + 1;
    drunkness <- drunkness + 1 ;
    write name + " drunk, level of drunkness of " + drunkness +" %" + " and level of energy of: " + energy + " % ";
  }
  else
  {
    do goto target: store_Loc speed: guestSpeed;
    energy <- energy + 5;
    write name + " ate, level of drunkness of " + drunkness +" %" + " and level of energy of: " + energy + " % ";
  }

  do goto target: previousLocation speed: guestSpeed;  // go back to previous location
}


	
	
	
	
	// Personality Values 
	
	reflex updatePersonality{
		// To see if an agent is introverted, extrovert, generous, selfish, unHappy or happy...
		if (I < 74) {isIntrovert <- true;}
		if (I > 75) {isExtrovert <- true;}
		if (G > 75) {isGenerous <- true;}
		if (G < 74) {isSelfish <- true;}
		if (E > 70) {isHappy <- true;}
		if (E > 80) {isNotHappy <- true;} 
	}
	
	// First Place where They hangout 
	reflex rave when: Happiness > 80 {
		do goto target:Stage_Loc speed: guestSpeed;
		previousLocation <- location;
		write name + "is raving and going to stage!";
	}
	
	// Second Place where They hangout 
	
	reflex moshpit when: Happiness > 80 {
		do goto target:moshpit_Loc speed: guestSpeed;
		location <- moshpit_Loc;
		write name + "is raving and going to stage!";	}
		
	// third Place where They hangout is the stores  

		//Default guest/agent behaviour at festival -- missing stage location
	reflex Go_Dancing when: target=nil
	{
		do wander;
		color<- #purple;
		Happiness <- Happiness + rnd(-5,5);
	}
	
	//Move towards target
	reflex moveToTarget when: target!=nil
	{
		do goto target:target.location speed:guestSpeed;
	} 	
	
	 
}

/*
 * Species guest_rock_fan
 * 
 */
species guest_rock_fan parent: guest
{
	//bool isRaving <- false;
	rgb color <- #black;
	
	aspect default
	{
		draw cube(2) at: location color: color;
		draw name at: location + {1,1} color: #black font: font('Default', 10, #bold);
	}

	// raving when is happy
	reflex rave when: Happiness > 90{
		color <- rgb(Happiness,0,0); // Hapiness level indicates the color
	}

	// when at the stage and happy, invite guest_moshpit_dancer to dance
	reflex inviteToDance when: Happiness > 70 and (location distance_to(Stage_Loc) < Stage_sz){
		//// TODO: FIPA to ask guest_moshpit_dancer
		do start_conversation with:(to:: list(guest_moshpit_dancer), protocol:: 'fipa-propose', performative:: 'propose', contents:: ['Go dancing?']);
	}
	
	// when receive msg, read and update happiness
	reflex ReadMsg when: (!empty(agrees)){
		loop msg over: agrees {
			if (msg.contents[0] = 'Yes!'){
				Happiness <- 255.0;
			}
			if (msg.contents[0] = 'No!' and isHappy = true){
				//TODO: emotional rockfan
				Happiness <- 0.0;
			}
		}
	}
	
}


/*
 * guest_moshpit_dancer: know how to dance only dance in the mosh_pit with..
 */
species guest_moshpit_dancer parent: guest
{
	aspect default
	{
		draw cube(2) at: location color: #pink;
		draw name at: location + {1,1} color: #black font: font('Default', 10, #bold);
	}
	
	reflex Dance when: energy > 25{
		color <- #lime;
	}
	
	reflex rave when: Happiness > 90{
		////
		color <- #limegreen;
	}
	
	reflex RespondToInvitation when: (!empty(proposes)) and (location distance_to(Stage_Loc) < Stage_sz){  
		// TODO:read the FIPA invitation and respond
		// TODO:enter fever mode and dance
		loop msg over: proposes {
			if (msg.contents[0] = 'Go dancing?' and energy>25){
				Happiness <- 200.0;
				do start_conversation with:(to: msg.sender, protocol: 'fipa-propose', performative: 'agree', contents: ['Yes!', 'guest_moshpit_dancer']);
			}
            
        }
        proposes <- [];
	}
}
/*New species added here  */
	
	species guest_bullies skills:[moving]{
	bool isHungry <- false update: flip(0.5);
	bool isThirsty <- false update: flip(0.5);
	
	aspect base {
		rgb agentColor <- rgb("green");
		
		if (isHungry and isThirsty) {
			agentColor <- rgb("red");
		} else if (isThirsty) {
			agentColor <- rgb("darkorange");
		} else if (isHungry) {
			agentColor <- rgb("purple");
		}
		
		draw circle(1) color: agentColor;
	}
	
	// ------------------ They Just move around ------------------
	reflex move {
		do wander;
	}
}		
	species guest_drunk skills:[moving]{
	bool isHungry <- false update: flip(0.5);
	bool isThirsty <- false update: flip(0.5);
	
	aspect base {
		rgb agentColor <- rgb("green");
		
		if (isHungry and isThirsty) {
			agentColor <- rgb("red");
		} else if (isThirsty) {
			agentColor <- rgb("darkorange");
		} else if (isHungry) {
			agentColor <- rgb("purple");
		}
		
		draw circle(1) color: agentColor;
	}
	
	// ------------------ They Just move around ------------------
	reflex move {
		do wander;
	}
}	




/*  After here there are no more types of guests  */
species building
{
	bool sells_food<- false;
	bool sells_water<- false;	
} 

/* InfoCenter answers question with  information */
species Info_Center parent: building	
{
	list<Stores> Storess<- (Stores at_distance 1000);
	list<Water> Waters<- (Water at_distance 1000);
	
	bool hasLocations <- false;
	
	reflex listStoreLocations when: hasLocations = false
	{
		ask Storess
		{
			write "Food store at:" + location; 
		}	
		ask Waters
		{
			write "Drink store at:" + location; 
		}
		
		hasLocations <- true;
	}
	
	aspect default
	{
		draw cube(6) at: location color: #lightgreen;
		//draw "Info canter";
	}
	
}
 
species Stores parent: building
{
	bool sells_food <- true;
	
	aspect default
	{
		draw pyramid(6) at: location color: #green;
	}
}
 
species Water parent: building
{
	bool sells_water <- true;
	
	aspect default
	{
		draw pyramid(6) at: location color: #gold;
	}
}

species Stage parent: building
{
	//bool sells_food<- false;
	//bool sells_water<- false;	
	
	aspect default
	{
		draw pyramid(10) at: location color: #violet;
		draw "Stage" at:location+{5,5} color:#black;
	}
}

experiment main type: gui
{
	float minimum_cycle_duration <- 0.1;
	
	output
	{
		display map type: opengl
		{
			species Info_Center;
			species Stores;
			species guest_moshpit_dancer;
			species guest_rock_fan;
			species guest_moshpit_dancer;
			species guest_drunk;
			species guest_bullies;
			species Water;
			species Stage;
			
		}

    	display "my_display" {
        	chart "Happiness level histogram" type: histogram {
        		datalist (distribution_of(guest collect each.Happiness,25,0,255) at "legend") 
            	value:(distribution_of(guest collect each.Happiness,25,0,255) at "values");
            	}
        	}
        
        //fisplay two monitors
        //inspect "RockFan_Inspector" value: RockFan attributes: ["Happiness"];
        //inspect "RockFan_Random_Inspector" value: 2 among RockFan type:table;	
	}
}