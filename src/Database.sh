#!/bin/bash
dropdb group15
createdb group15

psql -f sql_functions/DDL_Queries.sql group15
psql -f sql_functions/DML_Queries.sql group15
