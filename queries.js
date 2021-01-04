const { response, request } = require('express')

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

const getRecruitmentInfo = (request, response) => {
    db.any(`SELECT pb_maso, pb_ten, cv_macongviec, cv_tencongviec, dtd_soluongcantuyen, dtd_madot
            FROM (congviec join dottuyendung on cv_macongviec = dtd_macongviec) join phongban on cv_masophongban = pb_maso
            WHERE current_date <= dtd_ngayketthuc
            GROUP BY pb_maso, pb_ten, cv_macongviec, cv_tencongviec, dtd_soluongcantuyen, dtd_madot`)
        .then(data => {
            response.render('pages/tuyendung', {jobs: data})
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const getRecruitmentJobById = (request, response) => {
    const id = request.params.id
    db.one(`SELECT cv_tencongviec, cv_mota, pb_ten, pb_masobophan, dtd_soluongcantuyen, dtd_ngaybatdau::date, dtd_ngayketthuc::date
            FROM (congviec join dottuyendung on cv_macongviec = dtd_macongviec) join phongban on cv_masophongban = pb_maso
            WHERE current_date <= dtd_ngayketthuc and cv_macongviec = $1`, [id])
        .then(data => {
            response.render('pages/congviec', {job: data})
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const addNewDotTuyenDung = (request, response) => {
    const {macongviec, soluongcantuyen, ngaybatdau, ngayketthuc} = request.body
    db.proc('p_add_new_dottuyendung', [ngaybatdau, ngayketthuc, macongviec, soluongcantuyen])
        .then(data => {
            response.redirect('/tuyendung')
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const deleteDotTuyenDung = (request, response) => {
    const id = request.params.id
    db.query('DELETE FROM dottuyendung WHERE dtd_madot = $1', [id])
        .then(data => {
            response.status(200).send(data)
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const xemDSTapHuan = (request, response) => {
    db.any(`SELECT * FROM taphuan`)
        .then(data => {
            response.render('pages/ds_taphuan', {ds_taphuan: data})
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const insertTapHuan = (request, response) => {
    const {tenctydoitac, diadiem, thoigian, chude, masophongban} = request.body
    db.proc('p_insert_taphuan', [tenctydoitac, diadiem, thoigian, chude, masophongban])
        .then(data => {
            response.status(200).redirect('/taphuan')
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const xemChiTietTapHuan = (request, response) => {
    const id = request.params.id
    db.any(`SELECT nld_sdt, nld_gioitinh, nld_ho ||' '|| nld_tendem ||' '|| nld_ten as name, nv_manv, tgth_vaitro
            FROM ((taphuan join thamgiataphuan on th_maso = tgth_masotaphuan) join nhanvien on tgth_quoctich = nv_quoctich and tgth_masocmnd = nv_masocmnd)
                join nguoilaodong on nv_quoctich = nld_quoctich and nv_masocmnd = nld_masocmnd
            WHERE th_maso = $1`, [id])
        .then(data => {
            response.render('pages/chitiettaphuan', {data: data, th_maso: id})
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const xoaDotTapHuan = (request, response) => {
    const id = request.params.id
    db.query('DELETE FROM taphuan WHERE th_maso = $1', [id])
        .then(data => {
            response.status(200).send(data)
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const updateTapHuan = (request, response) => {
    const id = request.params.id
    const {tenctydoitac, diadiem, thoigian, chude, masophongban} = request.body
    db.one(`UPDATE taphuan 
            SET th_tenctydoitac = ${tenctydoitac},
                th_diadiem = ${diadiem},
                th_thoigian = ${thoigian},
                th_chude = ${chude},
                th_masophongban = ${masophongban}
            WHERE th_maso = $1`, [id])
        .then(data => {
            response.status(200).redirect(`/taphuan/${id}`)
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const editTapHuan = (request, response) => {
    const id = request.params.id
    db.one(`SELECT * FROM taphuan WHERE th_maso = $1`, [id])
        .then(data => {
            response.status(200).render('pages/form_update_taphuan', {data:data})
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const themNguoiTapHuan = (request, response) => {
    const {manv, vaitro} = request.body
    const th_maso = request.params.id
    db.task('insert_taphuan', async t => {
        const nvien = await t.one(`SELECT nv_quoctich, nv_masocmnd FROM nhanvien WHERE nv_manv = $1`, [manv])
        return t.any(`INSERT INTO thamgiataphuan(tgth_quoctich, tgth_masocmnd, tgth_masotaphuan, tgth_vaitro)
                        VALUES ($1, $2, $3, $4)`, [nvien.nv_quoctich, nvien.nv_masocmnd, th_maso, vaitro])
    })
        .then(data => {
            response.status(200).redirect(`/taphuan/${th_maso}`)
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}


module.exports = {
    getUsers,
    getUserById,
    getRecruitmentInfo,
    getRecruitmentJobById,
    addNewDotTuyenDung,
    deleteDotTuyenDung,
    xemDSTapHuan,
    insertTapHuan,
    xemChiTietTapHuan,
    xoaDotTapHuan,
    updateTapHuan,
    editTapHuan,
    themNguoiTapHuan,
}