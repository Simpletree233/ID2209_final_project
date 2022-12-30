/**
* Name: Festival Simulation
* Author: Federico Yuyang 
*/


model Festival

global{
		//Configuring the values
	
	int guest_num<- 10;
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
	int Stage_sz<- 10;
	float guestSpeed <- 0.5;
	
	//Rate for hungryness or thirstyness
	int hungerRate <- 5;
	
	
	init
	{
		/* Create guest_num (defined above) amount of Guests */
		create guest number: guest_num
		{
	    location <- guest_Loc;
			
		}
		/*
		 * Number of stores is defined above 
		 */
		create Stores number: store_num
		{
			location <- store_Loc;

		}
		
		/*
		 * Number of stores id defined above 
		 */
		create Water number: water_num
		{
			location <- water_Loc;

		}
		
		create Info_Center number: InfoCenter_num
		{
			location <- InfoCent_Loc;
		}
		


		create Stage number: Stage_num
		{
			location <- Stage_Loc;
		}
		
	
		
		
			}

		}
	
	

/*
 * Max value for both is 100
 * Guests enter w/ random 50 - 100
 * Guests will dance until they get either thirsty or hungry, then will head to info center 
 * for guidelines on reaching the food and drinks stores
 */



species guest skills:[moving]
{
	float thirst<- rnd(50)+50.0;
	float hunger<- rnd(50)+50.0;	
	//int guestid<-
	
	rgb color<- #red;
	
	
	building target<- nil;
	
	aspect default
	{
		draw sphere(3) at: location color:color;
	}
	
	/* 
	 *  Thirstyness and hungerness 0 and 0.5
	 * Once value is under  below 25, agent will head towards info/Store
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
		
		target <- nil;
	}
	 
	
}

species RockFan parent: guest
{
	aspect default
	{
		draw cube(2) at: location color: #black;
	}
}



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
	}
	
}



/* 
 * Replenish function.
 */
 
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
		draw pyramid(6) at: location color: #black;
	}
}

experiment main type: gui
{
	
	output
	{
		display map type: opengl
		{
			species Info_Center;
			species Stores;
			species guest;
			species Water;
			species Stage;
			
		}
	}
}