import csv

genres = set()
with open("movies.csv", encoding='utf-8') as fp:
    
    reader = csv.DictReader(fp)
    for row in reader:
        genre_list = row['genres'].split(',')
        for genre in genre_list:
            genres.add(genre.strip())


with open("genres.csv", "w", newline="", encoding="utf-8") as fw:
    writer = csv.writer(fw)
    for genre in genres:
        writer.writerow([genre])