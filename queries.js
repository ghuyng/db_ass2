const initOption = {}
const pgp = require('pg-promise')(initOption)

const cn = {
    host: 'localhost',
    port: '5432',
    database: 'ass2',
    user: 'postgres',
    password: 'postword',
}

var db = pgp(cn)

const getUsers = (request, response) => {
    db.any('SELECT * FROM nhanvien')
        .then(data => {
            response.render('pages/ds_nhanvien', {empList : data})
        })
        .catch(err =>{
            response.status(404).send('Not Found')
        })
}

const getUserById = (request, response) => {
    const id = request.params.id
    db.one('SELECT * FROM nhanvien WHERE nv_manv=$1', [id])
        .then(data => {
            response.render('pages/nhanvien', {nhanvien: data})
        })
        .catch(err => {
            response.status(404).send('Not Found')
        })
}

module.exports = {
    getUsers,
    getUserById,
}