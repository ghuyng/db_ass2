# Prerequisites:
1. Install nodejs and npm
2. Check for nodejs version and npm version:    
`node -v`  
`npm -v`  
3. After install nodejs, install dependencies:
`npm install`

# How to start server:
1. Start postgres server
2. Modify database information in file 'queries.js' :  
Change your username, password, database, port,... inside: `const cn = [ ... ]`
3. Start node server:  
`node index.js`
4. The website will be at:  
localhost:3000/  

# ERD for reference:

![](/images/EERD.png "")
