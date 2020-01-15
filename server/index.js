const pgp = require('pg-promise')(/* initialization options */);
const http = require('http');
const url = require('url');
var express = require('express');


const cn = {
    host: 'localhost', // server name or IP address;
    port: 5433,
    database: 'postgres',
    user: 'postgres',
    password: '@gunr2312'
};

const pg = require('pg');
const R = require('ramda');

//const cs = 'postgres://postgres:s$cret@localhost:5432/ydb';

const client = new pg.Client(cn);
client.connect();

/*client.query('SELECT * FROM db_app_build.hp_places').then(res => {
    console.log(res.rows);
});
*/

var app = express();




app.get('/Rooms',function(request, response)  {
  var d, query;
  query = url.parse(request.url, true).query;
   client.query('SELECT * FROM db_app_build.hp_places p left JOIN db_app_build.hp_places_instructions i ON p.id = i.placeid WHERE catagory = \'Room\'').then(res => {
	  console.log( res.rows);
	  d = JSON.stringify(res.rows);
	  console.log(client.query('SELECT * FROM db_app_build.hp_places'));
  response.writeHead(200, {"Content-Type": "text/html"});
  response.write(d);
  response.end();
    //console.log(res.rows);
	});
});

app.get('/Places',function(request, response)  {
  var d, query;
  query = url.parse(request.url, true).query;
   client.query('SELECT * FROM db_app_build.hp_places p left JOIN db_app_build.hp_places_instructions i ON p.id = i.placeid WHERE catagory = \'Place\'').then(res => {
	  console.log( res.rows);
	  d = JSON.stringify(res.rows);
	  console.log(client.query('SELECT * FROM db_app_build.hp_places'));
  response.writeHead(200, {"Content-Type": "text/html"});
  response.write(d);
  response.end();
    //console.log(res.rows);
	});
});


app.listen(3000);