/**
* Name: barangay
* Based on the internal empty template. 
* Author: 
* Tags: 
*/


model barangay

/* Insert your model definition here */

global {
	float environment_size <- 50.0 #m;
	int nb_people <- 30;
    float agent_speed <- 5.0 #m/#s;	
	float infection_distance <- 3.0;
	float proba_infection <- 0.05;
	int init_infA <- 4;
	int init_infB <- 4;
	float go_out_rate <- 1.0;
	bool social_distancing <- false;
	int mobile_people <- round(nb_people * go_out_rate);
	int nb_infected_init <- init_infA + init_infB;
//	float step <- 45 #seconds;
//	geometry shape <- envelope(square(300 #m));

    geometry shape <- square(environment_size);
    
	geometry brgy_A;
	geometry brgy_B; 
	
	int infectedA <- init_infA update: people_A count (each.is_infected);
	int infectedB <- init_infB update: people_B count (each.is_infected);
	int susceptibleA <- nb_people/2 -init_infA update: people_A count(each.is_susceptible);
	int susceptibleB <-  nb_people/2-init_infA update: people_B count(each.is_susceptible);
	
	
	
	

	init {
		brgy_A <- polygon([{0,0}, {0,environment_size}, {environment_size/2,environment_size}, {environment_size/2,0}]);
		brgy_B <- polygon([{environment_size/2,0}, {environment_size/2, environment_size}, {environment_size, environment_size}, {environment_size,0}]);
	
		
		
		
		/** 
		create people number: nb_people {
			speed <- agent_speed;
		}
        **/
	        create people_A number: nb_people/2 {
	        	location <- any_location_in (one_of (brgy_A));
	        }
        
	        create people_B number: nb_people/2 {
	        	location <- any_location_in (one_of (brgy_B));
	        }
        
        
        
        
		ask init_infA among people_A {
			is_infected <- true;
			is_susceptible <- false;
		}
		
		ask init_infB among people_B {
			is_infected <- true;
			is_susceptible <- false;
		}

	}





species people_A skills: [moving] {
	float size <- 0.5;
	float speed <- 1.0;
	list<people_A> targets;
	bool is_infected <- false;
	bool is_susceptible <-true;
	
	reflex wander {
	    if flip(1.0) {
	        if (social_distancing = true) {
	            ask mobile_people among people_A {
	                // Calculate the distance to other people and adjust speed accordingly
	                float min_distance <- people_A select ((each distance_to self) < 1.0 #m);
	                if (min_distance < 1.0 #m) {
	                    speed <- 0.0; // Stop moving if too close
	                } else {
	                    speed <- rnd(0.0, 1.0 #m);
	                    do wander bounds: brgy_A;
	                }
	            }
	        } else {
	            speed <- rnd(0.0, 1.0 #m);
	            do wander bounds: brgy_A;
	        }
	    }
	}

	reflex move {
		do wander;
	}

	reflex infect when: is_infected {
		ask people_A at_distance infection_distance {
		//	if (proba_infection > 0.2) {
		    if (flip(proba_infection)) {
				is_infected <- true;
				is_susceptible <- false;
				
			}
		}
	}
	
	reflex mysendmessage {
		targets <- people_A at_distance infection_distance;
		
		if(proba_infection > 0.2){
			ask targets {
				write "I ("+name+"): " + targets + "INFECTED";
			}
		}
	}

	aspect default {
		draw circle(size) color: is_infected ? #red : #blue;
		
	}
	
	aspect base {
		//draw circle(infection_distance) color: #black wireframe: true;
		//ask people_A at_distance(infection_distance){
		//	draw polyline([self.location,myself.location]) color: #red;
		}
	}


species people_B skills: [moving] {
	float size <- 0.5;
	float speed <- 1.0;
	list<people_B> targets;
	bool is_infected <- false;
	bool is_susceptible <-true;
	

	reflex move {
		do wander;
	}

	reflex infect when: is_infected {
		ask people_B at_distance infection_distance {
		//	if (proba_infection > 0.2) {
		    if (flip(proba_infection)) {
				is_infected <- true;
				is_susceptible <- false;
				
			}
		}
	}
	
	reflex mysendmessage {
		targets <- people_B at_distance infection_distance;
		
		if(proba_infection > 0.2){
			ask targets {
				write "I ("+name+"): " + targets + "INFECTED";
			}
		}
	}

	aspect default {
		draw circle(size) color: is_infected ? #red : #blue;
		
	}
	
	aspect base {
		//draw circle(infection_distance) color: #black wireframe:true;
		ask people_B at_distance(infection_distance){
			//draw polyline([self.location,myself.location]) color: #red;
		}
	}
	
	
	
	
}
	int infected <- nb_infected_init update: infectedA + infectedB;
	int susceptible <- nb_people-nb_infected_init update: (susceptibleA + susceptibleB);
	int cycle_number <- 0 update: cycle_number + 1;
	
		float susceptible_rate <- 1.0 update: susceptible / nb_people;
		float infection_rate update: infected / nb_people;
		reflex end_simulation when: infected = nb_people{
			do pause;
		}

}

	


experiment main_experiment type: gui { 
	parameter "Initial Human Population " var: nb_people;
	parameter "Infection distance" var: infection_distance;
	parameter "Proba infection" var: proba_infection min: 0.0 max: 1.0;
	parameter "Nb people infected at init" var: nb_infected_init;
	parameter "Nb people infected in City 1" var: init_infA;
	parameter "Nb people infected in City 2" var: init_infB;
	parameter "Nb people susceptible in City 1" var: susceptibleA;
	parameter "Nb people susceptibe in City 2" var: susceptibleB;

	
	output {
		monitor "Initial Population" value: nb_people;
    	monitor "Number of infected agents" value: infected;
    	monitor "Number of infected agents in City 1" value: infectedA;
    	monitor "Number of infected agents in City 2" value: infectedB;
    	monitor "Number of susceptible agents" value: susceptible;
    	monitor "Number of susceptible agents in City 1" value: susceptibleA;
    	monitor "Number of susceptible agents in City 2" value: susceptibleB;
    	monitor "Infection rate:" value: infection_rate;
    	monitor "Number of cycles" value: cycle_number;
		display map {
			graphics "areas" transparency: 0.8 {
		        draw brgy_A color: #green;
				draw brgy_B color: #red;
			}
			
			species people_A; // 'default' aspect is used automatically	
			species people_A aspect: base;		
			
			species people_B; // 'default' aspect is used automatically	
			species people_B aspect: base;
		}
		display SI type: java2D refresh: every(5 #cycles) {
			chart "Susceptible and Infection Rate" type: series 
			x_label: "Day"
			y_label: "Rate"
			x_tick_line_visible: false
			y_range: [0,1.0] // can be modified depending
							 // maximum rate
		
			{
				
				// data "susceptible" value: susceptible_rate color: #blue ;
				
				data "infected" value: infection_rate color: #red;
				//data "recovered" value: recovery_rate color: #green ;
				data "susceptible" value: susceptible_rate color: #blue ;
				
			}
		}
	}
}
