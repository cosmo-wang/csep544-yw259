const express = require('express')
const cors = require('cors');
const app = express()
const port = 3001

const allowedOrigins = ['http://localhost:3000',
                      'https://cosmo-wang.github.io/bangumi-ratings/'];
app.use(cors({
  origin: function(origin, callback){
    if(!origin) return callback(null, true);
    if(allowedOrigins.indexOf(origin) === -1){
      var msg = 'The CORS policy for this site does not ' +
                'allow access from the specified Origin.';
      return callback(new Error(msg), false);
    }
    return callback(null, true);
  }
}));

const AnimeDAO = require('./AnimeDAO')

app.use(express.json())
app.use(function (req, res, next) {
    res.setHeader('Access-Control-Allow-Origin', 'http://localhost:3000');
    res.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE');
    res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Access-Control-Allow-Headers');
    next();
});

app.get('/ratings', (req, res) => {
    AnimeDAO.getRatings()
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            res.status(500).send(error);
        })
})

app.get('/quotes', (req, res) => {
    AnimeDAO.getQuotes()
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            res.status(500).send(error);
        })
})

app.get('/new_animes', (req, res) => {
    AnimeDAO.getNewAnimes()
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            res.status(500).send(error);
        })
})

app.post('/add_anime', (req, res) =>{
    const isOldAnime = req.query.type === 'old';
    AnimeDAO.addAnime(req.body, isOldAnime)
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            if (error.code === '23505') {
                res.sendStatus(400);
            } else {
                res.status(500).send(error);
            }
        })
});

app.post('/add_quote', (req, res) =>{
    AnimeDAO.addQuote(req.body)
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            res.status(500).send(error);
        })
});

app.post('/update_anime', (req, res) => {
    const id = req.query.id;
    const isOldAnime = req.query.type === 'old';
    AnimeDAO.updateAnime(id, req.body, isOldAnime)
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            res.status(500).send(error);
        });
});

app.post('/update_quote', (req, res) => {
    const id = req.query.id;
    AnimeDAO.updateQuote(id, req.body)
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            res.status(500).send(error);
        });
});

app.post('/update_rankings', (req, res) => {
    AnimeDAO.updateRankings(req.body)
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            res.status(500).send(error);
        });
});

app.delete('/anime', (req, res) =>{
    const id = req.query.id;
    const isOldAnime = req.query.type === 'old';
    AnimeDAO.deleteAnime(id, isOldAnime)
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            res.status(500).send(error);
        })
});

app.delete('/quote', (req, res) =>{
    const id = req.query.id;
    AnimeDAO.deleteQuote(id)
        .then(response => {
            res.status(200).send(response);
        })
        .catch(error => {
            res.status(500).send(error);
        })
});

app.listen(port, () => {
    console.log(`App running on port ${port}.`)
})