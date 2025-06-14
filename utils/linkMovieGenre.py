from connect import conn, cur
import csv

cur.execute('SELECT id, title FROM "movie";')
movies_map = {title: id for id, title in cur.fetchall()}

cur.execute('SELECT id, name FROM "genre";')
genres_map = {name: id for id, name in cur.fetchall()}

with open("movies.csv", encoding="utf-8") as movies:
    
    reader = csv.DictReader(movies)
    for row in reader:
        movie_title = row['title'].strip()
        movie_id = movies_map.get(movie_title)

        genres = row["genres"]
        genre_list = [g.strip() for g in genres.split(",")]
        
        for genre in genre_list:
            if genre == "\\N":
                continue
            genre_id = genres_map.get(genre)
            cur.execute('INSERT INTO "movie_genre" ("movie_id", "genre_id") VALUES(%s, %s) ON CONFLICT DO NOTHING', (int(movie_id), int(genre_id)) )

    conn.commit()
    cur.close()
    conn.close()