DROP TABLE IF EXISTS Quote;
DROP TABLE IF EXISTS Anime;
DROP TABLE IF EXISTS OldAnime;
DROP TABLE IF EXISTS NewAnime;

CREATE TABLE Anime (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL,
    tv_episodes INTEGER DEFAULT 0,
    movies INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL default '想看',
    genre TEXT NOT NULL default '',
    year TEXT,
    episode_length FLOAT NOT NULL DEFAULT 24,
    douban_ratings FLOAT DEFAULT 0.0,
    description TEXT default ''
);

CREATE TABLE OldAnime (
    id INTEGER NOT NULL,
    story FLOAT NOT NULL DEFAULT 0.0,
    illustration FLOAT NOT NULL DEFAULT 0.0,
    music FLOAT NOT NULL DEFAULT 0.0,
    passion FLOAT NOT NULL DEFAULT 0.0,
    start_date TEXT,
    end_date TEXT,
    times_watched INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE NewAnime (
    id INTEGER NOT NULL,
    seasons TEXT NOT NULL,
    release_date TEXT,
    broadcast_day TEXT,
    season_rankings JSONB default '{}'
);

CREATE TABLE Quote (
    id SERIAL PRIMARY KEY,
    anime_id INTEGER NOT NULL,
    content TEXT NOT NULL,
    month TEXT NOT NULL,
    zh_translations TEXT,
    person TEXT
);

\copy Anime(name, tv_episodes, movies, status, genre, year, episode_length, douban_ratings, description) FROM 'parsed_data/anime.txt';
\copy OldAnime FROM 'parsed_data/old_anime.txt';
\copy NewAnime FROM 'parsed_data/new_anime.txt' DELIMITER E'\t'  QUOTE '"' ESCAPE '\' CSV;
\copy Quote(anime_id, content, month, zh_translations, person) FROM 'parsed_data/quote.txt';

ALTER TABLE Quote ADD FOREIGN KEY (anime_id) REFERENCES Anime(id);
