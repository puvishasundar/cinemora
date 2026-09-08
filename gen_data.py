import csv

movies = [
    # Title, Genre, Year, Rating, Views(K), Reviews, Runtime(min), Director, Language
    ("Inception", "Sci-Fi", 2010, 8.8, 420, 15200, 148, "C. Nolan", "English"),
    ("Interstellar", "Sci-Fi", 2014, 8.7, 510, 18300, 169, "C. Nolan", "English"),
    ("Dune", "Sci-Fi", 2021, 8.0, 380, 12100, 155, "D. Villeneuve", "English"),
    ("Dune: Part Two", "Sci-Fi", 2024, 8.5, 340, 9900, 166, "D. Villeneuve", "English"),
    ("The Dark Knight", "Action", 2008, 9.0, 610, 21000, 152, "C. Nolan", "English"),
    ("Oppenheimer", "Drama", 2023, 8.4, 400, 13500, 180, "C. Nolan", "English"),
    ("Parasite", "Thriller", 2019, 8.6, 290, 11200, 132, "Bong Joon-ho", "Korean"),
    ("The Grand Budapest Hotel", "Comedy", 2014, 8.1, 180, 6400, 99, "W. Anderson", "English"),
    ("Whiplash", "Drama", 2014, 8.5, 220, 8100, 106, "D. Chazelle", "English"),
    ("La La Land", "Drama", 2016, 8.0, 260, 9200, 128, "D. Chazelle", "English"),
    ("Mad Max: Fury Road", "Action", 2015, 8.1, 350, 10400, 120, "G. Miller", "English"),
    ("Joker", "Drama", 2019, 8.4, 470, 16800, 122, "T. Phillips", "English"),
    ("Get Out", "Thriller", 2017, 7.7, 210, 7300, 104, "J. Peele", "English"),
    ("Everything Everywhere All at Once", "Adventure", 2022, 7.8, 190, 6900, 139, "Daniels", "English"),
    ("Spider-Man: Into the Spider-Verse", "Animation", 2018, 8.4, 330, 10900, 117, "P. Ramsey", "English"),
    ("Coco", "Animation", 2017, 8.4, 300, 9700, 105, "L. Unkrich", "English"),
    ("Spirited Away", "Animation", 2001, 8.6, 280, 9100, 125, "H. Miyazaki", "Japanese"),
    ("Your Name", "Animation", 2016, 8.4, 250, 8700, 106, "M. Shinkai", "Japanese"),
    ("The Shawshank Redemption", "Drama", 1994, 9.3, 640, 24500, 142, "F. Darabont", "English"),
    ("Fight Club", "Drama", 1999, 8.8, 480, 17600, 139, "D. Fincher", "English"),
    ("Pulp Fiction", "Thriller", 1994, 8.9, 500, 19100, 154, "Q. Tarantino", "English"),
    ("The Matrix", "Sci-Fi", 1999, 8.7, 460, 16700, 136, "Wachowskis", "English"),
    ("Gladiator", "Action", 2000, 8.5, 330, 11700, 155, "R. Scott", "English"),
    ("Avatar", "Sci-Fi", 2009, 7.9, 590, 20200, 162, "J. Cameron", "English"),
    ("Avatar: The Way of Water", "Sci-Fi", 2022, 7.6, 310, 8600, 192, "J. Cameron", "English"),
    ("Titanic", "Drama", 1997, 7.9, 550, 19800, 195, "J. Cameron", "English"),
    ("The Lord of the Rings: The Fellowship of the Ring", "Fantasy", 2001, 8.9, 470, 16400, 178, "P. Jackson", "English"),
    ("The Lord of the Rings: The Two Towers", "Fantasy", 2002, 8.8, 440, 15100, 179, "P. Jackson", "English"),
    ("The Lord of the Rings: The Return of the King", "Fantasy", 2003, 9.0, 480, 17000, 201, "P. Jackson", "English"),
    ("Harry Potter and the Sorcerer's Stone", "Fantasy", 2001, 7.6, 400, 13200, 152, "C. Columbus", "English"),
    ("The Hunger Games", "Adventure", 2012, 7.2, 300, 9600, 142, "G. Ross", "English"),
    ("Guardians of the Galaxy", "Adventure", 2014, 8.0, 380, 12800, 121, "J. Gunn", "English"),
    ("Black Panther", "Action", 2018, 7.3, 400, 13900, 134, "R. Coogler", "English"),
    ("Avengers: Endgame", "Action", 2019, 8.4, 620, 21500, 181, "Russo Bros", "English"),
    ("Avengers: Infinity War", "Action", 2018, 8.4, 590, 20200, 149, "Russo Bros", "English"),
    ("Doctor Strange", "Fantasy", 2016, 7.5, 290, 9400, 115, "S. Derrickson", "English"),
    ("The Social Network", "Drama", 2010, 7.7, 240, 8300, 120, "D. Fincher", "English"),
    ("Her", "Drama", 2013, 8.0, 160, 5700, 126, "S. Jonze", "English"),
    ("Blade Runner 2049", "Sci-Fi", 2017, 8.0, 250, 8200, 164, "D. Villeneuve", "English"),
    ("Arrival", "Sci-Fi", 2016, 7.9, 230, 7600, 116, "D. Villeneuve", "English"),
    ("No Country for Old Men", "Thriller", 2007, 8.2, 260, 8900, 122, "Coen Bros", "English"),
    ("Django Unchained", "Action", 2012, 8.4, 360, 12300, 165, "Q. Tarantino", "English"),
    ("Once Upon a Time in Hollywood", "Drama", 2019, 7.6, 220, 7100, 161, "Q. Tarantino", "English"),
    ("Knives Out", "Thriller", 2019, 7.9, 270, 9000, 130, "R. Johnson", "English"),
    ("The Grand Adventure of Toy Story", "Animation", 1995, 8.3, 320, 10700, 81, "J. Lasseter", "English"),
    ("Finding Nemo", "Animation", 2003, 8.1, 300, 10100, 100, "A. Stanton", "English"),
    ("Up", "Animation", 2009, 8.3, 310, 10400, 96, "P. Docter", "English"),
    ("Inside Out", "Animation", 2015, 8.1, 290, 9600, 95, "P. Docter", "English"),
    ("WALL-E", "Animation", 2008, 8.4, 300, 9900, 98, "A. Stanton", "English"),
    ("The Prestige", "Thriller", 2006, 8.5, 300, 10600, 130, "C. Nolan", "English"),
]

with open("/home/claude/cinemora/movies.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["Movie_ID","Title","Genre","Release_Year","Rating","Views","Reviews","Runtime","Director","Language","Description","Image"])
    for i, (title, genre, year, rating, views, reviews, runtime, director, lang) in enumerate(movies, start=1):
        slug = "".join(c.lower() if c.isalnum() else "_" for c in title).strip("_")
        while "__" in slug:
            slug = slug.replace("__", "_")
        image = f"{slug}.jpg"
        desc = f"A {genre.lower()} film from {year}, directed by {director}, exploring bold ideas with a {rating} rating on Cinemora."
        writer.writerow([i, title, genre, year, rating, views, reviews, runtime, director, lang, desc, image])

print(f"Wrote {len(movies)} movies")
