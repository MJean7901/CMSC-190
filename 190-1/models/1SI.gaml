/**
* Name: Simple SI Model
* Author: Legaspi, Myla & Sinco, Chezca
* Description: First part of the tutorial : Incremental Model
* Tags: tutorial, gis
*/
model SI_city

global {
    int init_human_pop <- 20;
    int total_pop <- init_human_pop update: init_human_pop;
    int infectious_days <- 14 #days;
    float go_out_rate <- 1.0;
    bool social_distancing <- false;
    int mobile_people <- round(init_human_pop * go_out_rate);
    float agent_speed <- 5.0 #cm/#s;    
    float infection_distance <- 3 #m;
    float proba_infection <- 0.25;
    float min_distance <- 1.0 #m;
    int init_inf <- 3;
    float step <- 1 #minutes;
    geometry shape <- envelope(square(50 #m));
    
    int infected <- init_inf update: people count (each.is_infected);
	int susceptible <- init_human_pop - init_inf update: people count (each.is_susceptible);
	int cycle_number <- 0 update: cycle_number + 1;
    init {
        create people number: init_human_pop {
        	location <- any_location_in(shape);
            speed <- agent_speed;
        }

        ask init_inf among people {
            is_infected <- true;
            is_susceptible <- false;
           
            
        }
        
        ask mobile_people among people{
        	social_distancing <- true;
        }
   }



/* Behavior  */

species people skills: [moving] {
	bool is_susceptible <- true;
    bool is_infected <- false;
    float range <- 3.0 #m;
    list<people> neighbors;
    bool social_distancing <- false;
    float distance <- 1.0;
    float agent_speed <- 5.0 #cm/#s;
    

	reflex wander {
    if flip(1.0) {
        if (social_distancing = true) {
            ask mobile_people among people {
                // Calculate the distance to other people and adjust speed accordingly
                float min_distance <- people select ((each distance_to self) < 1.0 #m);
                if (min_distance < 1.0 #m) {
                    speed <- 0.0; // Stop moving if too close
                } else {
                    speed <- rnd(0.0, 1.0 #m);
                    do wander bounds: shape;
                }
            }
        } else {
            speed <- rnd(0.0, 1.0 #m);
            do wander;
        }
    }
}
	/*reflex wander {
			if flip(1.0) {
				if (can_go_out = false) {
					speed <- rnd(0.0, 1.0);
					do wander bounds: shape;
				} else {
					do wander;
				}
			}
		} */

    
    reflex compute_neighbors {
         neighbors <- people select ((each distance_to self) < 5);
         
         if(length(people) > 0) {
         	ask neighbors{
         		write "Infected:" + neighbors;
         	}
         	
         	}
      
         }

   reflex infect when: is_infected {
    ask people at_distance infection_distance {
        if (flip(proba_infection)) {
            is_infected <- true;
            is_susceptible <- false;
            write "infected:" + people;
        }
    }
}
	




	reflex move {
			do wander;
			distance <- distance + speed;
		}
		
    aspect default {
        draw circle(0.5) color: is_infected ? #red : #green;
        //draw circle(range) color: #black wireframe: true;
        
    }
}

	float susceptible_rate <- 1.0 update: susceptible / init_human_pop;
	float infection_rate update: infected / init_human_pop;
	
	reflex end_simulation when: infected = total_pop{
		do pause;
	}

}



experiment main_experiment type: gui {
	parameter "Initial Human Population" var: init_human_pop;
    parameter "Infection distance" var: infection_distance;
    parameter "Proba infection" var: proba_infection min: 0.0 max: 1.0;
    parameter "Nb people infected at init" var: init_inf ;
    //parameter "Social Distancing" var: social_distancing;
    
    output {
    	monitor "Initial Population" value: init_human_pop;
    	monitor "Current Population" value: total_pop;
    	monitor "Number of infected agents" value: infected;
    	monitor "Number of susceptible agents" value: susceptible;
    	monitor "Infection rate:" value: infection_rate;
    	monitor "Number of cycles" value: cycle_number;
    	
        display map {
            species people; // 'default' aspect is used automatically            
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
				data "susceptible" value: susceptible_rate color: #green ;
				
			}
		}
    }

    
}

