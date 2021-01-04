const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const port = 3000
const db = require('./queries')
var urlencodedParser = bodyParser.urlencoded({ extended: false })

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

app.get('/hopdong', db.getContracts)
app.get('/hopdong/insert', (request, response) => {response.render('pages/insert_hopdong')})
app.post('/hopdong/insert',urlencodedParser, db.insertContract)
app.get('/hopdong/update/:id', db.getContractById)
app.post('/hopdong/update',urlencodedParser, db.updateContract)
app.get('/hopdong/delete/:id', db.deleteContract)
app.get('/hopdong/moreinfo/:id', db.moreInfoAboutContract)
app.post('/hopdong/search',urlencodedParser, db.getContractByName)

app.listen(port, ()=>{
    console.log(`App running on port ${port}.`)
})
