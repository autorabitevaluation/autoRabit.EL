# AutoRABIT  

[AutoRABIT](https://www.autorabit.com/) feature migration connector is an unique, one-of-a-kind structure. This will enable our users to promote their data scripts using version control. This would allow salesforce admins/release managers to migrate data and metadata 10x faster. 
We will provide you with series of data in json format and associated filters with their relationships.

## Getting Started

To understand this solution better, you can refer to the documentation [AutoRABIT/docs](https://knowledgebase.autorabit.com/docs/ncino-an-overview).

To get set up and running quickly:

 - Work through the [Tutorial](http://course-catalog.teachery.co/lessons/devops-academy)
 - To set up the feature templates [Tutorial](https://academy.autorabit.com/?sfwd-courses=autorabit-ncino-integration-course)

This repository consists of an custom built structure, these folders will created for each feature template with an intention of keeping all the associated data in the feature name folder.

    ├── data                     
    ├── filters                    
    └── objectrelationships

Once you are familiar with the tutorial, you’re ready to move on.

Getting Help
------------

Check the [AutoRABIT FAQ](http://course-catalog.teachery.co/lessons/devops-academy) and read through the [Top 10 questions on nCino Feature Migration](http://course-catalog.teachery.co/lessons/devops-academy).


## Prerequisites

 - Salesforce org: nCino installed org
 - AutoRABIT enterprise licence account

## Description of Files and Directories

### A typical top-level directory layout

    .
    ├── config                     # Configuration files
    ├── dataset                    # Feature template files
    └── README.md

### Configuration files
.

    ├── ...
    ├── config                    # Test files (alternatively `spec` or `tests`)
    │   ├── manifest.yaml         # This contains information about features that are committed
    │   ├── project-def.json      # End-to-end, integration tests
    └── ...

### Data files

    ├── ...
    ├── dataset                          # Feature Template files
    │   ├── <feature-name>               # Folder name will use the name as published by nCino
    │          ├── .store      			 # Contains metadata information and original files    
	│          ├── data      			 # Contains data files
	│          ├── filters      		 # Contains filters related to feature    
	│          ├── objectsets.json       # Contains relationship between objects selected in that feature 
    │          ├── Version.json     	 # Contains version related information    
	│          ├── autorabit.json        # Contains configurations related to AR
	│          ├── buckets.json      	 # Contains relations between objects	
	│          ├── userids.json      	 # Contains userids of source salesforce org    
    └── ...

