-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

CREATE TABLE "user"(
    "id" SERIAL PRIMARY KEY,
    "username" TEXT UNIQUE NOT NULL,
    "email" TEXT UNIQUE NOT NULL,
    "password" TEXT NOT NULL
);

CREATE TABLE "user_follows"(
    "follower_id" INTEGER REFERENCES "user"("id") ON DELETE CASCADE,
    "followed_id" INTEGER REFERENCES "user"("id") ON DELETE CASCADE,
    "followed_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("follower_id", "followed_id")
);

CREATE TABLE "movie"(
    "id" SERIAL PRIMARY KEY,
    "title" TEXT NOT NULL,
    "release_year" INTEGER,
    "runtime" INTEGER
);

CREATE TABLE "ratings"(
    "user_id" INTEGER REFERENCES "user"("id") ON DELETE CASCADE,
    "movie_id" INTEGER REFERENCES "movie"("id") ON DELETE CASCADE,
    "rating" NUMERIC(2,1) NOT NULL CHECK("rating" <= 5),
    "rated_date" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("user_id", "movie_id")
);

CREATE TABLE "genre"(
    "id" SERIAL PRIMARY KEY,
    "name" TEXT UNIQUE NOT NULL
);

CREATE TABLE "movie_genre"(
    "movie_id" INTEGER REFERENCES "movie"("id") ON DELETE CASCADE,
    "genre_id" INTEGER REFERENCES "genre"("id") ON DELETE CASCADE,
    PRIMARY KEY("movie_id", "genre_id")
);

CREATE TABLE "watch_history"(
    "user_id" INTEGER REFERENCES "user"("id") ON DELETE CASCADE, 
    "movie_id" INTEGER REFERENCES "movie"("id") ON DELETE CASCADE,
    "watched_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("user_id", "movie_id")
);

CREATE TABLE "watchlist"(
    "user_id" INTEGER REFERENCES "user"("id") ON DELETE CASCADE, 
    "movie_id" INTEGER REFERENCES "movie"("id") ON DELETE CASCADE,
    "added_at" TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ("user_id", "movie_id")
);

CREATE INDEX "movie_title" ON "movie" ("title");


CREATE FUNCTION add_to_watch_history()
RETURNS TRIGGER
AS $$
BEGIN
    INSERT INTO "watch_history" ("user_id", "movie_id")
    SELECT NEW.user_id, NEW.movie_id
    WHERE NOT EXISTS(
        SELECT 1 FROM "watch_history"
        WHERE user_id = NEW.user_id AND movie_id = NEW.movie_id
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER  "after_rating_insert"
AFTER INSERT ON "ratings"
FOR EACH ROW
EXECUTE FUNCTION add_to_watch_history();


CREATE VIEW recent_watches AS
SELECT username, title FROM "user"
JOIN "watch_history" ON "user".id = watch_history.user_id
JOIN "movie" ON watch_history.movie_id = movie.id
ORDER BY watch_history.watched_at DESC;


CREATE VIEW movie_genre_view AS
SELECT movie_id, name  FROM "genre" JOIN "movie_genre" ON genre.id = movie_genre.genre_id
ORDER BY name ASC;


CREATE FUNCTION highest_rated_genre(IN userID INTEGER)
RETURNS TEXT
AS $$
DECLARE
    my_genre TEXT;
BEGIN
    SELECT genre.name INTO my_genre FROM "ratings" JOIN "movie_genre" ON ratings.movie_id = movie_genre.movie_id
    JOIN "genre" ON movie_genre.genre_id = genre.id
    WHERE ratings.user_id = userID
    GROUP BY genre.name
    ORDER BY AVG(ratings.rating) DESC
    LIMIT 1;

    RETURN my_genre;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION movie_recommend(IN userID INTEGER)
RETURNS TABLE(title TEXT, release_year INTEGER)
AS $$
DECLARE
    favorite_genre TEXT;
BEGIN
    SELECT highest_rated_genre(userID) INTO favorite_genre;

    RETURN QUERY
    SELECT movie.title, movie.release_year FROM movie
    JOIN movie_genre ON movie.id = movie_genre.movie_id
    JOIN genre ON movie_genre.genre_id = genre.id
    WHERE genre.name = favorite_genre AND movie.release_year <= EXTRACT(YEAR FROM CURRENT_DATE) AND
    AND NOT EXISTS (
        SELECT 1 FROM watchlist wl
        WHERE wl.user_id = userID AND wl.movie_id = movie.id
      )
    AND NOT EXISTS (
        SELECT 1 FROM watch_history wh
        WHERE wh.user_id = userID AND wh.movie_id = movie.id
      )
    ORDER BY release_year DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION give_rating(IN user_name TEXT, IN movie_name TEXT, IN rating NUMERIC(2,1))
RETURNS VOID AS
$$
BEGIN
    INSERT INTO "ratings" (user_id, movie_id, rating)
    VALUES(
        (SELECT id FROM "user" WHERE "user"."username"=user_name),
        (SELECT id FROM "movie" WHERE "movie"."title"=movie_name),
        rating);
END;
$$ LANGUAGE plpgsql;


CREATE VIEW user_rated_movies AS
SELECT username, title, rating FROM "user"
JOIN "ratings" ON "user".id = ratings.user_id
JOIN "movie" ON ratings.movie_id = movie.id
ORDER BY ratings.rated_date DESC, title ASC;


CREATE OR REPLACE FUNCTION get_ids(IN follower TEXT, IN followed TEXT)
RETURNS TABLE(follower_id INTEGER, followed_id INTEGER) AS $$
BEGIN
    RETURN QUERY
    SELECT uf.follower_id, uf.followed_id FROM "user_follows" uf
    JOIN "user" u1 ON uf.follower_id = u1.id
    JOIN "user" u2 ON uf.followed_id = u2.id
    WHERE u1.username = follower AND u2.username = followed;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION recommend_by_followed_rating(IN follower TEXT, IN followed TEXT)
RETURNS TABLE(user_id INTEGER, title TEXT, rating NUMERIC(2,1)) AS $$
DECLARE
    followedID INTEGER;
    followerID INTEGER;
BEGIN
    SELECT follower_id, followed_id INTO followerID, followedID
    FROM get_ids(follower, followed);

    RETURN QUERY
    SELECT r.user_id, m.title, r.rating FROM "ratings" r
    JOIN "movie" m ON r.movie_id = m.id
    WHERE r.user_id = followedID
    AND NOT EXISTS(
        SELECT 1 FROM "watch_history" wh
        WHERE wh.user_id = followerID AND wh.movie_id = r.movie_id
    )
    
    ORDER BY r.rating DESC
    LIMIT 10;
END;
$$ LANGUAGE plpgsql;

