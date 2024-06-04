@echo off

:loop
if not "%1"=="" (
    if "%1"=="--express" (
        set server_type="express"
    )
    if "%1"=="--mongo" (
        set db_type="mongo"
    )
    if "%1"=="--auth" (
        set auth_type="user"
    )
)
if not "%2"=="" (
    if "%2"=="--express" (
        set server_type="express"
    )
    if "%2"=="--mongo" (
        set db_type="mongo"
    )
    if "%2"=="--auth" (
        set auth_type="user"
    )
)
if not "%3"=="" (
    if "%3"=="--express" (
        set server_type="express"
    )
    if "%3"=="--mongo" (
        set db_type="mongo"
    )
    if "%3"=="--auth" (
        set auth_type="user"
    )
)

REM Creating backend project folders...
echo "Creating backend project folders..."
mkdir .\backend
mkdir .\backend\routes
mkdir .\backend\models
mkdir .\backend\controllers
mkdir .\backend\middleware
mkdir .\backend\config

set mymodules=jsonwebtoken nodemon dotenv colors bcrypt 

if %server_type%=="express" (
    if %db_type%=="mongo" (
        set mymodules=jsonwebtoken nodemon dotenv colors bcrypt express express-async-handler mongoose
    ) else (
        set mymodules=jsonwebtoken nodemon dotenv colors bcrypt mongoose
    )
)

if %auth_type%=="user" (
    call :generateAuthMiddleware
    call :generateAuthController
    call :generateAuthRoutes

    if %db_type%=="mongo" (
        call :generateUserModel
    )
)
call :generateServerSourceFile
call :generateGenerateToken
call :generateEnv
call :generateErrorHandler

echo "Initializing Node Project... (npm init -y)"
REM Navigate into the directory
cd .\backend
REM Initializing node project...  (npm init -y)
echo "Installing dependencies..."
npm init -y && npm install express express-async-handler nodemon dotenv colors bcrypt jsonwebtoken mongoose

echo "Done!"

echo.&pause&goto:eof

:generateEnv
echo "Generating .env file -- .\.env"
REM Generate .env file
(
    echo PORT=5000
    echo SECRET_KEY=
    echo SECRET_EXPIRES="60m"
    echo.
    echo DB_NAME=
    echo DB_USER=
    echo DB_PASSWORD=
    echo DB_HOST=
    echo DB_URI=
) >> .\backend\.env
GOTO:EOF

:generateGenerateToken
echo "Generating generate jwt token file -- .\config\generateToken.js"
REM Generate generateToken.js file
(
echo const jwt = require('jsonwebtoken'^);
echo.
echo const generateToken = (id^) =^> ^{
echo     return jwt.sign(^{ id ^}, process.env.SECRET_KEY, ^{
echo         expiresIn: process.env.SECRET_EXPIRES,
echo     ^}^);
echo ^};
echo.
echo module.exports = generateToken;
) >> .\backend\config\generateToken.js
GOTO:EOF

:generateAuthMiddleware
echo "Generating auth middleware -- .\middleware\authMiddleware.js"
REM Generate Auth Middleware
(
    echo const jwt = require("jsonwebtoken"^);
    echo const User = require("../models/userModel"^);
    echo const asyncHandler = require("express-async-handler"^);
    echo.
    echo const protect = asyncHandler(async (req, res, next^) =^> ^{
    echo     let token;
    echo     if (req.headers.authorization ^&^& req.headers.authorization.startsWith("Bearer"^)^) ^{
    echo         try ^{
    echo             token = req.headers.authorization.split(" "^)[1^];
    echo.
    echo             //decodes token id
    echo             const decoded = jwt.verify(token, process.env.SECRET_KEY^);
    echo             req.user = await User.findById(decoded.id^).select("-password"^);
    echo             next(^);
    echo         ^} catch(err^) ^{
    echo             res.status(401^);
    echo             throw new Error("Not authorized, token failed"^);
    echo         ^}
    echo     ^}
    echo.
    echo     if(!token^) ^{
    echo         res.status(401^);
    echo         throw new Error("Not authorized, no token"^);
    echo     ^}
    echo ^}^);
    echo.
    echo module.exports = protect;
) >> .\backend\middleware\authMiddleware.js
GOTO:EOF

:generateAuthRoutes
echo "Generating auth routes -- .\routes\authRoutes.js"
REM Generate Auth Routes
(
    echo const express = require('express'^);
    echo const protect = require('^.^./middleware/authMiddleware.js'^);
    echo const ^{ login, register ^} = require('../controllers/authController.js'^);
    echo.
    echo const router = express.Router(^);
    echo.
    echo router.post('/login', protect, login^);
    echo router.post('/register', protect, register^);
    echo.
    echo module.exports = router;
) >> .\backend\routes\authRoutes.js
GOTO:EOF

:generateErrorHandler
echo "Generating error handling middleware -- .\middleware\errorHandler.js"
REM Generate Error Handling Middleware
    (
    echo const notFound = (req, res, next^) =^> ^{
    echo     const error = new Error('Not Found - '+req.originalUrl^);
    echo     res.status(404^);
    echo     next(error^);
    echo ^};
    echo.
    echo const errorHandler = (err, req, res, next^) =^> ^{
    echo     const statusCode = res.statusCode === 200 ? 500 : res.statusCode;
    echo     res.status(statusCode^);
    echo     res.json(^{
    echo         message: err.message,
    echo         stack: process.env.NODE_ENV === 'production' ? null : err.stack
    echo     ^}^);
    echo ^};
    echo.
    echo module.exports = ^{ notFound, errorHandler ^};
) >> .\backend\middleware\errorHandler.js
GOTO:EOF

:generateUserModel
echo "Generating user model schema -- .\models\userModel.js"
(
    echo const mongoose = require("mongoose"^);
    echo const { Schema, model } = mongoose;
    echo const bcrypt = require("bcrypt"^);
    echo.
    echo const userSchema = new Schema(^{
    echo     email: ^{
    echo         type: String,
    echo         required: true,
    echo         unique: true
    echo     ^},
    echo     username: ^{
    echo         type: String,
    echo         required: true,
    echo         unique: true
    echo     ^},
    echo     password: ^{
    echo         type: String,
    echo         required: true,
    echo     ^},
    echo     firstName: ^{
    echo         type: String,
    echo         required: true,
    echo     ^},
    echo     lastName: ^{
    echo         type: String,
    echo         required: true,
    echo     ^},
    echo     dateOfBirth: ^{
    echo         type: Date,
    echo         required: true,
    echo     ^},
    echo ^}, ^{ timestamps: true ^}^);
    echo.
    echo userSchema.methods.confirmPassword = async function(password^) ^{
    echo     return await bcrypt.compare(password, this.password^);
    echo ^};
    echo.
    echo userSchema.pre('save', async function(next^) ^{
    echo    if(!this.isModified(^)^) return next(^);
    echo.
    echo    const salt = await bcrypt.genSalt(10^);
    echo    this.password = await bcrypt.hash(this.password, salt^);
    echo    next(^);
    echo ^}^);
    echo.
    echo // virtual property of 'fullName'
    echo userSchema.virtual('fullName'^).get(function(^) ^{
    echo     return `^$^{this.firstName^} $^{this.lastName^}^`;
    echo ^}^);
    echo.
    echo // ensure virtuals are included in JSON
    echo userSchema.set('toJSON', ^{ virtuals: true ^}^);
    echo.
    echo const User = model("User", userSchema^);
    echo.
    echo module.exports = User
) >> .\backend\models\userModel.js
GOTO:EOF

:generateServerSourceFile
echo "Generating server file -- .\server.js"
REM Generating server.js
(
    echo const express = require('express'^); 
    echo const colors = require('colors'^);  
    echo require('dotenv'^).config(^); 
    echo.
    echo const authRoutes = require('./routes/authRoutes.js'^);
    echo const ^{ notFound, errorHandler^} = require('./middleware/errorHandler.js'^);
    echo const app = express(^);
    echo const PORT = process.env.PORT ^|^| 3000
    echo.
    echo app.use(express.json(^)^);
    echo.
    echo // auth routes
    echo app.use('/api/v1/auth', authRoutes^);
    echo.
    echo // error handler middleware
    echo app.use(notFound^);
    echo app.use(errorHandler^);
    echo.
    echo app.listen(PORT, (^) =^> ^{ 
    echo     console.log(`^Server running on port $^{PORT^}^`^);
    echo ^}^);
) >> .\backend\server.js
GOTO:EOF

:generateAuthController
echo "Generating auth controller -- .\controllers\authController.js"
REM Generate Auth Controller -- .\controllers\authController.js
(
    echo const asyncHandler = require('express-async-handler'^);
    echo const User = require('../models/userModel.js'^);
    echo const generateToken = require('../config/generateToken'^);
    echo.
    echo const USER_CREATE_SUCCESS = "User created successfully";
    echo const USER_CREATE_FAIL = "Failed to create new user";
    echo const USER_LOGIN_SUCCESS = "User logged in successfully";
    echo const USER_LOGIN_FAIL = "Failed to login user";
    echo.
    echo const login = asyncHandler(async (req, res, next^) =^> ^{
    echo     const ^{ identifier, password ^} = req.body;
    echo     if(^!identifier ^|^| ^!password^) ^{
    echo         res.status(400^);
    echo         throw new Error(`^$^{USER_LOGIN_FAIL^}. Please provide an email/username and password^`^);
    echo     ^}
    echo     try ^{
    echo         const isEmail = ^/^.+^\@^.+^\^.^.^+/.test(identifier^);
    echo         const query = isEmail ^? ^{ email: identifier ^} : ^{ username: identifier ^};
    echo.
    echo         //find the user
    echo         const user = await User.findOne(query^);
    echo         if(user ^&^& (await user.confirmPassword(password^)^)^) ^{
    echo             // prepare the data
    echo             const userData = ^{
    echo                 _id: user._id,
    echo                 username: user.username,
    echo                 email: user.email,
    echo                 firstName: user.firstName,
    echo                 lastName: user.lastName,
    echo                 fullName: user.fullName,
    echo                 dateOfBirth: user.dateOfBirth,
    echo                 token: generateToken(user._id^)
    echo             ^}
    echo             // send the response
    echo             res.json(^{
    echo                 message: USER_LOGIN_SUCCESS,
    echo                 data: userData
    echo             ^}^);
    echo         ^} else ^{
    echo             res.status(401^);
    echo             throw new Error(`^$^{USER_LOGIN_FAIL^}. Invalid email/username or password^`^);
    echo         ^}
    echo     ^} catch(err^) ^{
    echo         next(err^);
    echo     ^}
    echo ^}^);
    echo.
    echo const register = asyncHandler(async (req, res, next^) =^> ^{
    echo     const ^{ email, username, firstName, lastName, dateOfBirth, password ^} = req.body;
    echo     // if not all data is valid, return error message
    echo     if(^!email ^|^| ^!username ^|^| ^!firstName ^|^| ^!lastName ^|^| ^!dateOfBirth ^|^| ^!password^) ^{
    echo         res.status(400^);
    echo         throw new Error(`^$^{USER_CREATE_FAIL^}. Some required fields are missing!^`^);
    echo     ^}
    echo     try ^{
    echo         const userExistsWithEmail = await User.findOne(^{ email: email, username: username ^}^);
    echo         if(^userExistsWithEmail ^&^& userExistsWithEmail.length ^> 0^) ^{
    echo             res.status(400^);
    echo             throw new Error(`^User account with email $^{email^} already exists^`^);
    echo         ^}
    echo         const userExistsWithUsername = await User.findOne(^{ username: username ^}^);
    echo         if(^userExistsWithUsername ^&^& userExistsWithUsername.length ^> 0^) ^{
    echo             res.status(400^);
    echo             throw new Error(`^User account with username $^{username}^ already exists^`^);
    echo         ^}
    echo         // handle dateOfBirth conversion to ISO string.
    echo         const DOB = new Date(dateOfBirth^);
    echo         const iso = DOB.toISOString(^);
    echo         // create new user
    echo         const user = await User.create(^{
    echo             email: email,
    echo             username: username,
    echo             password: password,
    echo             firstName: firstName,
    echo             lastName: lastName,
    echo             dateOfBirth: iso, // using date converted to ISO string
    echo         ^}^);
    echo         // prepare user data for send
    echo         const userData = ^{
    echo             _id: user._id,
    echo             username: user.username,
    echo             email: user.email,
    echo             firstName: user.firstName,
    echo             lastName: user.lastName,
    echo             fullName: user.fullName,
    echo             dateOfBirth: user.dateOfBirth,
    echo             createdAt: user.createdAt,
    echo             updatedAt: user.updatedAt,
    echo             token: generateToken(user._id^)
    echo         ^}
    echo         // send status code and data
    echo         res.status(201^).json(^{
    echo             message: USER_CREATE_SUCCESS,
    echo             data: userData,
    echo         ^}^);
    echo     ^} catch(err^) ^{ 
    echo         next(err^) 
    echo     ^}
    echo ^}^);
    echo.
    echo module.exports = ^{ login, register ^}
) >> .\backend\controllers\authController.js
GOTO:EOF

EXIT /B 1