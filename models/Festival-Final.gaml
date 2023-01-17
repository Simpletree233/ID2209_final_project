/**
* Name: Festival Simulation
* Author: Federico- Yuyang 
*/


model MusicParty

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


global{
	//Configuring the values  
	int guest_num<- 10;
	int InfoCenter_num<-1;
	int Stage_num<- 2;
	int store_num<- 2;
	int water_num<- 2;
	
	// Interval for changing Stage shows
	int TimeInterval <- 60;
	
	//location and size
	list<point> Stage_Loc <- [{80,50},{20,70}];   // Stage
	int Stage_sz <- 20; // stage size
	int Stage_area<- 20; // the area that stage covers	
	
	point moshpit_Loc <- {60,15};   // moshpit 
	int moshpit_sz <- 10;
	int moshpit_area <- 12;
	
	point guest_Loc <- {80,40};  //Guest spawn location
	point store_Loc <- {30,10};  //Stores with food
	point water_Loc <- {20,10};  //Stores with water

	float guestSpeed <- 1.0;
	point previousLocation <- guest_Loc;
	
	string lookingForFriendsString <- "Looking for an interesting guest_rock_fan";
    predicate lookingForFriends <- new_predicate(lookingForFriendsString);
    
    string found_a_new_friendString <- "Found a guest_rock_fan with music";
    predicate found_a_new_friend <- new_predicate(found_a_new_friendString);
	
	//global init
	init 
	{
		create guest number: guest_num
		{location <- guest_Loc;}
		
		create guest_rock_fan number: 1
		{location <- guest_Loc;}
		
		create guest_moshpit_dancer number: 1
		{location <- guest_Loc;}
		
		create guest_bullies number: 1
		{location <- {rnd(100), rnd(100)};}
		
		create guest_drunk number: 1
		{location <- {rnd(100), rnd(100)};}
		
		create Store number: store_num
		{location <- store_Loc;}
		
		create Water number: water_num
		{location <- water_Loc;	}
		
		create Moshpit number: 1
		{location <- moshpit_Loc;}
		
		int i <- 0;
		create Stage number: Stage_num
		{	location <- Stage_Loc[i];
			i <- i+1;
		}
			}

}


//////////////////////////////////////////Species below//////////////////////////////////
/*We have used a global Guest species, and used simple_bdi for making friends  */

species guest skills:[moving,fipa] control: simple_bdi {
	// Begin set of rules using  BDI to make friends according to other types #
	int viewDistance <- 10;
	bool isInterestedInMusic <- flip(0.5);
	bool isInterestedInMakingFriends <- false;
	
	// guest preference parameters
	list<float> values <- [];
    float mySpeed <- guestSpeed;
    bool valuesReceived <- false;
    list<list<float>> stageValues <- [];
    list<float> utilityPerStage <- [0.0, 0.0];
	
	// Three (3) personal Traits used for the Guests 
	float I <- rnd(50)+50.0; // Social (used for Introvert or Extrovert)
	float G <- rnd(50)+50.0; // Genorisity Used for selfish or generous
	float E <- rnd(50)+50.0; // Emotional or Not Emotional 
	
	//other status parameters
	float Happiness <- rnd(50)+50.0;	// We are measuring this value according to agents interactions 
	float energy <- 100.0 max 100.0; // It will decrease every second and restock after drinking or eating
	float drunkness <- 0.0; // It will decrease every second and restock after drinking or eating  

	// Base bool values ofr personality Traits 
	bool isIntrovert <- false;
	bool isExtrovert <- false;
	bool isGenerous <- false;
	bool isSelfish <- false;
	bool isEmotional <- false;
	bool isHappy <- false;
	
	// To flip decision on whether eating or drinking to get more energy and move
	bool flippingFoodDrinkVariable <- true update: flip(0.5);	
	
	rgb color;
	
	building target<- nil;
	
	//init
	init {
		// Update personality: To see if an agent is introverted, extrovert, generous, selfish, unHappy or happy...
		if (I < 60) {isIntrovert <- true;}
		if (I > 75) {
			isExtrovert <- true; 
			isInterestedInMakingFriends <- true;}
		if (G > 75) {isGenerous <- true;}
		if (G < 74) {isSelfish <- true;}
		if (E > 74) {isEmotional <- true;}
		if (Happiness > 70) {isHappy <- true;}
		if (Happiness < 20) {isHappy <- false;}
		
		if (isInterestedInMakingFriends) {
			// At this moment, the intention list is empty. So, the first item in the desire list will be added to the intention list.
			// In other words, here, the first intention is equal to the first desire--lookingForFriends.
        	do add_desire(lookingForFriends);
        }
     
        //init preference value
        loop times: 6  {values << rnd(100.0)/10.0;}	

    }
    
    //visual parameters
	aspect default {
		rgb agentColor <- rgb("green");
		
		if (isInterestedInMusic and isInterestedInMakingFriends) {
			agentColor <- rgb("red");
		} else if (isInterestedInMusic) {
			agentColor <- rgb("darkorange");
		} else if (isInterestedInMakingFriends) {
			agentColor <- rgb("purple");
			
		}
				
      	draw circle(1) color: agentColor border: #black;
      	//draw name at: location + {1,1} color: #black font: font('Default', 10, #bold);
      	//draw circle(viewDistance) color: agentColor border: #pink wireframe: true;
	}
			
	//BDI function
	//agents have a set of rules to deal with other types 
	
	// The darkorange agents will stop after they find a music guest_rock_fan.
	perceive target: guest where (each.isHappy = true and self.isInterestedInMusic and not self.isInterestedInMakingFriends) in: viewDistance {
        focus id:found_a_new_friendString var:location;
        ask myself {
			// Myself: guest_rock_fan
			// Self: guests
            do remove_intention(lookingForFriends, true);
        }
    }
	
	// The red agents will continue wandering even after they find a music guest_rock_fan.
	perceive target: guest where (each.isHappy = true and self.isInterestedInMusic and self.isInterestedInMakingFriends) in: viewDistance {
        focus id:found_a_new_friendString var:location;
        ask myself {
            do remove_intention(lookingForFriends, false);
        }
    }
    
    // Plan for achieving the 'lookForFriends' intention 
	plan lookForFriend intention: lookingForFriends {
		target <- nil;
	}
	
	
	//Ends BDI for setz of rules 
	
    predicate preferredStage <- new_predicate('has a preferred stage');
    //choosing preferred stage
    reflex getStageInformation when: time mod TimeInterval = 0 {
    	stageValues <- [];
    	//do inform with:(message: message(a), contents: ["Send me values"]);
        do start_conversation with:(to:: list(Stage), protocol:: 'fipa-request', performative:: 'inform', contents:: ['Send Values']);
        //write name + ": Let me know the stage attribute values!";       
     }
     
     reflex ChooseStage when: valuesReceived {
        valuesReceived <- false;
        utilityPerStage <- [0.0, 0.0];
        
        //write name + ":" + length(stageValues);
        // loop for calculating utility values
        loop i from: 0 to: Stage_num - 1 {   // for every Stage
            loop j from: 0 to: length(stageValues) - 1 {    // for every stage attribute value
                list<float> currentStageValues <- stageValues[i];
                utilityPerStage[i] <- utilityPerStage[i] + (currentStageValues[j] * values[j]);
            }
            //stageColors << Stage[i].color;
        }
       
       	// choose max utility and its index
        float maxValue <- max(utilityPerStage);
        int maxIndex <- 0;       
        loop k from:0 to: length(utilityPerStage) - 1 {
        	if(maxValue = utilityPerStage[k]) {
        		maxIndex <- k;
        	}
        }       
        target.location <- Stage_Loc[maxIndex];
        //color <- stageColors[maxIndex];
        //write name + ": likes to enjoy the show in Stage  " + maxIndex + " now.";
     }
     
     reflex receiveValues when: (!empty(informs)) {
     	loop msg over: informs {
            stageValues << msg.contents[0];
        }
        valuesReceived <- true;
        informs <- [];
     }
 
 // go to target if any    
	reflex Wander when: target=nil
	{
		do wander;
		//color<- #purple;
		Happiness <- Happiness + rnd(-5,5);
	}
	
	//Move towards target
	reflex moveToTarget when: target!=nil
	{
		do goto target:target.location speed:mySpeed;
	} 		
	
/*All the guests are given 100 % of energy, the concert last 6 hrs, 
 * and depending of their activities they lose energy levels by the minute. 
 * If they moshpit energy increases more than if they are just dancing or somewhere else.
 * The energy level will be used to go to eat or drink to restock their energy levels.
 */ 
 
	reflex updateEnergyAndDrunkness
	{
	    if location distance_to any(Stage_Loc) < Stage_area
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
	reflex restoreEnergy // when energy level is low
	{	
	  	if (energy < 20 and flippingFoodDrinkVariable) {
	  		target.location <- water_Loc;
	  		do remove_intention(lookingForFriends, true);
	  	} 
	  	else if (energy < 20) {
	  		target.location <- store_Loc;
	  		do remove_intention(lookingForFriends, true);
	  	} 
	  	//write name + " drunk, level of drunkness of " + drunkness +" %" + " and level of energy of: " + energy + " % ";
	  	
	  	if location distance_to any(Store) < 5.0  {energy <- 100.0;}
	  	if location distance_to any(Water) < 4.0  {drunkness <- drunkness + 1.0;}
	}
	
	reflex SpeedUpdate 
	{
		if energy < 30 {mySpeed <- 3.0;}
		if energy < 10 {mySpeed <- 4.0;}
		if drunkness > 20 {mySpeed <- 1.5;}
		if energy < 30 {mySpeed <- 3.0;}
		if energy < 30 {mySpeed <- 3.0;}		
		if energy < 30 {mySpeed <- 3.0;}		
	}
	
	//Global reflex that Respond to all FIPA proposes
	reflex Responding when: (!empty(proposes)) {
		loop msg over:proposes {
			if (msg.contents[0] = "XXX" and isHappy = false) {
				do wander;
			}
			
			else if (msg.contents[0] = "XXX") {
				do wander;
			}
		}
		proposes <-[];
	}
	
	// First Place where They hangout 
	reflex rave when: isHappy {
		do goto target:one_of(Stage_Loc) speed: mySpeed+1;
		//previousLocation <- location;
		//write name + "is raving and going to stage!";
	}
	
	// Second Place where They hangout 
	reflex moshpit when: isHappy and isExtrovert {
		//TODO: add conditions that guest will choose between the two places, like invited by dancer etc
		do goto target:moshpit_Loc speed: mySpeed+2;
		location <- moshpit_Loc;
		//write name + "is going to moshipit!";	
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
		do goto target:one_of(water_Loc) speed:mySpeed;
		drunkness <- drunkness + 10;
	}
	
}


/*
 * guest_moshpit_dancer: know how to dance, only dance in the mosh_pit.
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
	bool isBully <- true;   // not being used  
	
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

 
species Store parent: building
{
	bool sells_food <- true;
	
	aspect default
	{
		draw pyramid(6) at: location color: #green;
		draw "Store" at:location+{3,3} color:#black;
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

species Stage parent: building skills:[fipa]
{
	list<float> values <- [];
	rgb color;
	
	init {
		loop times: 6 {
			values << rnd(100.0)/10.0;
		}
	}
	
	reflex reAssignValues when: time mod TimeInterval = 0 {  //every 60 loops reassign the values
		values <- [];
		loop times: 6 {
			values << rnd(100.0)/10.0;
		}
		//write "Stage: Change the values" ;
	}
	
	reflex sendValues when: !empty(informs) {
		//write name + ": Message received, sending values to the guests";
		loop msg over: informs {
			//do start_conversation with:(to::msg.sender,protocol:: 'fipa-request', performative:: 'inform',contents:: [values]);
			do inform with:(message:msg, contents:[values]);
		}
		informs <- [];
	}
	
	aspect default
	{
		draw square(Stage_sz) wireframe:true at: location color: #green;
		draw name at:location color:#black font: font('Default', 20, #bold);
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
			species Store;
			species Stage ;
			species Moshpit transparency:0.5;	
			species Water;	
							
			species guest;
			species guest_rock_fan;
			species guest_moshpit_dancer;
			species guest_drunk;
			species guest_bullies;	
			
			graphics "clock1" {
        		draw "Tim Elasped:" + time + "minutes" at:{1,3} color: #black font: font('Default', 15, #bold);
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