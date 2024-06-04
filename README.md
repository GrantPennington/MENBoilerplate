# Boilerplate Generation script for MEN (mongdb, express, node) backend
create_node.bat is a batch script that generates an MVC style folder structure for a node express backend project.
This is intended to be used for a MERN full-stack application, but it can be edited to use any database configuration.

### Usage
```console
foo@bar:~$ .\create_node.bat --express --mongo --auth
```
As of right now (June 4, 2024), the optional arguments don't really have much purpose because they are the only configurations setup right now.
However, remember to include the arguments because they are crucial right now.


### Folder Structure
The generated backend project will have this folder structure. 

* ── backend
  +  .env
  +  server.js 
  +  package.json  
  +  package-lock.json 
  + ├── config
    + generateToken.js 
       
  + ├── controllers 
    + authController.js 
  
  + ├── middleware 
    + authMiddleware.js 
    + errorHandler.js        
  + ├── models  
    + userModel.js 
         
  + └── routes 
    + authRoutes.js
  

##### The entry point to the application is server.js
The batch script should be called from the command line inside the directory you want to create your boilerplate.

### Future Plans
- Ask user for file name instead of the default backend and also a file path to save it at (default: working directory)
- Add multiple different database implementations (current: mongodb)
- Add different server configuration options, like using http, nestjs, KOA, etc.
