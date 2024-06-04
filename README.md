# Boilerplate Generation script for MEN (mongdb, express, node) backend
The batch script should be called from the command line inside the directory you want to create your boilerplate.

### Usage
```console
foo@bar:~$ .\create_node.bat --express --mongo --auth
```
As of right now (June 4, 2024), the optional arguments don't really have much purpose because they are the only configurations setup right now.
However, remember to include the arguments because they are crucial right now.

### Future Plans
- Ask user for file name instead of the default backend and also a file path to save it at (default: working directory)
- Add multiple different database implementations (current: mongodb)
- Add different server configuration options, like using http, nestjs, KOA, etc.
