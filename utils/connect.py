import psycopg2

conn = psycopg2.connect(
    host="localhost",
    database="mrdb",
    user="postgres",
    password="ash"
)

cur = conn.cursor()
