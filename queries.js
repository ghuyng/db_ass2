const { request, response } = require('express')

const initOption = {}
const pgp = require('pg-promise')(initOption)


const cn = {
    host: 'localhost',
    port: '5432',
    database: 'assign2',
    user: 'postgres',
    password: 'trung1182000',
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

const getContracts = (request, response) => {
    db.any('SELECT * FROM hopdong ORDER BY hd_mahopdong ASC')
        .then(data => {
            response.render('pages/ds_hopdong', {conList : data})
        })
        .catch(err =>{
            response.render('pages/error_hopdong', {err_mes: "Not Found"})
        })
}

const getContractById = (request, response) => {
    const id = request.params.id
    db.one('SELECT * FROM hopdong WHERE hd_mahopdong=$1', [id])
        .then(data => {
            response.render('pages/update_hopdong', {hopdong: data})
        })
        .catch(err => {
            response.render('pages/error_hopdong', {err_mes: "Not Found"})
        })
}

const getContractByName = (request, response) => {
    var ten = request.body.Ten;
    db.any("SELECT * FROM hopdong WHERE hd_ten= '"+ten+"'::varchar ORDER BY hd_mahopdong ASC")
        .then(data => {
            response.render('pages/search_hopdong', {conList: data})
        })
        .catch(err => {
            response.render('pages/error_hopdong', {err_mes: "Not found"})
        })
}

const insertContract = (request, response) => {
    var ten = request.body.Ten;
    var trangthai = request.body.TrangThai;
    var loaihopdong = request.body.LoaiHopDong;
    var ngaybatdau = request.body.NgayBatDau;
    var ngayketthuc = request.body.NgayKetThuc;
    var macongviec = request.body.MaCongViec;
    db.query("insert into hopdong (hd_ten, hd_trangthai, hd_loaihopdong, hd_ngaybatdau, hd_ngayketthuc, hd_macongviec) values ('"+ten+"'::varchar, '"+trangthai+"'::TT_HopDong,'"+loaihopdong+"'::varchar,'"+ngaybatdau+"'::timestamp,'"+ngayketthuc+"'::timestamp,'"+macongviec+"'::integer)")
    .then(data => {
        response.redirect("../hopdong")
    })
    .catch(err => {
        response.render('pages/error_hopdong', {err_mes: err.message})
    })
}

const updateContract = (request, response) => {
    var mahopdong = request.body.MaHopDong;
    var ten = request.body.Ten;
    var trangthai = request.body.TrangThai;
    var loaihopdong = request.body.LoaiHopDong;
    var ngaybatdau = request.body.NgayBatDau;
    var ngayketthuc = request.body.NgayKetThuc;
    var macongviec = request.body.MaCongViec;
    db.query("UPDATE HopDong SET HD_Ten = '"+ten+"'::varchar,HD_TrangThai = '"+trangthai+"'::TT_HopDong,HD_LoaiHopDong = '"+loaihopdong+"'::varchar,HD_NgayBatDau = '"+ngaybatdau+"'::timestamp,HD_NgayKetThuc = '"+ngayketthuc+"'::timestamp,HD_MaCongViec = '"+macongviec+"'::integer WHERE HD_MaHopDong = '"+mahopdong+"'::integer")
    .then(data => {
        response.redirect("../hopdong")
    })
    .catch(err => {
        response.render('pages/error_hopdong', {err_mes: err.message})
    })

}

const deleteContract = (request,response) =>{
    db.query('DELETE FROM HopDong WHERE HD_MaHopDong = $1', request.params.id)
    .then(data => {
        response.redirect("../")
    })
    .catch(err => {
        response.render('pages/error_hopdong', {err_mes: err.message})
    })
}

const moreInfoAboutContract = (request,response) =>{
    const id = request.params.id
    db.one('SELECT * FROM ((NhanVien join NguoiLaoDong on NV_QuocTich = NLD_QuocTich AND NV_MaSoCMND = NLD_MaSoCMND) join LamViecCho on NV_QuocTich = LVC_QuocTich and NV_MaSoCMND = LVC_MaSoCMND) join HopDong on LVC_MaHopDong = HD_MaHopDong WHERE HD_MaHopDong = $1', [id])
        .then(data => {
            response.render('pages/moreinfo_hopdong', {info: data})
        })
        .catch(err => {
            response.render('pages/error_hopdong', {err_mes: "Not Found"})
        })
}

module.exports = {
    getUsers,
    getUserById,
    getContracts,
    getContractById,
    getContractByName,
    insertContract,
    updateContract,
    deleteContract,
    moreInfoAboutContract,
}