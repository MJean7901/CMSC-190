/**
* Name: Simple SI Model
* Author: Legaspi, Myla & Sinco, Chezca
* Description: First part of the tutorial : Incremental Model
* Tags: tutorial, gis
*/
model SIR_city

global {
    int init_human_pop <- 30;
    int total_pop <- init_human_pop update: init_human_pop;
    
    float go_out_rate <- 1.0;
    bool social_distancing <- false;
    int mobile_people <- round(init_human_pop * go_out_rate);
    float agent_speed <- 5.0 #cm/#s;    
    float infection_distance <- 3 #m;
    float proba_infection <- 0.5;
    float min_distance <- 1.0 #m;
    int init_inf <- 10;
    int init_recov;
    float step <- 1 #minutes;
    geometry shape <- envelope(square(50 #m));
    
    int infected <- init_inf update: people count (each.is_infected);
	int susceptible <- init_human_pop - (init_inf + init_recov) update: people count (each.is_susceptible);
	int recovered <- 0 update: people count (each.is_recovered);
	
	int cycle_number <- 0 update: cycle_number + 1;
    init {
        create people number: init_human_pop {
        	location <- any_location_in(shape);
            speed <- agent_speed;
            infectious_period <- 14;
        }

        ask init_inf among people {
            is_infected <- true;
            is_susceptible <- false;
           is_recovered <- false;
            
        }
        
        ask mobile_people among people{
        	social_distancing <- true;
        }
   }
species environment {
	aspect shape{
		draw shape color: #white border: #black;
	}
}


/* Behavior  */

species people skills: [moving] {
	bool is_susceptible <- true;
    bool is_infected <- false;
    bool is_recovered <- false;
    float range <- 3.0 #m;
    list<people> neighbors;
    bool social_distancing <- false;
    float distance <- 1.0;
    float agent_speed <- 5.0 #cm/#s;
    int infectious_days <- 0;
    int infectious_period;
    int recovered_days <-0;
    int recovered_period;
    

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
		            
		            
		            infectious_period <- 14;
		            write "infected:" + people;
		        }
		    }
		   
	   }
	   
	   reflex days_of_infection when: is_infected {
	   	if (is_infected){
	   		infectious_days <- infectious_days +1;
	   		write "infectious days:" + infectious_days;
	   	}
	   	
	   }
		
		// ... (existing code)

// ... (existing code)

		reflex recovered when: is_infected {
		    if (infectious_days >= infectious_period) {  // Use >= instead of =
		        is_recovered <- true;
		        is_infected <- false;
		        recovered_days <- 0;
		        
		        // Assuming recovered_period should be based on some parameter, adjust accordingly
		        recovered_period <- 50; // Set a meaningful value or use a parameter
		        
		        write "Recovered: " + self; // Use 'self' to refer to the current agent
		    }
		}
		
		reflex days_of_recovery when: is_recovered {
		    recovered_days <- recovered_days + 1;
		}
		
		reflex get_susceptible when: is_recovered {
		    if (recovered_days >= recovered_period) {  // Use >= instead of =
		        is_recovered <- false;
		        is_susceptible <- true;
		        recovered_days <- 0;
		    }
		}

// ... (existing code)

// ... (existing code)


	
		reflex move {
				do wander;
				distance <- distance + speed;
			}
			
	    aspect default {
	       // draw circle(0.5) color: is_infected ? #red : #green;
	         
	        //draw circle(range) color: #black wireframe: true;
	        
	        if is_susceptible{
	        	draw circle (0.4) color: #blue;
	        }
	        if is_infected{
	        	draw circle(0.4) color: #red;
	        }
	        if is_recovered{
	        	draw circle(0.4) color: #green;
	        }
	        
	    }
	}

	float susceptible_rate <- 1.0 update: susceptible / init_human_pop;
	float infection_rate update: infected / init_human_pop;
	float recovery_rate update: recovered/init_human_pop;
	
	/*reflex end_simulation when: infected = total_pop{
		do pause;
	}*/

 }//end people



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
    	monitor "Number of recovered:" value: recovered;
    	
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
				data "recovered" value: recovery_rate color: #green ;
				data "susceptible" value: susceptible_rate color: #blue ;
				
			}
		}
    }

    
}