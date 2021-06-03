const moment = require('moment');

const Pool = require('pg').Pool
const pool = new Pool({
    user: 'cosmo',
    host: 'localhost',
    database: 'animedb',
    password: '',
    port: 5432,
});

const getRatings = () => {
    return new Promise(function(resolve, reject) {
        const query = 'SELECT a.id, a.name, a.year, a.douban_ratings, a.tv_episodes, a.movies, ' +
                        'a.episode_length, a.status, a.genre, a.description, ' +
                        'b.story, b.illustration, b.music, b.passion, b.start_date, ' +
                        'b.end_date, (b.story + b.illustration + b.music + b.passion)::float AS rating, b.times_watched ' +
                        'FROM Anime a, OldAnime b ' +
                        'WHERE a.id = b.id';
        console.log(query);
        pool.query(query, (error, results) => {
          if (error) {
            reject(error);
          } else {
            results.rows.forEach(row => row.rating = row.rating.toFixed(1));
            resolve(results.rows);
          }
        })
    })
}

const getQuotes = () => {
    return new Promise(function(resolve, reject) {
        const query = 'SELECT q.id, q.month, q.content, q.person, q.zh_translations, a.name AS anime_name ' +
                        'FROM Quote q, Anime a ' +
                        'WHERE q.anime_id = a.id';
        console.log(query);
        pool.query(query, (error, results) => {
          if (error) {
            reject(error)
          } else {
            resolve(results.rows);
          }
        })
    })
}

const getNewAnimes = () => {
    return new Promise(function(resolve, reject) {
        const query = 'SELECT a.id, a.name, a.genre, n.season_rankings, n.release_date, ' +
                        'n.broadcast_day, a.tv_episodes, a.description, n.seasons, a.status ' +
                        'FROM NewAnime n, Anime a ' +
                        'WHERE n.id = a.id';
        console.log(query);
        pool.query(query, (error, results) => {
          if (error) {
            reject(error)
          } else {
            resolve(results.rows);
          }
        })
    })
}

const addAnime = async (newEntry, isOldAnime) => {
    const animeId = await new Promise((resolve, reject) => {
        let movies, year, episode_length, douban_ratings;
        if (isOldAnime) {
            movies = newEntry.movies;
            year = newEntry.year;
            episode_length = newEntry.episode_length;
            douban_ratings = newEntry.douban_ratings;
        } else {
            movies = 0;
            year = new Date().getFullYear();
            episode_length = 24;
            douban_ratings = 0;
        }
        const animeTableQuery = 'INSERT INTO Anime(name, tv_episodes, movies, status, ' +
            'genre, year, episode_length, douban_ratings, description) VALUES ' +
            `(\'${newEntry.name}\', ${newEntry.tv_episodes}, ${movies}, ` +
            `\'${newEntry.status}\', \'${newEntry.genre}\', \'${year}\', ` +
            `${episode_length}, ${douban_ratings}, \'${newEntry.description}\') RETURNING id;`;
        console.log(animeTableQuery);
        pool.query(animeTableQuery, (error, results) => {
          if (error) {
            reject(error);
          } else {
            resolve(results.rows[0].id)
          }
        })
    });
    const secondQuery = isOldAnime ? 'INSERT INTO OldAnime(id, story, illustration, ' +
            'music, passion, start_date, end_date, times_watched) VALUES ' +
            `(${animeId}, ${newEntry.story}, ${newEntry.illustration}, ${newEntry.music}, ${newEntry.passion}, ` +
            `\'${newEntry.start_date}\', \'${newEntry.end_date}\', ${newEntry.times_watched});` : 
            'INSERT INTO NewAnime(id, seasons, release_date, ' +
            'broadcast_day) VALUES ' +
            `(${animeId}, \'${newEntry.seasons}\', \'${newEntry.release_date}\', \'${newEntry.broadcast_day}\');`
    return new Promise((resolve, reject) => {
        console.log(secondQuery);
        pool.query(secondQuery, (error, results) => {
            if (error) {
                reject(error);
            } else {
                resolve("success")
            }
        })
    });
}

const addQuote = async (newQuote) => {
    return new Promise(function(resolve, reject) {
        const query = 'INSERT INTO Quote(anime_id, content, month, zh_translations, person) ' +
                `VALUES ((SELECT id FROM Anime WHERE name = \'${newQuote.anime_name}\'), \'${newQuote.content}\', ` +
                `\'${newQuote.month}\', \'${newQuote.zh_translations}\', \'${newQuote.person}\');`;
        console.log(query);
        pool.query(query, (error, results) => {
          if (error) {
            reject(error)
          } else {
            resolve("success");
          }
        });
    });
}

const updateAnime = async (id, newEntry, isOldAnime) => {
    return new Promise(function(resolve, reject) {
        let movies, year, episode_length, douban_ratings;
        if (isOldAnime) {
            movies = newEntry.movies;
            year = newEntry.year;
            episode_length = newEntry.episode_length;
            douban_ratings = newEntry.douban_ratings;
        } else {
            movies = 0;
            year = new Date().getFullYear();
            episode_length = 24;
            douban_ratings = 0;
        }
        const firstQuery = 'UPDATE Anime SET ' + 
            `name = \'${newEntry.name}\', tv_episodes = ${newEntry.tv_episodes}, ` +
            `movies = ${movies}, status = \'${newEntry.status}\', genre = \'${newEntry.status}\', ` +
            `year = \'${year}\', episode_length = ${episode_length}, douban_ratings = ${douban_ratings}, ` +
            `description = \'${newEntry.description}\' WHERE id = ${id}; `;
        const secondQuery = isOldAnime ? 'UPDATE OldAnime SET ' + 
            `story = ${newEntry.story}, illustration = ${newEntry.illustration}, ` +
            `music = ${newEntry.music}, passion = ${newEntry.passion}, ` + 
            `start_date = \'${newEntry.start_date}\', end_date = \'${newEntry.end_date}\', ` + 
            `times_watched = ${newEntry.times_watched} WHERE id = ${id};` : 
            'UPDATE NewAnime SET ' + 
            `seasons = \'${newEntry.seasons}\', release_date = \'${newEntry.release_date}\', ` +
            `broadcast_day = \'${newEntry.broadcast_day}\' WHERE id = ${id}`;
        console.log(firstQuery + secondQuery);
        pool.query(firstQuery + secondQuery, (error, results) => {
          if (error) {
            reject(error)
          } else {
            resolve("success");
          }
        });
    });
}

const updateQuote = async (id, quoteData) => {
    return new Promise((resolve, reject) => {
        const query = 'UPDATE Quote SET ' + 
            `anime_id = (SELECT id FROM Anime WHERE name = \'${quoteData.anime_name}\'), ` +
            `content = \'${quoteData.content}\', month = \'${quoteData.month}\', ` +
            `zh_translations = \'${quoteData.zh_translations}\', person = \'${quoteData.person}\' WHERE id = ${id};`;
        console.log(query);
        pool.query(query, (error, results) => {
          if (error) {
            reject(error)
          } else {
            resolve("success");
          }
        });
    });
}

const updateRankings = async (newRankings) => {
    return new Promise((resolve, reject) => {
        let query = '';
        Object.keys(newRankings).forEach(id => {
            query += 'UPDATE NewAnime SET season_rankings=' + 
                    `\'${JSON.stringify(newRankings[id])}\' WHERE id = ${id}; `;
        })
        console.log(query);
        pool.query(query, (error, results) => {
            if (error) {
              reject(error)
            } else {
              resolve("success");
            }
        });
    });
}

const deleteAnime = async (id, isOldAnime) => {
    return new Promise(function(resolve, reject) {
        const query = `DELETE FROM Anime WHERE id = ${id}; DELETE FROM ${isOldAnime ? 'OldAnime' : 'NewAnime'} WHERE id = ${id};`;
        console.log(query);
        pool.query(query, (error, results) => {
          if (error) {
            reject(error)
          } else {
            resolve("success");
          }
        });
    });
}

const deleteQuote = async (id) => {
    return new Promise(function(resolve, reject) {
        const query = `DELETE FROM Quote WHERE id = ${id};`;
        console.log(query);
        pool.query(query, (error, results) => {
          if (error) {
            reject(error)
          } else {
            resolve("success");
          }
        });
    });
}

module.exports = {
    getRatings,
    getQuotes,
    getNewAnimes,
    addAnime,
    deleteAnime,
    updateAnime,
    addQuote,
    updateQuote,
    deleteQuote,
    updateRankings
}
