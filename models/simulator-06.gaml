/**
* Name: Simulator
* Author: Lê Đức Toàn
*/


model Simulator


import './transmit-disease-config.gaml'
import './transmit-disease-pig.gaml'


global {
	file pigs;
	int speed;
	string experiment_id;
	
    init {
    	pigs <- csv_file("../includes/input/transmit-disease-pigs.csv", true);
    	speed <- 45;
    	
    	create TransmitDiseasePig from: pigs;
        create Trough number: 5;
        loop i from: 0 to: 4 {
        	Trough[i].location <- trough_locs[i];
        }
        create TransmitDiseaseConfig number: 1;
        TransmitDiseaseConfig[0].day <- 10;
    }
    
    reflex stop when: cycle = 60 * 24 * 55 {
    	do pause;
    }
}

experiment Transmit {
	parameter "Experiment ID" var: experiment_id <- "";
    output {
        display Simulator name: "Simulator" {
            grid Background border: #black;
            species TransmitDiseasePig aspect: base;
        }
        display CFI name: "CFI" refresh: every((60 * 24)#cycles) {
        	chart "CFI" type: series {
        		loop pig over: TransmitDiseasePig {
        			data string(pig.id) value: pig.cfi;
        		}
        	}
        }
        display Weight name: "Weight" refresh: every((60 * 24)#cycles) {
        	chart "Weight" type: histogram {
        		loop pig over: TransmitDiseasePig {
        			data string(pig.id) value: pig.weight;
        		}
        	}
        }
        display CFIPig0 name: "CFIPig0" refresh: every((60 * 24)#cycles) {
        	chart "CFI vs Target CFI" type: series {
        		data 'CFI' value: TransmitDiseasePig[0].cfi;
        		data 'Target CFI' value: TransmitDiseasePig[0].target_cfi;
        	}
        }
        display DFIPig0 name: "DFIPig0" refresh: every((60 * 24)#cycles) {
        	chart "DFI vs Target DFI" type: series {
        		data 'DFI' value: TransmitDiseasePig[0].dfi;
        		data 'Target DFI' value: TransmitDiseasePig[0].target_dfi;
        	}
        }
    }
    
    reflex log when: mod(cycle, 24 * 60) = 0 {
    	ask simulations {
    		loop pig over: TransmitDiseasePig {
    			save [
    				floor(cycle / (24 * 60)),
    				pig.id,
    				pig.target_dfi,
    				pig.dfi,
    				pig.target_cfi,
    				pig.cfi,
    				pig.weight,
    				pig.eat_count,
    				pig.excrete_each_day,
    				pig.excrete_count,
    				pig.expose_count_per_day,
    				pig.recover_count
    			] to: "../includes/output/transmit/" + experiment_id + "-" + string(pig.id) + ".csv" rewrite: false format: "csv";	
    		}
		}		
    }
    
    reflex capture when: mod(cycle, speed) = 0 {
    	ask simulations {
    		save (snapshot(self, "Simulator", {500.0, 500.0})) to: "../includes/output/transmit/" + experiment_id + "-simulator-normal-" + string(cycle) + ".png";
    		save (snapshot(self, "Simulator", {500.0, 500.0})) to: "../includes/output/transmit/" + experiment_id + "-cfi-normal-" + string(cycle) + ".png";
    		save (snapshot(self, "Simulator", {500.0, 500.0})) to: "../includes/output/transmit/" + experiment_id + "-weight-normal-" + string(cycle) + ".png";
    		save (snapshot(self, "Simulator", {500.0, 500.0})) to: "../includes/output/transmit/" + experiment_id + "-cfipig0-normal-" + string(cycle) + ".png";
    		save (snapshot(self, "Simulator", {500.0, 500.0})) to: "../includes/output/transmit/" + experiment_id + "-dfipig0-normal-" + string(cycle) + ".png";
    	}
    }
}