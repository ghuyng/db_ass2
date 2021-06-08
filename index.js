const express = require('express')
const bodyParser = require('body-parser')
const app = express()
const port = 3000
// const db = require('./queries')
const { response, request } = require('express')
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

// app.get('/nhanvien', db.getUsers)
// app.get('/nhanvien/:id', db.getUserById)


// // Routing for tuyen dung
// app.get('/tuyendung', db.getRecruitmentInfo)

// app.get('/tuyendung/new', (request, response) => {
//     response.render('pages/form_modottuyendung')
// })
// app.post('/tuyendung/new', db.addNewDotTuyenDung)


// app.get('/tuyendung/:id', db.getRecruitmentJobById)

// app.delete('/tuyendung/:id', db.deleteDotTuyenDung)


// //Routing for tap huan
// app.get('/taphuan', db.xemDSTapHuan)
// app.get('/taphuan/new', (request, response) =>{
//     response.render('pages/form_motaphuan', {message: null})
// })

// app.post('/taphuan/new', db.insertTapHuan)

// app.get('/taphuan/:id', db.xemChiTietTapHuan)
// app.delete('/taphuan/:id', db.xoaDotTapHuan)

// app.get('/taphuan/:id/update', db.editTapHuan)
// app.post('/taphuan/:id/update', db.updateTapHuan)
// app.post('/taphuan/:id/add-employee/', db.themNguoiTapHuan)


// // Routing for Du An
// app.get('/duan', db.viewProjectList)
// app.post('/duan/', db.insertProject)
// app.get('/duan/:id/employee', db.getProjectEmployeeDetail)
// app.post('/duan/:id/employee/', db.addEmployeeToProject)
// app.get('/duan/:id/partner', db.getProjectPartnerDetail)
// app.post('/duan/:id/partner', db.addProjectPartner)
// app.delete('/duan/:id/partner', db.deleteProjectPartner)
// app.delete('/duan/:id', db.deleteProject)
// app.get('/duan/:id/update', db.modifyProject)
// app.post('/duan/:id/update', db.updateProject)
// app.post('/duan/:id/employee/', db.addEmployeeToProject)


// app.get('/hopdong', db.getContracts)
// app.get('/hopdong/insert', (request, response) => {response.render('pages/insert_hopdong')})
// app.post('/hopdong/insert',urlencodedParser, db.insertContract)
// app.get('/hopdong/update/:id', db.getContractById)
// app.post('/hopdong/update',urlencodedParser, db.updateContract)
// app.get('/hopdong/delete/:id', db.deleteContract)
// app.get('/hopdong/moreinfo/:id', db.moreInfoAboutContract)
// app.post('/hopdong/search',urlencodedParser, db.getContractByName)
// app.get('/nguoilaodong', db.getWorkers)

app.listen(port, ()=>{
    console.log(`App running on port ${port}.`)
})
