<!-- ---
layout: post
title: A Semantic Map Implementation for a Long-Term Autonomous Robot - My BSc Thesis
date: 2019-01-28
--- -->

In 2016 I completed my BSc Thesis/Project at TUGraz that focused on the implementation of a semantic map extension for a long term autonomy project. 

The thesis describes fundamental concepts like costmaps and semantic map information, as well as the implementation of a semantic map extension intended to add information about the existence of doors and their likelyhood to be open or closed, to both the robots path planning and reasoning as it would patrol a building for extended periods without needing human intervention. 

The project is to my knowledge long canceled, but in the spirit of open access, you can find my thesis [here](/assets/Semantic_Map_Bachelorthesis_N_Riedmann_2016.pdf) and the accompanying source code on my gitlab at [https://gitlab.com/UnseenWizzard/lta_semantic_map/](https://gitlab.com/UnseenWizzard/lta_semantic_map/)

Here's the Abstract of the thesis: 

> This thesis presents an implementation of a Semantic Map that is to be used as part of a long-term autonomous robot system in the Long-Term Autonomy Project by the TU Graz, Institute for Software Technology. To provide an understanding of the theoretical and practical foundations of the implementation, the thesis opens with a discussion of important concepts like Semantic Maps and Costmaps, as well as descriptions of related developments and utilized technologies. The implemented Semantic Map is part of a ROS2 based system and offers interfaces to OPRS3 - the reasoning system used in the project. Before the implementation, existing Semantic Map implementations were researched and considered for the project. The considered frameworks are presented and evaluated, but were not used due to various reasons. The individual components of the implemented Semantic Map module are described in the Implementation section, which details the purpose and function of each component, as well as providing design-document like descriptions of classes, member variables and methods and ROS and OPRS speciﬁc functionality.