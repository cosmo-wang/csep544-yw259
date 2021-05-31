DROP TABLE IF EXISTS QuotedFrom;
DROP TABLE IF EXISTS Anime;
DROP TABLE IF EXISTS OldAnime;
DROP TABLE IF EXISTS NewAnime;
DROP TABLE IF EXISTS Quote;

CREATE TABLE Anime (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    tv_episodes INTEGER DEFAULT 0,
    movies INTEGER NOT NULL DEFAULT 0,
    status TEXT NOT NULL,
    genre TEXT NOT NULL,
    year TEXT,
    episode_length FLOAT NOT NULL,
    douban_ratings FLOAT DEFAULT 0.0,
    description TEXT
);

CREATE TABLE OldAnime (
    id INTEGER PRIMARY KEY,
    story FLOAT NOT NULL DEFAULT 0.0,
    illustration FLOAT NOT NULL DEFAULT 0.0,
    music FLOAT NOT NULL DEFAULT 0.0,
    passion FLOAT NOT NULL DEFAULT 0.0,
    start_date TEXT,
    end_date TEXT,
    times_watched INTEGER NOT NULL DEFAULT 0
);

CREATE TABLE NewAnime (
    id INTEGER PRIMARY KEY,
    seasons TEXT[] NOT NULL,
    release_date TEXT,
    broadcast_day TEXT,
    season_rankings JSONB
);

CREATE TABLE Quote (
    id INTEGER PRIMARY KEY,
    content TEXT NOT NULL,
    month TEXT NOT NULL,
    zh_translations TEXT,
    person TEXT
);

CREATE TABLE QuotedFrom (
    quote_id INTEGER PRIMARY KEY,
    anime_id INTEGER NOT NULL,
    FOREIGN KEY (anime_id) REFERENCES Anime(id),
    FOREIGN KEY (quote_id) REFERENCES Quote(id)
);

\copy Anime FROM 'parsed_data/anime.txt';
\copy OldAnime FROM 'parsed_data/old_anime.txt';
\copy NewAnime FROM 'parsed_data/new_anime.txt' DELIMITER E'\t'  QUOTE '"' ESCAPE '\' CSV;
\copy Quote FROM 'parsed_data/quote.txt';
\copy QuotedFrom FROM 'parsed_data/quoted_from.txt';