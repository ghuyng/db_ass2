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
            //response.status(404).send(err.message)
            response.render('pages/form_motaphuan',{message: err.message})
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
    var a = 1
    const id = request.params.id
    const {tenctydoitac, diadiem, thoigian, chude, masophongban} = request.body
    db.any(`UPDATE taphuan 
            SET th_tenctydoitac = $1,
                th_diadiem = $2,
                th_thoigian =$3 ,
                th_chude = $4,
                th_masophongban = $5
            WHERE th_maso = $6`, [tenctydoitac, diadiem, thoigian, chude, masophongban, id])
        .then(data => {
            a = data
            response.status(200).redirect(`/taphuan`)
        })
        .catch(err => {
            //response.status(404).send(err.message)
            response.render('pages/form_update_taphuan', {data: a, message: err.message})
        })
}

const editTapHuan = (request, response) => {
    const id = request.params.id
    db.one(`SELECT * FROM taphuan WHERE th_maso = $1`, [id])
        .then(data => {
            response.status(200).render('pages/form_update_taphuan', {data:data, message: null})
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

const viewProjectList = (request, response) => {
    keyword = request.query.search?request.query.search:''
    db.any(`SELECT *
            FROM (duan JOIN phongban ON da_masophongban = pb_maso)
            WHERE da_ten ~* '.*${keyword}.*'`)
        .then(data => {
            response.render('pages/ds_duan', {projects: data})
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const insertProject = (request, response) => {
    const {ten, trangthai, masophongban} = request.body
    db.any(`INSERT INTO duan(da_ten, da_trangthai, da_masophongban)
            VALUES ($1, $2, $3)`, [ten, trangthai, masophongban])
        .then(data => {
            response.status(200).redirect('/duan')
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const getProjectEmployeeDetail = (request, response) => {
    const id = request.params.id
    db.any(`SELECT nv_manv, nld_ho|| ' '|| nld_tendem || ' ' || nld_ten as ten_nv, tgl_thoiluong, tgl_ngaytieptuc
            FROM ((((duan JOIN lamviectren ON da_maso = lvt_masoduan) JOIN thoigianlam ON tgl_masoduan = da_maso)
                     JOIN nhanvien ON lvt_quoctich = nv_quoctich AND lvt_masocmnd = nv_masocmnd)
                     JOIN nguoilaodong ON nld_quoctich = nv_quoctich AND nld_masocmnd = nv_masocmnd)
            WHERE da_maso = $1`, [id])
        .then(data => {
            response.render('pages/duan_nhanvien', {empList: data, da_maso: id})
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const getProjectPartnerDetail = (request, response) => {
    const id = request.params.id
    db.any(`SELECT *
            FROM (duan JOIN doitac ON dt_masoduan = da_maso)
            WHERE da_maso = $1`, [id])
        .then(data => {
            response.render('pages/duan_doitac', {data: data, da_maso: id})
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const addProjectPartner = (request, response) => {
    const id = request.params.id
    const tendoitac = request.body.tendoitac
    db.any(`INSERT INTO doitac(dt_tendoitac, dt_masoduan) 
            VALUES ($1, $2)`, [tendoitac, id])
        .then(data => {
            response.status(200).redirect(`/duan/${id}/partner`)
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const deleteProject = (request, response) => {
    const id = request.params.id
    db.query('DELETE FROM duan WHERE da_maso = $1', [id])
        .then(data => {
            response.status(200).send(data)
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const updateProject = (request, response) => {
    const id = request.params.id
    const {tenduan, trangthai, masophongban} = request.body
    db.any(`UPDATE duan 
            SET da_ten = $1,
                da_trangthai = $2,
                da_masophongban = $3
            WHERE da_maso = $4`, [tenduan, trangthai, masophongban, id])
        .then(data => {
            response.status(200).redirect(`/duan`)
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const modifyProject = (request, response) => {
    const id = request.params.id
    db.one(`SELECT * FROM duan WHERE da_maso = $1`, [id])
        .then(data => {
            response.status(200).render('pages/form_update_duan', {data:data})
        })
        .catch(err => {
            response.status(404).send(err.message)
        })
}

const addEmployeeToProject = (request, response) => {
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

const deleteProjectPartner = (request, response) => {
    const id = request.params.id
    const {tendoitac} = request.body
    db.query('DELETE FROM doitac WHERE dt_tendoitac = $1 AND dt_masoduan = $2', [tendoitac, id])
        .then(data => {
            response.status(200).send(data)
        })
        .catch(err => {
            response.status(404).send(err.message)
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
    viewProjectList,
    insertProject,
    deleteProject,
    addEmployeeToProject,
    updateProject,
    modifyProject,
    getProjectEmployeeDetail,
    getProjectPartnerDetail,
    addProjectPartner,
    deleteProjectPartner,
    getContracts,
    getContractById,
    getContractByName,
    insertContract,
    updateContract,
    deleteContract,
    moreInfoAboutContract,
}