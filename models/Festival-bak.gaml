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
	
	point Stage_Loc <- {80,50};   // Stage
	int Stage_sz <- 20; // stage size
	int Stage_area<- 20; // the area that stage covers	
	
	point moshpit_Loc <- {60,15};   // moshpit 
	int moshpit_sz <- 10;
	int moshpit_area <- 12;
	
	point guest_Loc <- {80,40};  //Guest spawn location
	point store_Loc <- {30,10};  //Stores with food
	point water_Loc <- {20,10};  //Stores with water

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
		
		create Moshpit number: 1
		{location <- moshpit_Loc;}
		
		create Stage number: Stage_num
		{location <- Stage_Loc;}

		
			}

		}

//////////////////////////////////////////Species below//////////////////////////////////

species guest skills:[moving,fipa]
{

	// Three (3) personal Traits used for the Guests 
	
	float I <- rnd(50)+50.0; // Social (used for Introvert or Extrovert)
	float G <- rnd(50)+50.0; // Genorisity Used for selfish or generous
	float E <- rnd(50)+50.0; // Emotional or Not Emotional 
	
	float Happiness <- rnd(50)+50.0;	// We are measuring this value according to agents interactions 
	float energy <- 100.0 max 100.0; // It will decrease every second and restock after drinking or eating
	float drunkness <- 0.0; // It will decrease every second and restock after drinking or eating  
	//float thirst<- rnd(50)+50.0;   // To have them Drink or not 
	//float hunger<- rnd(50)+50.0;	// Maybe not needed 

	// Base values ofr personality Traits 
	bool isIntrovert <- false;
	bool isExtrovert <- false;
	bool isGenerous <- false;
	bool isSelfish <- false;
	bool isHappy <- false;
	bool isNotHappy <- false;
	
	// To flip decision on whether eating or drinking to get more energy and move
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
 
	reflex updateEnergyAndDrunkness
	{
	    if location distance_to Stage_Loc < Stage_area
	    {
	      energy <- energy - 0.5 * 2;  // reduces by a factor of 2x
	    }
	    else if location distance_to moshpit_Loc < moshpit_area
	    {
	      energy <- energy - 0.5 * 4; // reduces by a factor of 4x
	    }
	    else
	    {
	      energy <- energy - 0.5; // reduces at a normal rate
	      drunkness <- drunkness - 0.1; 
	   }
	}

 /* This reflex prints out the current energy level of each guest to the console
 * This could be a readable value together with happiness.
 */ 

   reflex fromToLoop { // Note:this is fixed
    	//write "Time elapsed: " + stepCounterVariable + " minutes, and the energy level of " + name + " is " + energy + "%" ;
    } 


	reflex restockEnergy // when energy level is low
	{
	  previousLocation  <- location;  // store current location as previous location
	
	  if (energy < 20  and flippingFoodDrinkVariable)  //50% prob to get drink
	  {
	    do goto target:water_Loc speed: guestSpeed;
	    energy <- energy + 1;
	    drunkness <- drunkness + 1 ;
	    write name + " drunk, level of drunkness of " + drunkness +" %" + " and level of energy of: " + energy + " % ";
	    do goto target: previousLocation speed: guestSpeed;  // go back to previous location
	  }
	  else if (energy < 20)   // get food at store
	  {
	    do goto target: store_Loc speed: guestSpeed;
	    energy <- energy + 5;
	    write name + " ate, level of drunkness of " + drunkness +" %" + " and level of energy of: " + energy + " % ";
	    do goto target: previousLocation speed: guestSpeed;  // go back to previous location
	  }
	
	  //do goto target: previousLocation speed: guestSpeed;  // go back to previous location
	}
	
	// Personality Values 
	reflex updatePersonality{
		// To see if an agent is introverted, extrovert, generous, selfish, unHappy or happy...
		if (I < 74) {isIntrovert <- true;}
		if (I > 75) {isExtrovert <- true;}
		if (G > 75) {isGenerous <- true;}
		if (G < 74) {isSelfish <- true;}
		if (Happiness > 70) {isHappy <- true;}
		if (Happiness < 20) {isHappy <- false;} 
	}
	
	reflex SwitchSetOfRules{
		if (energy > 25){
			
		}
	}
	
	// First Place where They hangout 
	reflex rave when: isHappy {
		do goto target:Stage_Loc speed: guestSpeed+1;
		//previousLocation <- location;
		write name + "is raving and going to stage!";
	}
	
	// Second Place where They hangout 
	reflex moshpit when: isHappy and isExtrovert {
		//TODO: add conditions that guest will choose between the two places, like invited by dancer etc
		do goto target:moshpit_Loc speed: guestSpeed+2;
		location <- moshpit_Loc;
		//write name + "is going to moshipit!";	
		}
		
	// third Place where They hangout is the stores  
	
	
	reflex Wander when: target=nil
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
	reflex rave when: isHappy{
		color <- rgb(Happiness,0,0); // Hapiness level indicates the color
	}

	// when at the stage and happy, invite guest_moshpit_dancer to dance
	reflex inviteToDance when: isHappy and (location distance_to(moshpit_Loc) < moshpit_area){
		//// TODO: FIPA to ask guest_moshpit_dancer
		write "RockFan" + name + " invites nearby dancer to dancer";
		do start_conversation with:(to:: list(guest_moshpit_dancer), protocol:: 'fipa-propose', performative:: 'propose', contents:: ['Go dancing?']);
	}
	
	// when receive msg, read and update happiness
	reflex ReadMsg when: (!empty(agrees)){
		loop msg over: agrees {
			if (msg.contents[0] = 'Yes!' and isHappy = true){
				write "RockFan" + name + " 's proposal is accepted. He is happy.";
				Happiness <- 255.0;
			}
			if (msg.contents[0] = 'No!' and isHappy = false){
				//TODO: what will sad rockfan do?
				write "RockFan" + name + " 's proposal got rejected. He is sad."; 
				Happiness <- 0.0;
				do getDrunk;
			}
		}
	}
	
	action getDrunk{
		do goto target:one_of(water_Loc) speed:guestSpeed;
		drunkness <- drunkness + 10;
	}
	
}


/*
 * guest_moshpit_dancer: know how to dance, only dance in the mosh_pit with..
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
		do goto target:moshpit_Loc speed:guestSpeed+2;
		Happiness <- Happiness + rnd(2); 
	}
	
	reflex rave when: energy > 25 and isHappy{
		////
		color <- #limegreen;
	}
	
	reflex RespondToInvitation when: (!empty(proposes)) and (location distance_to(moshpit_Loc) < moshpit_area){  
		// TODO:read the FIPA invitation and respond
		// TODO:enter fever mode and dance
		loop msg over: proposes {
			if (msg.contents[0] = 'Go dancing?' and energy > 25){
				Happiness <- 200.0;
				do start_conversation with:(to: msg.sender, protocol: 'fipa-propose', performative: 'agree', contents: ['Yes!', 'guest_moshpit_dancer']);
			}
			else if (msg.contents[0] = 'Go dancing?' and energy < 20){
				Happiness <- 100.0;
				do start_conversation with:(to: msg.sender, protocol: 'fipa-propose', performative: 'agree', contents: ['No!', 'guest_moshpit_dancer']);
			}
            
        }
        proposes <- [];
	}
}
/*New species added here  */
	
species guest_bullies parent:guest control: simple_bdi{
	bool isHungry <- false update: flip(0.5);
	bool isThirsty <- false update: flip(0.5);
	bool isBully <- true;
	
	string BullyString <- "Looking for someone to bully";
    predicate Bully <- new_predicate(BullyString);
    
    string ChillString <- "Looking for someone to bully";
    predicate NotInTheMood <- new_predicate(ChillString);
    
	init {
		if (isBully) {
			do add_desire(Bully);
		}
	}
	
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
	
	plan IrregateSomeone intention: Bully {
		//TODO do something here with FIPA communication
		do wander;
	}
	
	plan Chill intention:NotInTheMood {
		do wander;
	}
	
}
		
species guest_drunk skills:[moving]{
	bool isHungry <- false update: flip(0.5);
	bool isThirsty <- false update: flip(0.5);
	
	aspect base {
		rgb agentColor <- rgb("green"); //<- rgb(Happiness,0,0);
		
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
		//draw "Info center";
	}
	
}
 
species Stores parent: building
{
	bool sells_food <- true;
	
	aspect default
	{
		draw pyramid(6) at: location color: #green;
		draw "Store" at:location+{5,5} color:#black;
	}
}
 
species Water parent: building
{
	bool sells_water <- true;
	
	aspect default
	{
		draw pyramid(3) at: location color: #gold;
	}
}

species Stage parent: building
{
	aspect default
	{
		draw square(Stage_sz) wireframe:true at: location color: #green;
		draw "Stage" at:location color:#black font: font('Default', 20, #bold);
	}
}

species Moshpit parent: building
{
	aspect default 
	{	
		draw circle(moshpit_sz) wireframe:true at: location color: #black;
		draw "Moshpit" at:location color:#black font: font('Default', 25, #bold);
	}
}

experiment main type: gui
{
	float minimum_cycle_duration <- 0.1;
	
	output
	{
		display map type: opengl 
		{
			//species Info_Center;
			species Stores;
			species Stage transparency:0.5;
			species Moshpit transparency:0.5;	
			species Water;	
							
			species guest;
			species guest_rock_fan;
			species guest_moshpit_dancer;
			species guest_drunk;
			species guest_bullies;	
			
			graphics "clock1" {
        		draw "Tim Elasped:" + stepCounterVariable + "minutes" at:{1,3} color: #black font: font('Default', 15, #bold);
        	}
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