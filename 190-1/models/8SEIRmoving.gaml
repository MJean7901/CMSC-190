/**
* Name: barangay
* Based on the internal empty template. 
* Author: 
* Tags: 
*/


model SEIRMoving

/* Insert your model definition here */

global {
	float environment_size <- 50.0 #m;
	int nb_people <- 30;
    int total_pop <- nb_people update: nb_people;
    float go_out_rate <- 1.0;
    bool social_distancing <- false;
    int mobile_people <- round(nb_people * go_out_rate);
    float agent_speed <- 5.0 #cm/#s;    
    float infection_distance <- 3 #m;
    float proba_infection <- 0.5;
    float min_distance <- 1.0 #m;
    float exposed_distance <- 3 #m;
    float proba_exposed <- 0.5;
    float exposure_rate <- 2/14;
    int init_expoA <- 3;
    int init_expoB <- 3;
    int init_expo <- init_expoA + init_expoB;
    int init_recovA;
    int init_recovB;
    
    int init_infA <-5;
    int init_infB <-5;
    int nb_infected_init <- init_infA + init_infB;
    float step <- 1 #minutes;
    geometry shape <- square(environment_size);
    
	geometry brgy_A;
	geometry brgy_B; 
	int infectedA <- init_infA update: people_A count (each.is_infected);
	int infectedB <- init_infB update: people_B count (each.is_infected);
	int susceptibleA <- nb_people/2 -(init_infA + init_recovA) update: people_A count(each.is_susceptible);
	int susceptibleB <-  nb_people/2-(init_infB + init_recovB) update: people_B count(each.is_susceptible);
	int recoveredA <- init_recovA update: people_A count (each.is_recovered);
	int recoveredB <- init_recovB update: people_B count (each.is_recovered);
	int exposedA <- init_expoA update: people_A count (each.is_exposed);
	int exposedB <- init_expoA update: people_B count (each.is_exposed);
	
	
	int infected <- nb_infected_init update: infectedA +infectedB;
	int susceptible <- nb_people-(nb_infected_init+init_expo)update: (susceptibleA + susceptibleB);
	int recovered <- 0 update: recoveredA +recoveredB;
	int exposed <- init_expo update: exposedA + exposedB; 
	int cycle_number <- 0 update: cycle_number + 1;
	
	float susceptible_rate <- 1.0 update: susceptible / nb_people;
	float infection_rate update: infected / nb_people;
	float recovery_rate update: recovered/nb_people;
	float exposed_rate update: exposed/nb_people;
	reflex end_simulation when: infected = nb_people{
		do pause;
	}
	
	
	
	

	init {
		brgy_A <- polygon([{0,0}, {0,environment_size}, {environment_size/2,environment_size}, {environment_size/2,0}]);
		brgy_B <- polygon([{environment_size/2,0}, {environment_size/2, environment_size}, {environment_size, environment_size}, {environment_size,0}]);
	
		
		point brgy_A_start <- point(brgy_A);
		
		/** 
		create people number: nb_people {
			speed <- agent_speed;
		}
        **/
        
        create people_A number: nb_people/2 {
        	location <- any_location_in (one_of (brgy_A));
        	infectious_period<- rnd(14,18);
        }
        
        create people_B number: nb_people/2 {
        	location <- any_location_in (one_of (brgy_B));
        	infectious_period<- rnd(14,18);
        }
        
		ask init_infA among people_A {
			is_infected <- true;
            is_susceptible <- false;
           is_recovered <- false;
           is_exposed <-false;
		}
		
		ask init_infB among people_B {
			is_infected <- true;
            is_susceptible <- false;
           is_recovered <- false;
           is_exposed <-false;
		}
		
		 
        ask mobile_people among people_A{
        	social_distancing <- true;
        }
        ask mobile_people among people_B{
        	social_distancing <- true;
        }

	}

}



species people_A skills: [moving] {
	bool is_susceptible <- true;
    bool is_infected <- false;
    bool is_recovered <- false;
    bool is_exposed <-false;
    float range <- 3.0 #m;
    list<people_A> neighbors;
    bool social_distancing <- false;
    float distance <- 1.0;
    float agent_speed <- 5.0 #cm/#s;
    int infectious_days <- 0;
    int exposed_days <-0;
    int infectious_period;
    int exposed_period;
    int recovered_days <-0;
    int recovered_period;
    

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
	                    do wander;
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
	         neighbors <- people_A select ((each distance_to self) < 5);
	         
	         if(length(people_A) > 0) {
	         	ask neighbors{
	         		write "Infected:" + neighbors;
	         	}
	         	
	          }
	      
		 }

	   
	   reflex exposed when: is_infected{
	   	ask people_A at_distance exposed_distance {
	   		if(flip(proba_exposed)){
	   			is_exposed<-true;
	   			is_susceptible<-false;
	   			
	   			exposed_period <-2;
	   			write "exposed:" +people_A;
	   		}
	   	}
	   }
	    reflex days_of_exposure when: is_exposed {
	   	if (is_exposed){
	   		exposed_days <- exposed_days +1;
	   		write "exposed days:" + exposed_days;
	   	}
	   	
	   }
		
	      reflex infect when: is_exposed {
		    ask people_A at_distance infection_distance {
		        if (flip(proba_infection)) {
		            is_infected <- true;
		            is_susceptible <- false;
		            
		            
		            infectious_period <- 14;
		            write "infected:" + people_A;
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
		        is_exposed <-false;
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
		        is_exposed<- false;
		        recovered_days <- 0;
		    }
		}

// ... (existing code)

// ... (existing code)


	
		reflex move {
				do wander;
				
			}
			
	    aspect default {
	       // draw circle(0.5) color: is_infected ? #red : #green;
	         
	        //draw circle(range) color: #black wireframe: true;
	        
	        if is_susceptible{
	        	draw circle (0.4) color: #blue;
	        }
	        if is_exposed{
	        	draw circle(0.4) color: #yellow;
	        }
	        if is_infected{
	        	draw circle(0.4) color: #red;
	        }
	        if is_recovered{
	        	draw circle(0.4) color: #green;
	        }
	        
	    }
	}
	
	
	species people_B skills: [moving] {
	bool is_susceptible <- true;
    bool is_infected <- false;
    bool is_recovered <- false;
    bool is_exposed <-false;
    float range <- 3.0 #m;
    list<people_B> neighbors;
    bool social_distancing <- false;
    float distance <- 1.0;
    float agent_speed <- 5.0 #cm/#s;
    int infectious_days <- 0;
    int exposed_days <-0;
    int infectious_period;
    int exposed_period;
    int recovered_days <-0;
    int recovered_period;
    

		reflex wander {
	    if flip(1.0) {
	        if (social_distancing = true) {
	            ask mobile_people among people_B {
	                // Calculate the distance to other people and adjust speed accordingly
	                float min_distance <- people_B select ((each distance_to self) < 1.0 #m);
	                if (min_distance < 1.0 #m) {
	                    speed <- 0.0; // Stop moving if too close
	                } else {
	                    speed <- rnd(0.0, 1.0 #m);
	                    do wander;
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
	         neighbors <- people_B select ((each distance_to self) < 5);
	         
	         if(length(people_B) > 0) {
	         	ask neighbors{
	         		write "Infected:" + neighbors;
	         	}
	         	
	          }
	      
		 }

	   
	   reflex exposed when: is_infected{
	   	ask people_B at_distance exposed_distance {
	   		if(flip(proba_exposed)){
	   			is_exposed<-true;
	   			is_susceptible<-false;
	   			
	   			exposed_period <-2;
	   			write "exposed:" +people_B;
	   		}
	   	}
	   }
	    reflex days_of_exposure when: is_exposed {
	   	if (is_exposed){
	   		exposed_days <- exposed_days +1;
	   		write "exposed days:" + exposed_days;
	   	}
	   	
	   }
		
	      reflex infect when: is_exposed {
		    ask people_B at_distance infection_distance {
		        if (flip(proba_infection)) {
		            is_infected <- true;
		            is_susceptible <- false;
		            
		            
		            infectious_period <- 14;
		            write "infected:" + people_B;
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
		        is_exposed <-false;
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
		        is_exposed<- false;
		        recovered_days <- 0;
		    }
		}

// ... (existing code)

// ... (existing code)


	
		reflex move {
				do wander bounds: brgy_B;
				
			}
			
	    aspect default {
	       // draw circle(0.5) color: is_infected ? #red : #green;
	         
	        //draw circle(range) color: #black wireframe: true;
	        
	        if is_susceptible{
	        	draw circle (0.4) color: #blue;
	        }
	        if is_exposed{
	        	draw circle(0.4) color: #yellow;
	        }
	        if is_infected{
	        	draw circle(0.4) color: #red;
	        }
	        if is_recovered{
	        	draw circle(0.4) color: #green;
	        }
	        
	    }
	}

	
	
	/*reflex end_simulation when: infected = total_pop{
		do pause;
	}*/

 //end people



experiment main_experiment type: gui {
	parameter "Initial Human Population " var: nb_people;
	parameter "Infection distance" var: infection_distance;
	parameter "Proba infection" var: proba_infection min: 0.0 max: 1.0;
	parameter "Nb people infected at init" var: nb_infected_init;
	parameter "Nb people infected in City 1" var: init_infA;
	parameter "Nb people infected in City 2" var: init_infB;
	parameter "Nb people susceptible in City 1" var: susceptibleA;
	parameter "Nb people susceptibe in City 2" var: susceptibleB;
	parameter "Nb people exposed in City 1" var: exposedA;
	parameter "Nb people exposed in City 2" var: exposedB;
    output {
    	monitor "Initial Population" value: nb_people;
    	monitor "Number of infected agents" value: infected;
    	monitor "Number of infected agents in City 1" value: infectedA;
    	monitor "Number of infected agents in City 2" value: infectedB;
    	monitor "Number of susceptible agents" value: susceptible;
    	monitor "Number of susceptible agents in City 1" value: susceptibleA;
    	monitor "Number of susceptible agents in City 2" value: susceptibleB;
    	monitor "Number of recovered agents in City 1" value: recoveredA;
    	monitor "Number of recovered agents in City 2" value: recoveredB;
    	monitor "Number of recovered Agents" value: recovered;
    	monitor "Number of exposed in City 1" value: exposedA;
    	monitor "Number of exposed in City 1" value: exposedB;
    	
    	monitor "Infection rate:" value: infection_rate;
    	monitor "Number of cycles" value: cycle_number;
    	
    	
        display map {
        	graphics "areas" transparency: 0.8 {
		        draw brgy_A color: #green;
				draw brgy_B color: #red;
			}
            species people_A; // 'default' aspect is used automatically    
            species people_B;        
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
				data "exposed" value: exposed_rate color: #yellow;
			}
		}
    }

    
}
