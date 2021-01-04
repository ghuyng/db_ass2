const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const port = 3000
const db = require('./queries')
const { response, request } = require('express')

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
app.get('/tuyendung', db.getRecruitmentInfo)

app.get('/tuyendung/new', (request, response) => {
    response.render('pages/form_modottuyendung')
})
app.post('/tuyendung/new', db.addNewDotTuyenDung)


app.get('/tuyendung/:id', db.getRecruitmentJobById)

app.delete('/tuyendung/:id', db.deleteDotTuyenDung)


app.get('/taphuan', db.xemDSTapHuan)
app.get('/taphuan/new', (request, response) =>{
    response.render('pages/form_motaphuan')
})

app.post('/taphuan/new', db.insertTapHuan)

app.get('/taphuan/:id', db.xemChiTietTapHuan)
app.delete('/taphuan/:id', db.xoaDotTapHuan)

app.get('/taphuan/:id/update', db.editTapHuan) 
app.post('/taphuan/:id/update', db.updateTapHuan) 
app.post('/taphuan/:id/add-employee/', db.themNguoiTapHuan) 


app.listen(port, ()=>{
    console.log(`App running on port ${port}.`)
})
