from connect import cur, conn
import csv

with open("genres.csv") as fp:
    reader = csv.reader(fp)
    for row in reader:
        cur.execute('INSERT INTO "genre"("name") VALUES (%s)', (row[0],))
        print(row[0])
conn.commit()
cur.close()
conn.close()