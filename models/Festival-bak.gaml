/**
* Name: Festival Simulation
* Author: Federico Yuyang 
*/


model MusicParty

global{
		//Configuring the values
	
	int guest_num<- 50;
	int InfoCenter_num<-1;
	int Stage_num<-1;
	int store_num<-2;
	int water_num<-2;
	point InfoCent_Loc <- {50,80};
	int InfoCenter_sz<- 20;
	point Stage_Loc <- {80,50};   // Stage Area 
	point guest_Loc <- {80,40};  //Dancing Area next to the stage 
	point store_Loc <- {30,10};  //Stores with food
	point water_Loc <- {20,10};  //Stores with water
	int Stage_sz<- 15;
	float guestSpeed <- 0.5;
	
	
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
	
	
	
	init 
	{
		create guest number: guest_num
		{location <- guest_Loc;}
		
		create guest_rock_fan number: 10
		{location <- guest_Loc;}
		
		create guest_moshpit_dancer number: 10
		{location <- guest_Loc;}
		
		create guest_bullies number: 10
		{location <- guest_Loc;}
		
		create guest_drunk number: 20
		{location <- guest_Loc;}
		
		create Stores number: store_num
		{location <- store_Loc;}
		
		create Water number: water_num
		{location <- water_Loc;		}
		
		create Info_Center number: InfoCenter_num
		{location <- InfoCent_Loc;}
		
		create Stage number: Stage_num
		{location <- Stage_Loc;}

		
			}

		}
	
	

/*
 * 
 * 
 * Guests will dance until they get either thirsty or hungry, then will head to info center 
 * for guidelines on reaching the food and drinks stores
 */



species guest skills:[moving,fipa]
{
	//Rate for hungryness or thirstyness
	int hungerRate <- 5;
	
	float I <- rnd(50)+50.0; // Introvert
	float G <- rnd(50)+50.0; // Generous
	float S <- rnd(50)+50.0; // Selfish
	float E <- rnd(50)+50.0; // emotional		
	bool isIntrovert <- false;
	bool isGenerous <- false;
	bool isSelfish <- false;
	bool isEmotional <- false;
	
	float Happiness <- rnd(50)+50.0;
	
	float thirst<- rnd(50)+50.0;
	float hunger<- rnd(50)+50.0;	

	
	rgb color<- #red;
	
	
	building target<- nil;
	
	aspect default
	{
		draw sphere(2) at: location color:color;
		draw name at: location + {1,1} color: #black font: font('Default', 10, #bold);
		
	}
	
	reflex updatePersonality{
		// To see if an agent is introverted, generous, selfish, emotional or not...
		if (I > 80) {isIntrovert <- true;}
		if (G > 80) {isGenerous <- true;}
		if (S > 80) {isSelfish <- true;}
		if (E > 80) {isEmotional <- true;} 
	}
	
	reflex rave when: Happiness > 80 and thirst>25{
		do goto target:Stage_Loc speed: guestSpeed;
		write name + "is raving and going to stage!";
		hungerRate<-8; // increase hunger rate
	}
	
	/* 
	 *
	 * Once value is below 25, agent will head towards info/Store
	 */	 
	 
	reflex thirstyHungry{
		
		//Decrement thirst and hunger counters
		thirst<- thirst-rnd(hungerRate);
		hunger<- hunger-rnd(hungerRate);
		
		bool getFood<- false;
		
		if(target=nil and (thirst < 25 or hunger < 25)){
			string destinationMessage<- name;
			//write destinationMessage;
			if(thirst < 25 and hunger < 25)
			{
				destinationMessage <- destinationMessage + " is thirsty and hungry,";
			}
			else if(thirst < 25)
			{
				destinationMessage <- destinationMessage + " is thirsty,";
			}
			else if(hunger < 25)
			{
				destinationMessage <- destinationMessage + " is hungry,";
				getFood <- true;
			}
			
			color<- #blue;
			target <- one_of(Info_Center);
			
			destinationMessage <- destinationMessage + " heading to " + target.name;
			write destinationMessage;
			
		}
	} 
		
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
	
	/* 
	 * Guest arrives at the information center
	 * The guests will prioritize the attribute that is lower for them,
	 * if tied then thirst goes first and guest decides to go for a drink
	 */ 
	reflex reachInfoCenter when: target!=nil and target.location= InfoCent_Loc and location distance_to(target.location) < InfoCenter_sz
	{
		string destinationString <- name  + " getting "; 
		ask Info_Center at_distance InfoCenter_sz
		{
			if(myself.thirst <= myself.hunger)
			{
				myself.target <- Waters[rnd(length(Waters)-1)];
				myself.color<- #gold;
				destinationString <- destinationString + "drink at ";
			}
			else
			{
				myself.target <- Storess[rnd(length(Storess)-1)];
				myself.color<- #lightblue;
				destinationString <- destinationString + "food at ";
			}
			
			write destinationString + myself.target.name;
		}
	}
	
	reflex isThisAStore when: target != nil and location distance_to(target.location) < 2
	{
		ask target
		{
			string replenishString <- myself.name;	
			if(sells_food = true)
			{
				myself.hunger <- 1000.0;
				myself.target<-nil;
				myself.color<- #brown;
				replenishString <- replenishString + " ate food at " + name;
			}
			else if(sells_water = true)
			{
				myself.thirst <- 1500.0;
				myself.target<-nil;
				myself.color<- #red;
				replenishString <- replenishString + " had a drink at " + name;
			}
			
			write "replenishString"+replenishString;
			
		}
		hungerRate<-5;
		target <- nil;
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
			if (msg.contents[0] = 'Yes!' and thirst>25){
				Happiness <- 255.0;
			}
			if (msg.contents[0] = 'No!' and isEmotional = true){
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
	
	reflex Dance when: thirst > 25{
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
			if (msg.contents[0] = 'Go dancing?' and thirst>25){
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