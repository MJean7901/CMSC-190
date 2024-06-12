# Title: Assessing Respiratory Infectious Disease Transmission in Public School Settings: An Agent-Based Modeling Approach at Pines City National High School

# Author: Myla Jean C. Legaspi

# Date: June 2024

## Abstract

In the Philippine educational landscape, congestion and overpopulation in classrooms present a significant challenge in curbing the transmission of respiratory infectious diseases. The close proximity of students and staff, stemming from limited space and high student-to-classroom ratios, escalates the risk of disease dissemination within school premises.

This paper employs Agent-Based Modeling to develop a framework for understanding the dynamics of respiratory infectious disease transmission within school environments, particularly focusing on Pines City National High School. It identifies the effects of various key factors influencing disease spread, including protection rates, initial exposure rates, and the implementation of non-pharmaceutical interventions such as lockdowns and quarantine areas.

The simulation employs QGIS and AutoCAD to create the structure of the shapefile or simulation area, and the GAMA Platform for the actual simulation. In scenarios where there’s a varying protection rate, it shows that starting with 0% protection, the infection rate is 93.1%, but it decreases to 25% with 100% protection. Each 25% increase in protection results in approximately a 20% decrease in infection rate. The study underscores the significance of comprehensive immunity measures, with higher protection rates associated with fewer infections.

In addition, the impact of initial exposure rates on respiratory infectious disease transmission shows that infection rates rise steeply with increased initial exposure rates: 61.20% at 25% exposure (+3.63%), 74.20% at 50% exposure (+16.63%), and peak at 80.20% at 75% exposure (+22.63%). This concludes that as the initial exposure rate increases, the percentage of infected individuals also increases.

Implementation of lockdown and quarantine areas also shows that without lockdown and quarantine, the rate peaks at 55.01%. With lockdown but no quarantine, it drops to 28.54% (-26.47%). When only a quarantine area is implemented, the rate is 30.16% (-24.85%). With both lockdown and quarantine, it further decreases to 28.67% (-26.34%). These findings highlight the effectiveness of containment strategies in controlling infection rates during a pandemic.

## Setting Up the Simulation

### 1. Installation of GAMA Platform

The platform used for the simulation is GAMA. GAMA is a modeling and simulation development environment for building spatially explicit agent-based simulations. To install the GAMA Platform, simply click on the link provided below:

[GAMA Platform](https://gama-platform.org)

Choose the operating system of your choice; GAMA is compatible with Linux, Windows, and macOS.

### 2. Launching GAMA and Importing Files

Once the installation of GAMA is complete, click on the application to open it. To import a file, follow these steps:

1. Navigate to the location where the GAMA project(s) you want to import are stored. This could be a folder containing a single project or a collection of projects. You have two options: use "Select root directory" to choose a folder containing the project, or "Select archive file" to choose an archive file (such as the Legaspi_CMSC190.zip file) that contains the project.
   
2. From the list of available projects, select the projects to import (specifically, the Legaspi_CMSC190 as determined by GAMA). Projects can only be imported if they do not already exist in the workspace. Note that the project consists of several .gaml models: 0Lockdown.gaml, 1Lockdown.gaml, 2QLockdown.gaml, 3NQLockdown.gaml, ER1.gaml, ER2.gaml, ER3.gaml, ER4.gaml, PR1.gaml, PR2.gaml, PR3.gaml, PR4.gaml, and PR5.gaml, as well as the building, road shapefiles, hallways, and quarantine area shapefiles necessary for creating the virtual environment.

3. Indicate whether these projects should be connected from the workspace or copied there (the latter is the default). When importing content from an archive, the workspace will automatically receive a copy of the content.

### 3. Running the Simulation

Click on any .gaml file in the workspace and then click the play or run symbol (green button) located at the top left corner before the code of the simulation. After clicking this button, the simulation will be presented and will run until the end of the cycle. There are also options to pause, play, or run one cycle at a time.

