import json

DELIMITER = '\t'
INPUT_DIR = 'original_data/'
OUTPUT_DIR = 'parsed_data/'

def safe_get(json_obj, key, default_value=""):
    try:
        value = str(json_obj[key])
        if value == "Invalid date":
            value = ""
        elif value == "":
            value = default_value
        return value
    except KeyError:
        return default_value

class Anime:
    def __init__(self, anime_id, name, tv_episodes, movies, status, genre, year, episode_length, douban_ratings, description):
        self.anime_id = anime_id
        self.name = name
        self.tv_episodes = tv_episodes
        self.movies = movies
        self.status = status
        self.genre = genre
        self.year = year
        self.episode_length = episode_length
        self.douban_ratings = douban_ratings
        self.description = description

    def __str__(self):
        return f"{self.name}\t{self.tv_episodes}\t{self.movies}\t{self.status}\t{self.genre}\t{self.year}\t{self.episode_length}\t{self.douban_ratings}\t{self.description}"

class OldAnime:
    def __init__(self, anime_id, story, illustration, music, passion, start_date, end_date, times_watched):
        self.anime_id = anime_id
        self.story = story
        self.illustration = illustration
        self.music = music
        self.passion = passion
        self.start_date = start_date
        self.end_date = end_date
        self.times_watched = times_watched

    def __str__(self):
        return f"{self.anime_id}\t{self.story}\t{self.illustration}\t{self.music}\t{self.passion}\t{self.start_date}\t{self.end_date}\t{self.times_watched}"

class NewAnime:
    def __init__(self, anime_id, seasons, release_date, broadcast_day, season_rankings):
        self.anime_id = anime_id
        self.seasons = seasons
        self.release_date = release_date
        self.broadcast_day = broadcast_day
        self.season_rankings = season_rankings

    def __str__(self):
        return f"{self.anime_id}\t{self.seasons}\t{self.release_date}\t{self.broadcast_day}\t{self.season_rankings}"

class Quote:
    def __init__(self, quote_id, anime_id, content, month, zh_translation, person):
        self.quote_id = quote_id
        self.anime_id = anime_id
        self.content = content
        self.month = month
        self.zh_translation = zh_translation
        self.person = person

    def __str__(self):
        return f"{self.anime_id}\t{self.content}\t{self.month}\t{self.zh_translation}\t{self.person}"

f_ratings = open(INPUT_DIR + 'Ratings.json')
f_new_animes = open(INPUT_DIR + 'NewAnimes.json')
f_quotes = open(INPUT_DIR + 'Quotes.json')

f_anime = open(OUTPUT_DIR + 'anime.txt', 'w')
f_old_anime = open(OUTPUT_DIR + 'old_anime.txt', 'w')
f_new_anime = open(OUTPUT_DIR + 'new_anime.txt', 'w')
f_quote = open(OUTPUT_DIR + 'quote.txt', 'w')

ratings = json.load(f_ratings)['results']
new_animes = json.load(f_new_animes)['results']
quotes = json.load(f_quotes)['results']

anime_id = 1
anime_to_id = {}
for rating in ratings:
    anime = Anime(anime_id, safe_get(rating, "name"), safe_get(rating, "tv_episodes", 0), safe_get(rating, "movies"), \
        safe_get(rating, "status"), safe_get(rating, "genre"), safe_get(rating, "year"), safe_get(rating, "episode_length"), \
        safe_get(rating, "douban", default_value=0), safe_get(rating, "description").replace('\n', ""))
    anime_to_id[safe_get(rating, "name")] = anime_id
    old_anime = OldAnime(anime_id, safe_get(rating, "story"), safe_get(rating, "illustration"), safe_get(rating, "music"), \
        safe_get(rating, "passion"), safe_get(rating, "start_date"), safe_get(rating, "end_date"), safe_get(rating, "times_watched"))
    f_anime.write(str(anime) + '\n')
    f_old_anime.write(str(old_anime) + '\n')
    anime_id += 1

for new_anime in new_animes:
    if safe_get(new_anime, "name") not in anime_to_id:
        cur_id = anime_id
        anime = Anime(cur_id, safe_get(new_anime, "name"), safe_get(new_anime, "tv_episodes"), 0, \
            safe_get(new_anime, "status"), safe_get(new_anime, "genre"), 2021, 24, 0, safe_get(new_anime, "description").replace('\n', ""))
        anime_to_id[safe_get(rating, "name")] = anime_id
        f_anime.write(str(anime) + '\n')
        anime_id += 1
    else:
        cur_id = anime_to_id[safe_get(new_anime, "name")]
    new_anime_obj = NewAnime(cur_id, safe_get(new_anime, "season"), safe_get(new_anime, "start_date"), \
        safe_get(new_anime, "next_episode_day"), "\"" + safe_get(new_anime, "seasons_ranking").replace('\'', "\\\"") + "\"" )
    f_new_anime.write(str(new_anime_obj) + '\n')
        

quote_id = 1
for quote in quotes:
    quote_obj = Quote(quote_id, anime_to_id[safe_get(quote, "bangumi")], safe_get(quote, "content").replace('\n', ""), safe_get(quote, "month"), \
        safe_get(quote, "translation").replace('\n', ""), safe_get(quote, "person"))
    f_quote.write(str(quote_obj) + '\n')
    quote_id += 1
