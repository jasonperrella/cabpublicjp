#! /usr/bin/python3

"""
This is an example Flask | Python | Psycopg2 | PostgreSQL
application that connects to the 7dbs database from Chapter 2 of
_Seven Databases in Seven Weeks Second Edition_
by Luc Perkins with Eric Redmond and Jim R. Wilson.
The CSC 315 Virtual Machine is assumed.
John DeGood
degoodj@tcnj.edu
The College of New Jersey
Spring 2020
----
One-Time Installation
You must perform this one-time installation in the CSC 315 VM:
# install python pip and psycopg2 packages
sudo pacman -Syu
sudo pacman -S python-pip python-psycopg2
# install flask
pip install flask
----
Usage
To run the Flask application, simply execute:
export FLASK_APP=app.py 
flask run
# then browse to http://127.0.0.1:5000/
----
References
Flask documentation:  
https://flask.palletsprojects.com/  
Psycopg documentation:
https://www.psycopg.org/
This example code is derived from:
https://www.postgresqltutorial.com/postgresql-python/
https://scoutapm.com/blog/python-flask-tutorial-getting-started-with-flask
https://www.geeksforgeeks.org/python-using-for-loop-in-flask/
"""

import psycopg2
from config import config
from flask import Flask, render_template, request

# Connect to the PostgreSQL database server
def connect(query):
    conn = None
    try:
        # read connection parameters
        params = config()
 
        # connect to the PostgreSQL server
        print('Connecting to the %s database...' % (params['database']))
        conn = psycopg2.connect(**params)
        print('Connected.')
      
        # create a cursor
        cur = conn.cursor()
        
        # execute a query using fetchall()
        cur.execute(query)
        rows = cur.fetchall()

        # close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')
    # return the query result from fetchall()
    return rows
 
# app.py
app = Flask(__name__)


# serve form web page
@app.route("/")
def form():
    items = connect('SELECT * FROM COUNTY;')
    return render_template('my-form.html', items=items)

# handle venue POST and serve result web page      METHODS
@app.route('/test', methods=['GET', 'POST'])
def test():
    rows = connect('select name, total_miles_traveled, total_vehicles, evs, total_emissions, evgasratio from county inner join r2 on county_name = name WHERE name = \'' + request.form['countyInfo'].upper() +'\';')
    heads = ['Name', 'Total Miles Traveled', "Total Vehicles", "Number of EV's", "Total CO2 Emissions(kt)", "Gas Station per 1 EV Charger"]

    rows1 = connect('SELECT MUNICIPALITY, TOTAL_ELECTRICITY, TOTAL_NATURAL_GAS FROM TOWN_ENERGY WHERE COUNTY_NAME = \'' + request.form['countyInfo'].upper() +'\';')
    heads1 = ['Municipality', 'Total Electricity', "Total Natural Gas"]

    rows2 = connect('SELECT ADDRESS, ZIP_CODE, TOWN FROM EV_CHARGER INNER JOIN ZIPCODETOWN TOWN ON  ZIP_CODE = zipcode WHERE COUNTY_NAME = \'' + request.form['countyInfo'].upper() +'\';')
    heads2 = ['Address', 'Zip Code', 'Town']

    rows3 = connect('SELECT ADDRESS, ZIP_CODE, TOWN FROM EV_CHARGER INNER JOIN ZIPCODETOWN TOWN ON  ZIP_CODE = zipcode WHERE COUNTY_NAME = \'' + request.form['countyInfo'].upper() +'\';')
    heads3 = ['Address', 'Zip Code', 'Town']

    return render_template('my-result.html', rows3=rows3, heads3=heads3, rows2=rows2, heads2=heads2, rows1=rows1, heads1=heads1, rows=rows, heads=heads)


# handle query POST and serve result web page
@app.route('/asc', methods=['POST'])
def asc():
    rows = connect('SELECT NAME, TOTAL_EMISSIONS, (ROUND((EVs * 1.0 / TOTAL_VEHICLES * 1.0) * 10000.0, 2)) FROM COUNTY ORDER BY TOTAL_EMISSIONS ASC;')
    heads = ['Name', 'Total Emissions(kT)', 'Percent EVs(%)']
    return render_template('third-page.html', rows=rows, heads=heads)

# handle query POST and serve result web page
@app.route('/desc', methods=['POST'])
def desc():
    rows = connect('SELECT NAME, TOTAL_EMISSIONS, (ROUND((EVs * 1.0 / TOTAL_VEHICLES * 1.0) * 10000.0, 2)) FROM COUNTY ORDER BY TOTAL_EMISSIONS DESC;')
    heads = ['Name', 'Total Emissions(kT)', 'Percent EVs(%)']
    return render_template('third-page.html', rows=rows, heads=heads)

    # handle query POST and serve result web page
@app.route('/aboutus', methods=['POST'])
def about():
    return render_template('about.html')

if __name__ == '__main__':
    app.run(debug = True)


# Serene_Sparks_#3234
#8567615421

# select
# 	address, zip_code, county_name, town
# from
# 	(
# 	select
# 		row_number() over (partition by town
# 	order by
# 		address) as r,
# 		gs.*,
# 		ZIPCODETOWN.town
# 	from
# 		gas_station gs
# 	inner join ZIPCODETOWN on
# 		ZIPCODE = gs.zip_code
# 	where
# 		COUNTY_NAME = 'CAMDEN') as x
# where
# 	r <= 5;
# SELECT address, zip_code, county_name, town FROM (SELECT row_number() OVER (PARTITION BY town ORDER BY address) AS r, gs.*, ZIPCODETOWN.town FROM gas_station gs INNER JOIN ZIPCODETOWN on zipcode = gs.zip_score where COUNTY_NAME = 'ATLANTIC') as x where r <= 5; 