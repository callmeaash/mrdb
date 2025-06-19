-- Query Examples

-- Insert data into the user
INSERT INTO "user" ("username", "email", "password")
    VALUES ('parash', 'parashkhadka@gmail.com', 'parash');


-- Insert into ratings
SELECT give_rating(3, 4, 4.0);


-- Insert into user_follows
INSERT INTO "user_follows"("follower_id", "followed_id")
    VALUES (
        (SELECT "id" FROM "user" WHERE "username"='parash'),
        (SELECT "id" FROM "user" WHERE "username"='ash')
    );


-- Update the record of user table
UPDATE "user" SET "username" = 'anuu'
    WHERE "username"='anup';


-- Insert data in watch_history
INSERT INTO "watch_history" ("user_id", "movie_id")
    VALUES(
        (SELECT "id" FROM "user" WHERE "username"='parash'),
        (SELECT "id" FROM "movie" WHERE "title" = 'Titanic')
    );


-- Select recent movies watched by a user
SELECT * FROM "recent_watches" WHERE username='ash';


-- Select all the movies reated by a user
SELECT * FROM "user_rated_movies" WHERE username='ash';


-- Recommend movies to a user based on a genre which user has highly rated
SELECT * FROM movie_recommend(
    SELECT "id" FROM "users" WHERE "username"='ash';
);


-- Recommend movies to a user based on the a followed user
SELECT * FROM recommend_by_followed_rating('anup', 'ash')






