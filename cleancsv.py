import csv

fieldnames = ['title', 'year', 'runtime', 'genres']
with open("output.csv", encoding='utf-8') as fr, \
     open("movies.csv", "w", newline='', encoding='utf-8') as fw:
    
    reader = csv.DictReader(fr)
    writer = csv.DictWriter(fw, fieldnames=fieldnames)
    writer.writeheader()
    for row in reader:
        if row["titleType"] == 'movie':
            writer.writerow({
                'title': row['primaryTitle'].strip(), 
                'year': row['startYear'].strip(),
                'runtime': row['runtimeMinutes'].strip(),
                'genres': row['genres'].strip()
                }
            )