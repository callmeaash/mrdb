import csv

with open('title.basics.tsv', 'r', encoding='utf-8') as tsv_file, \
     open('output.csv', 'w', newline='', encoding='utf-8') as csv_file:
    
    tsv_reader = csv.reader(tsv_file, delimiter='\t')
    csv_writer = csv.writer(csv_file)
    
    for row in tsv_reader:
        csv_writer.writerow(row)
