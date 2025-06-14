from connect import cur, conn
import csv


with open("movies.csv", encoding="utf-8") as fp:
    reader = csv.DictReader(fp)
    for row in reader:
        year = None if row['year'] == "\\N" else int(row['year'])
        runtime = None if row['runtime'] == "\\N" else int(row['runtime'])
        cur.execute('INSERT INTO "movie" ("title", "release_year", "runtime") VALUES(%s, %s, %s)', (row['title'], year, runtime))

conn.commit()
cur.close()
conn.close()
