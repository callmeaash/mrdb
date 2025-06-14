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
    "rating" NUMERIC(2,1) NOT NULL,
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


CREATE INDEX "movie_title" ON "movie" ("title");


CREATE FUNCTION add_to_watch_history()
RETURNS TRIGGER AS $$
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