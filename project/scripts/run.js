const http = require('http');
const express = require('express');
const exec = require('child_process').exec;

const hostname = '127.0.0.1';
const port = 3000;

//const server = http.createServer((req, res) => {
 // res.statusCode = 200;
 // res.setHeader('Content-Type', 'text/plain');
 // res.end('Hello World111\n');
//});

//server.listen(port, hostname, () => {
//  console.log(`Server running at http://${hostname}:${port}/`);
//});
// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

// App
const app = express();


//const app = new Express();
app.get('/get', (req, res) => {
	console.log('im here');
	var yourscript = exec('sh create-stack.sh hello',
        (error, stdout, stderr) => {
            console.log(`${stdout}`);
            console.log(`${stderr}`);
            if (error !== null) {
                console.log(`exec error: ${error}`);
            }
        });
  //res.send('Hello world\n');
});

app.listen(port, hostname);
console.log(`Running on http://${hostname}:${port}`);