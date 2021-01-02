const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const port = 3000
const db = require('./queries')

app.set('view engine', 'ejs')

app.use(bodyParser.json())
app.use(
    bodyParser.urlencoded({
        extended: true,
    })
)

app.get('/', (request, response) => {
    response.render('pages/index')
})

app.get('/nhanvien', db.getUsers)
app.get('/nhanvien/:id', db.getUserById)

app.listen(port, ()=>{
    console.log(`App running on port ${port}.`)
})
