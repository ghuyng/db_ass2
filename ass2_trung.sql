-- drop database if exists ass2;
-- create database ass2;

create table QuyetDinh(
    QD_MaSo serial primary key ,
    QD_NgayRaQD timestamp,
    QD_LoaiQD varchar(20),
    check ( QD_NgayRaQD <= current_date )
);

create table BangCong(
    BC_MaSo serial primary key ,
    BC_GioVaoLamQuyDinh time ,
    BC_GioRaVeQuyDinh time,
    check ( BC_GioRaVeQuyDinh > BC_GioVaoLamQuyDinh )
);

create table NgayLamViec(
    NLV_MaBangCong int ,
    NLV_Ngay date ,
    NLV_GioVaoLam time ,
    NLV_GioRaVe time,
    primary key (NLV_MaBangCong, NLV_Ngay),
    foreign key (NLV_MaBangCong) references BangCong(BC_MaSo),
    check ( NLV_GioRaVe > NLV_GioVaoLam )
);

create table BoPhan(
    BP_MaSo serial primary key ,
    BP_Ten varchar(50)
);

create table PhongBan(
    PB_MaSo serial primary key ,
    PB_Ten varchar(50),
    PB_MaSoBoPhan int ,
    foreign key (PB_MaSoBoPhan) references BoPhan(BP_MaSo)
);

create type TT_DuAn as enum ('In progress', 'On hold', 'Completed');
create table DuAn(
    DA_MaSo serial primary key ,
    DA_Ten varchar(50),
    DA_TrangThai TT_DuAn,
    DA_MaSoPhongBan int ,
    foreign key (DA_MaSoPhongBan) references PhongBan(PB_MaSo)
);

create table DoiTac(
    DT_TenDoiTac varchar(50),
    DT_MaSoDuAn int ,
    primary key (DT_TenDoiTac, DT_MaSoDuAn),
    foreign key (DT_MaSoDuAn) references DuAn(DA_MaSo)
);

create table TapHuan(
    TH_MaSo serial primary key ,
    TH_TenCTYDoiTac varchar(50),
    TH_DiaDiem varchar(50),
    TH_ThoiGian date,
    TH_ChuDe varchar(50),
    TH_MaSoPhongBan int,
    foreign key (TH_MaSoPhongBan) references PhongBan(PB_MaSo)
);

create table CongViec(
    CV_MaCongViec serial primary key ,
    CV_TenCongViec varchar(50),
    CV_MoTa varchar(200),
    CV_MaSoPhongBan int ,
    foreign key (CV_MaSoPhongBan) references PhongBan(PB_MaSo)
);
create type TT_HopDong as enum ('Expired', 'Terminated', 'Active');
create table HopDong(
    HD_MaHopDong serial primary key ,
    HD_Ten varchar(50) ,
    HD_TrangThai TT_HopDong,
    HD_LoaiHopDong varchar(50),
    HD_NgayBatDau timestamp ,
    HD_NgayKetThuc timestamp ,
    HD_MaCongViec int ,
    foreign key (HD_MaCongViec) references CongViec(CV_MaCongViec)

);

create table DotTuyenDung(
    DTD_MaDot serial primary key ,
    DTD_NgayBatDau date,
    DTD_NgayKetThuc date,
    DTD_MaCongViec int,
    DTD_SoLuongCanTuyen int,
    foreign key (DTD_MaCongViec) references CongViec(CV_MaCongViec),
    check ( DTD_NgayKetThuc >= DTD_NgayBatDau )
);

create table NguoiLaoDong(
    NLD_QuocTich varchar(50),
    NLD_MaSoCMND varchar(9),
    NLD_SDT varchar(10) unique ,
    NLD_Email varchar(100) unique ,
    NLD_DiaChi varchar(200),
    NLD_GioiTinh char(1),
    NLD_NgaySinh date,
    NLD_Ho varchar(10),
    NLD_TenDem varchar(50),
    NLD_Ten varchar(10),
    primary key (NLD_QuocTich, NLD_MaSoCMND)
);

create table NhanVien(
    NV_QuocTich varchar(50),
    NV_MaSoCMND varchar(9),
    NV_MaNV varchar(5),
    NV_QuocTich_NGS varchar(50),
    NV_MaSoCMND_NGS varchar(9),
    NV_MaSoBangCong int not null ,
    primary key (NV_QuocTich, NV_MaSoCMND),
    foreign key (NV_QuocTich_NGS, NV_MaSoCMND_NGS) references NhanVien(NV_QuocTich, NV_MaSoCMND),
    foreign key (NV_MaSoBangCong) references BangCong(BC_MaSo)
);

create table NguoiXinViec(
    NXV_QuocTich varchar(50),
    NXV_MaSoCMND varchar(9),
    NXV_MaHoSoXinViec serial,
    primary key (NXV_QuocTich, NXV_MaSoCMND)
);

create table BuoiPhongVan(
    BPV_MaDot int,
    BPV_DiaDiem varchar(50),
    BPV_NgayPV timestamp,
    BPV_QuocTich varchar(50),
    BPV_MaSoCMND varchar(9),
    BPV_KetQuaPV bool,
    primary key (BPV_MaDot, BPV_DiaDiem, BPV_NgayPV, BPV_QuocTich, BPV_MaSoCMND),
    foreign key (BPV_MaDot) references DotTuyenDung(DTD_MaDot),
    foreign key (BPV_QuocTich, BPV_MaSoCMND) references NguoiXinViec(NXV_QuocTich, NXV_MaSoCMND)
);

create table Luong(
    L_QuocTich varchar(50),
    L_MaSoCMND varchar(9),
    L_LuongCoBan money,
    L_HeSoLuong decimal,
    L_HeSoPhuCap decimal,
    L_SoNgayNghiKhongPhep int default 0,
    L_ChiPhiThueVaBaoHiem money,
    primary key (L_QuocTich, L_MaSoCMND, L_LuongCoBan),
    foreign key (L_QuocTich, L_MaSoCMND) references NhanVien(NV_QuocTich, NV_MaSoCMND)
);

create table NguoiThan(
    NT_QuocTich_NV varchar(50),
    NT_MaSoCMND_NV varchar(9),
    NT_Ten varchar(50),
    NT_MoiQuanHe varchar(10),
    primary key (NT_QuocTich_NV, NT_MaSoCMND_NV, NT_Ten),
    foreign key (NT_QuocTich_NV, NT_MaSoCMND_NV) references NhanVien(NV_QuocTich, NV_MaSoCMND)
);

create table ChungChi(
    CC_MaChungChi serial primary key ,
    CC_QuocTich varchar(50),
    CC_MaSoCMND varchar(9),
    foreign key (CC_QuocTich, CC_MaSoCMND) references NguoiLaoDong(NLD_QuocTich, NLD_MaSoCMND)
);

create table BangHocVan(
    BHV_MaBangTotNghiep varchar(10) primary key ,
    BHV_Truong varchar(50) not null ,
    BHV_ChuyenNganh varchar(50) not null ,
    BHV_NamBatDau date,
    BHV_NamTotNghiep date,
    BHV_GPA decimal,
    BHV_CapHoc varchar(20),
    BHV_LoaiHinhDaoTao varchar(10),
    BHV_MaChungChi int,
    foreign key (BHV_MaChungChi) references ChungChi(CC_MaChungChi),
    check ( BHV_NamTotNghiep >= BHV_NamBatDau )
);

create table ChungChiNgoaiNgu(
    CCNN_MaBangNgoaiNgu varchar(10) primary key ,
    CCNN_NgonNgu varchar(20),
    CCNN_NgayHoanThanh date,
    CCNN_Diem decimal,
    CCNN_TrungTamCapBang varchar(50),
    CCNN_Chuan varchar(10),
    CCNN_NgayHetHan date,
    CCNN_MaChungChi int,
    foreign key (CCNN_MaChungChi) references ChungChi(CC_MaChungChi),
    check ( CCNN_NgayHetHan >= CCNN_NgayHoanThanh )
);

create table KhoaHocOnline(
    KHO_MaChungNhan varchar(10) primary key ,
    KHO_TrangWebDaoTao varchar(2000),
    KHO_TenKhoaHoc varchar(50),
    KHO_NgayHoanThanh date,
    KHO_XepLoai varchar(10),
    KHO_MaChungChi int,
    foreign key (KHO_MaChungChi) references ChungChi(CC_MaChungChi)
);

create table DuocNhanBoi(
    DNB_QuocTich varchar(50),
    DNB_MaSoCMND varchar(9),
    DNB_MaSoQuyetDinh int ,
    primary key (DNB_QuocTich, DNB_MaSoCMND, DNB_MaSoQuyetDinh),
    foreign key (DNB_QuocTich, DNB_MaSoCMND) references NhanVien(NV_QuocTich, NV_MaSoCMND),
    foreign key (DNB_MaSoQuyetDinh) references QuyetDinh(QD_MaSo)
);

create table ThamGiaPV(
    TGPV_QuocTich_NV varchar(50),
    TGPV_MaSoCMND_NV varchar(9),
    TGPV_MaDot int,
    TGPV_DiaDiem varchar(50),
    TGPV_NgayPV timestamp,
    TGPV_QuocTich_NguoiXinViec varchar(50),
    TGPV_MaSoCMND_NguoiXinViec varchar(9),
    primary key (TGPV_QuocTich_NV, TGPV_MaSoCMND_NV, TGPV_MaDot, TGPV_DiaDiem, TGPV_NgayPV, TGPV_QuocTich_NguoiXinViec, TGPV_MaSoCMND_NguoiXinViec),
    foreign key (TGPV_QuocTich_NV, TGPV_MaSoCMND_NV) references NhanVien(NV_QuocTich, NV_MaSoCMND),
    foreign key (TGPV_MaDot, TGPV_DiaDiem, TGPV_NgayPV, TGPV_QuocTich_NguoiXinViec, TGPV_MaSoCMND_NguoiXinViec) references
                      BuoiPhongVan(BPV_MaDot, BPV_DiaDiem, BPV_NgayPV, BPV_QuocTich, BPV_MaSoCMND)
);

create table ThamGiaTapHuan(
    TGTH_QuocTich varchar(50),
    TGTH_MaSoCMND varchar(9),
    TGTH_MaSoTapHuan int,
    TGTH_VaiTro varchar(50),
    primary key (TGTH_QuocTich, TGTH_MaSoCMND, TGTH_MaSoTapHuan),
    foreign key (TGTH_QuocTich, TGTH_MaSoCMND) references NhanVien(NV_QuocTich, NV_MaSoCMND),
    foreign key (TGTH_MaSoTapHuan) references TapHuan(TH_MaSo)
);

create table LamViecTren(
    LVT_QuocTich varchar(50),
    LVT_MaSoCMND varchar(9),
    LVT_MaSoDuAn int,
    primary key (LVT_QuocTich, LVT_MaSoCMND, LVT_MaSoDuAn),
    foreign key (LVT_QuocTich, LVT_MaSoCMND) references NhanVien(NV_QuocTich, NV_MaSoCMND),
    foreign key (LVT_MaSoDuAn) references DuAn(DA_MaSo)
);

create table ThoiGianLam(
    TGL_ThoiLuong interval hour,
    TGL_NgayTiepTuc date,
    TGL_QuocTich varchar(50),
    TGL_MaSoCMND varchar(9),
    TGL_MaSoDuAn int,
    primary key (TGL_ThoiLuong, TGL_NgayTiepTuc, TGL_QuocTich, TGL_MaSoCMND, TGL_MaSoDuAn),
    foreign key (TGL_QuocTich, TGL_MaSoCMND, TGL_MaSoDuAn) references LamViecTren(LVT_QuocTich, LVT_MaSoCMND, LVT_MaSoDuAn)
);

create table LamViecCho(
    LVC_QuocTich varchar(50),
    LVC_MaSoCMND varchar(9),
    LVC_MaHopDong int,
    LVC_MaSoPhongBan int,
    primary key (LVC_QuocTich, LVC_MaSoCMND, LVC_MaHopDong, LVC_MaSoPhongBan),
    foreign key (LVC_QuocTich, LVC_MaSoCMND) references NhanVien(NV_QuocTich, NV_MaSoCMND),
    foreign key (LVC_MaHopDong) references HopDong(HD_MaHopDong),
    foreign key (LVC_MaSoPhongBan) references PhongBan(PB_MaSo)
);


insert into QuyetDinh (QD_NgayRaQD, QD_LoaiQD)
values (to_date('1/1/2020', 'dd/mm/yyyy'), 'Khen thưởng'),
       (to_date('5/1/2020', 'dd/mm/yyyy'), 'Kỉ luật');

insert into BangCong (BC_GioVaoLamQuyDinh, BC_GioRaVeQuyDinh)
values (time '08:30:00', time '17:00:00'),
       (time '08:30:00', time '17:00:00');

insert into NgayLamViec (NLV_MaBangCong, NLV_Ngay, NLV_GioVaoLam, NLV_GioRaVe)
values (1, to_date('1/1/2020', 'dd/mm/yyyy'), time '9:00:00', time '16:00:00'),
       (1, to_date('2/1/2020', 'dd/mm/yyyy'), time '7:30:00', time '17:30:00'),
       (2, to_date('1/1/2020', 'dd/mm/yyyy'), time '9:00:00', time '16:00:00'),
       (2, to_date('2/1/2020', 'dd/mm/yyyy'), time '7:30:00', time '17:30:00');

insert into BoPhan (BP_Ten)
values ('Nghiên cứu phát triển'),
       ('Hành chính'),
       ('Kế toán');

insert into PhongBan (PB_Ten, PB_MaSoBoPhan)
values ('Phát triển sp', 1),
       ('Phát triển công nghệ', 1),
       ('Phát triển quy trình', 1);

insert into DuAn (DA_Ten, DA_TrangThai, DA_MaSoPhongBan)
values ('Dự án sx 1/1/2020', 'In progress', 1),
       ('Dự án sx 1/12/2020', 'On hold', 1);

insert into DoiTac (DT_TenDoiTac, DT_MaSoDuAn)
values ('ĐH Bách Khoa', 1);

insert into TapHuan (TH_TenCTYDoiTac, TH_DiaDiem, TH_ThoiGian, TH_ChuDe, TH_MaSoPhongBan)
values ('Vinamilk', 'Dĩ An, Binh Duong', to_date('1/11/2020', 'dd/mm/yyyy'), 'Qui trình sx', 1),
       ('HTX vận tải bx miền Đông', 'Mahattan, New York, USA', to_date('29/11/2020', 'dd/mm/yyyy'), 'Tâm lí tuổi dậy thì', 1);

insert into CongViec (CV_TenCongViec, CV_MoTa, CV_MaSoPhongBan)
values ('Phát triển sp', 'Tạo các sp mới có tính năng mới', 1),
       ('Phát triển công nghệ sx', 'Tạo công nghệ mới phục vụ sx', 2),
       ('Thiết kế sp', 'Tạo các sp mới có thiết kế nổi bật hơn', 1);

insert into HopDong (HD_Ten, HD_TrangThai, HD_LoaiHopDong, HD_NgayBatDau, HD_NgayKetThuc, HD_MaCongViec)
values ('HĐLĐMV1', 'Active', 'mùa vụ', to_date('1/6/2020', 'dd/mm/yyyy'), to_date('1/6/2021', 'dd/mm/yyyy'), 1),
       ('HĐLĐTH2', 'Expired', 'có thời hạn', to_date('1/1/2015', 'dd/mm/yyyy'), to_date('1/1/2020', 'dd/mm/yyyy'), 2),
       ('HĐLĐTH3', 'Terminated', 'có thời hạn', to_date('10/3/2018', 'dd/mm/yyyy'), to_date('10/3/2023', 'dd/mm/yyyy'), 3),
       ('HĐLĐMV4', 'Active', 'có thời hạn', to_date('1/6/2018', 'dd/mm/yyyy'), to_date('1/6/2020', 'dd/mm/yyyy'), 1),
       ('HĐLĐMV5', 'Active', 'không thời hạn', to_date('1/6/2020', 'dd/mm/yyyy'), to_date('1/6/2021', 'dd/mm/yyyy'), 1);

insert into DotTuyenDung (DTD_NgayBatDau, DTD_NgayKetThuc, DTD_MaCongViec, DTD_SoLuongCanTuyen)
values (to_date('2/5/2021', 'dd/mm/yyyy'), to_date('2/6/2021', 'dd/mm/yyyy'), 1, 1),
       (to_date('1/11/2020', 'dd/mm/yyyy'), to_date('1/12/2020', 'dd/mm/yyyy'), 2, 3);

insert into NguoiLaoDong (NLD_QuocTich, NLD_MaSoCMND, NLD_SDT, NLD_Email, NLD_DiaChi, NLD_GioiTinh, NLD_NgaySinh, NLD_Ho, NLD_TenDem, NLD_Ten)
values ('Viet Nam', '261572930', '0815678495', 'nhanh@gmail.com','14 Lý Thường Kiệt, Q.10, TP.HCM', 'F', to_date('12/3/1990', 'dd/mm/yyyy'), 'Nguyễn', 'Hồng', 'Ánh'),
       ('Viet Nam', '261456738', '0127567893', 'tqbao@gmail.com','178 Tô Hiến Thành, Q.10, TP.HCM', 'M', to_date('5/6/1989', 'dd/mm/yyyy'), 'Trần', 'Quốc', 'Bảo'),
       ('America', '261456738', '0912301242', 'kfjohn@gmail.com','475 Nguyễn Huệ, Q.5, TP.HCM', 'M', to_date('7/9/1994', 'dd/mm/yyyy'), 'Kennedy', 'F', 'John'),
       ('Viet Nam', '261746589', '0912390091', 'lmdung@gmail.com','57 Lê Lợi, Q.1, TP.HCM', 'M', to_date('14/5/1985', 'dd/mm/yyyy'), 'Lê', 'Mạnh', 'Dũng');

insert into NhanVien (NV_QuocTich, NV_MaSoCMND, NV_MaNV, NV_QuocTich_NGS, NV_MaSoCMND_NGS, NV_MaSoBangCong)
values ('Viet Nam', '261572930', '10001', null, null, 1),
       ('Viet Nam', '261456738', '20001', 'Viet Nam', '261572930', 2);

insert into NguoiXinViec (NXV_QuocTich, NXV_MaSoCMND)
values ('America', '261456738'),
       ('Viet Nam', '261746589');

insert into BuoiPhongVan (BPV_MaDot, BPV_DiaDiem, BPV_NgayPV, BPV_QuocTich, BPV_MaSoCMND, BPV_KetQuaPV)
values (1, '301A', to_date('12/5/2020', 'dd/mm/yyyy'), 'Viet Nam', '261746589', True),
       (2, '205C', to_date('10/11/2020', 'dd/mm/yyyy'), 'America', '261456738', False);

insert into Luong (L_QuocTich, L_MaSoCMND, L_LuongCoBan, L_HeSoLuong, L_HeSoPhuCap, L_SoNgayNghiKhongPhep, L_ChiPhiThueVaBaoHiem)
values ('Viet Nam', '261572930', 1575::money, 6.2, 0.1, 1, 315),
       ('Viet Nam', '261456738', 1665::money, 6.56, 0.1, 0, 333),
       ('USA', '100000000', 1500::money, 6.56, 0.1, 0, 333);

insert into NguoiThan (NT_QuocTich_NV, NT_MaSoCMND_NV, NT_Ten, NT_MoiQuanHe)
values ('Viet Nam', '261572930', 'Tô Trung Lưu', 'Cha'),
       ('Viet Nam', '261456738', 'Trần Ngọc Thanh', 'Mẹ');

insert into ChungChi (CC_QuocTich, CC_MaSoCMND)
values ('Viet Nam', '261572930'),
       ('Viet Nam', '261572930'),
       ('Viet Nam', '261456738'),
       ('Viet Nam', '261456738'),
       ('America', '261456738');

insert into BangHocVan (BHV_MaBangTotNghiep, BHV_Truong, BHV_ChuyenNganh, BHV_NamBatDau, BHV_NamTotNghiep, BHV_GPA, BHV_CapHoc, BHV_LoaiHinhDaoTao,
                        BHV_MaChungChi)
values ('129F213BK0', 'ĐH Bách Khoa', 'Khoa học máy tính', date '1/1/2008', date '1/1/2013', 8.67, 'Đại học', 'Chính quy', 1),
       ('939KHTN210', 'ĐH Khoa học tự nhiên', 'Khoa học máy tính', date '1/1/2007', date '1/1/2012', 8.47, 'Đại học', 'Chính quy', 3);

insert into ChungChiNgoaiNgu (CCNN_MaBangNgoaiNgu, CCNN_NgonNgu, CCNN_NgayHoanThanh, CCNN_Diem, CCNN_TrungTamCapBang, CCNN_Chuan, CCNN_NgayHetHan,
                              CCNN_MaChungChi)
values ('IELTS00001', 'Anh', to_date('14/5/2020', 'dd/mm/yyyy'), 7.0, 'IIG', 'IELTS', to_date('14/5/2022', 'dd/mm/yyyy'), 2),
       ('VN129034', 'Việt', to_date('18/9/2017', 'dd/mm/yyyy'), 27, 'BGD', null, to_date('18/9/2019', 'dd/mm/yyyy'), 5);

insert into KhoaHocOnline (KHO_MaChungNhan, KHO_TrangWebDaoTao, KHO_TenKhoaHoc, KHO_NgayHoanThanh, KHO_XepLoai, KHO_MaChungChi)
values ('CS801/12', 'coursera.org', 'Xây dựng machine learning web app với Python', to_date('8/8/2020', 'dd/mm/yyyy'), 'Xuất sắc', 4);

insert into DuocNhanBoi (DNB_QuocTich, DNB_MaSoCMND, DNB_MaSoQuyetDinh)
values ('Viet Nam', '261572930', 1),
       ('Viet Nam', '261456738', 2);

insert into ThamGiaPV (TGPV_QuocTich_NV, TGPV_MaSoCMND_NV, TGPV_MaDot, TGPV_DiaDiem, TGPV_NgayPV, TGPV_QuocTich_NguoiXinViec, TGPV_MaSoCMND_NguoiXinViec)
values ('Viet Nam', '261572930', 1, '301A', to_date('12/5/2020', 'dd/mm/yyyy'), 'Viet Nam', '261746589'),
       ('Viet Nam', '261572930', 2, '205C', to_date('10/11/2020', 'dd/mm/yyyy'), 'America', '261456738');

insert into ThamGiaTapHuan (TGTH_QuocTich, TGTH_MaSoCMND, TGTH_MaSoTapHuan, TGTH_VaiTro)
values ('Viet Nam', '261572930', 1, 'Người tổ chức'),
       ('Viet Nam', '261456738', 2, 'Tutor');

insert into LamViecTren (LVT_QuocTich, LVT_MaSoCMND, LVT_MaSoDuAn)
values ('Viet Nam', '261572930', 1),
       ('Viet Nam', '261456738', 2);

insert into ThoiGianLam (TGL_ThoiLuong, TGL_NgayTiepTuc, TGL_QuocTich, TGL_MaSoCMND, TGL_MaSoDuAn)
values ('45 hours', to_date('30/6/2002', 'dd/mm/yyyy'), 'Viet Nam', '261572930', 1),
       ('67 hours', to_date('24/8/2015', 'dd/mm/yyyy'), 'Viet Nam', '261456738', 2);

insert into LamViecCho (LVC_QuocTich, LVC_MaSoCMND, LVC_MaHopDong, LVC_MaSoPhongBan)
values ('Viet Nam', '261572930', 1, 1),
       ('Viet Nam', '261456738', 2, 2),
       ('Viet Nam', '100000001',  3, 2);

--########---
--create type TT_HopDong as enum ('Expired', 'Terminated', 'Active');
--create table HopDong(
    --MaHopDong serial primary key ,
    --Ten varchar(50) ,
    --TrangThai TT_HopDong,
    --LoaiHopDong varchar(50),
    --NgayBatDau timestamp ,
    --NgayKetThuc timestamp ,
    --MaCongViec int ,
    --foreign key (MaCongViec) references CongViec(MaCongViec) );
--########--
SELECT * FROM BangCong;
insert into BangCong
values (3,time '13:30:00', time '22:00:00'),(4,time '13:30:00', time '22:00:00'),(5,time '6:30:00', time '12:00:00');
insert into NhanVien (NV_QuocTich, NV_MaSoCMND, NV_MaNV, NV_QuocTich_NGS, NV_MaSoCMND_NGS, NV_MaSoBangCong)
values ('America', '261456738', '30001', 'Viet Nam', '261746589', 3),
       ('Viet Nam', '261746589', '30002',null,null , 4);
insert into LamViecCho (LVC_QuocTich, LVC_MaSoCMND, LVC_MaHopDong, LVC_MaSoPhongBan)
values ('America', '261456738', 3, 3),('Viet Nam', '261746589', 7, 1);

--Cau1---------------------------------------------------------------------------------------------
SELECT NV_QuocTich, NV_MaSoCMND, NV_MaNV, HD_TrangThai
FROM (NhanVien join LamViecCho on NhanVien.NV_QuocTich = LamViecCho.LVC_QuocTich
                                    and NhanVien.NV_MaSoCMND = LamViecCho.LVC_MaSoCMND) NVLVC
    join HopDong on NVLVC.LVC_MaHopDong= HopDong.HD_MaHopDong
WHERE HD_TrangThai = 'Terminated';
----------------------------------------------------------------------------------------------
SELECT PB_Ten, LVC_QuocTich, LVC_MaSoCMND
FROM PhongBan join LamViecCho on PhongBan.PB_MaSo = LamViecCho.LVC_MaSoPhongBan
WHERE LVC_MaHopDong IN (SELECT HD_MaHopDong FROM HopDong WHERE HD_TrangThai = 'Active')
ORDER BY PB_Ten;

insert into LamViecCho values ('USA', '100000000', 8, 1);
SELECT * FROM PhongBan;
SELECT * FROM LamViecCho;
-----------------------------------------------------------------------------------------------
SELECT CV_TenCongViec, count(*)
FROM CongViec join HopDong on CongViec.CV_MaCongViec = HopDong.HD_MaCongViec
WHERE HD_TrangThai = 'Active'
GROUP BY CV_TenCongViec
HAVING count(*) > 2;

SELECT * FROM CongViec;
SELECT * FROM HopDong;
----------------------------------------------------------------------------------------------
SELECT PB_Ten, MAX(age(HD_NgayKetThuc,HD_NgayBatDau))
FROM (PhongBan join LamViecCho on PhongBan.PB_MaSo = LamViecCho.LVC_MaSoPhongBan) PL
        join HopDong on PL.LVC_MaHopDong = HopDong.HD_MaHopDong
WHERE HD_TrangThai = 'Expired'
GROUP BY PB_Ten;

SELECT * FROM (PhongBan join LamViecCho on PB_MaSo = LVC_MaSoPhongBan) join HopDong on HD_MaHopDong = LamViecCho.LVC_MaHopDong;
SELECT * FROM NhanVien;
--Cau2------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION p_view_working_time(
    day interval
)
RETURNS TABLE (QuocTich varchar(50),MaSoCMND varchar(9),NgayBatDau timestamp, NgayKetKhuc timestamp, workingday interval)
as $$
begin
    RETURN QUERY
    SELECT NV_QuocTich, NV_MaSoCMND, HD_NgayBatDau, HD_NgayKetThuc, age(current_date,HD_NgayBatDau)
    FROM (NhanVien join LamViecCho on NhanVien.NV_QuocTich = LamViecCho.LVC_QuocTich and NhanVien.NV_MaSoCMND = LamViecCho.LVC_MaSoCMND)
                join HopDong on LVC_MaHopDong = HopDong.HD_MaHopDong
    WHERE HD_TrangThai = 'Active' AND (current_date - HD_NgayBatDau) >  day
    ORDER BY  HD_NgayBatDau ASC ;
end; $$ language plpgsql;

DROP FUNCTION p_view_working_time;

SELECT NV_MaSoCMND, HD_MaHopDong, HD_NgayBatDau, HD_NgayKetThuc, HD_TrangThai
FROM (NhanVien join LamViecCho LVC on NhanVien.NV_QuocTich = LVC.LVC_QuocTich and NhanVien.NV_MaSoCMND = LVC.LVC_MaSoCMND)
                join HopDong on LVC_MaHopDong = HopDong.HD_MaHopDong;

SELECT * FROM p_view_working_time(interval '1 year');
----------------------------------------------------------------------------------------------
create or replace procedure p_insert_HopDong  (
    Ten varchar(50) ,
    TrangThai TT_HopDong,
    LoaiHopDong varchar(50),
    NgayBatDau timestamp ,
    NgayKetThuc timestamp ,
    MaCongViec int
) language plpgsql as $$
begin
    if NgayBatDau is null then
        RAISE NOTICE  'Phải có ngày bắt đầu';
        NgayBatDau = current_date;
    end if;
    if NgayKetThuc is null AND LoaiHopDong <> 'không thời hạn' then
        RAISE NOTICE  'Phải có ngày kết thúc';
        NgayKetThuc := NgayBatDau + interval '1 year';
    end if;
    if NgayBatDau > NgayKetThuc OR NgayKetThuc is null then
        RAISE NOTICE  'Ngày kết thúc không hợp lệ';
        NgayKetThuc := NgayBatDau + interval '1 year';
    end if;
    if not exists(SELECT * FROM CongViec WHERE CongViec.CV_MaCongViec = MaCongViec) then
        RAISE NOTICE  'Không tồn tại công việc này';
        MaCongViec := 1;
    end if;
    INSERT INTO HopDong (HD_Ten, HD_TrangThai, HD_LoaiHopDong, HD_NgayBatDau, HD_NgayKetThuc, HD_MaCongViec)
    values (Ten,TrangThai,LoaiHopDong,NgayBatDau,NgayKetThuc,MaCongViec);
end;$$;

SELECT * FROM HopDong;
CALL p_insert_HopDong('HĐLĐMV10', 'Active', 'có thời hạn',
    null, to_date('1/6/2022', 'dd/mm/yyyy'), 3);
CALL p_insert_HopDong('HĐLĐMV11', 'Active', 'có thời hạn',
    to_date('1/6/2020', 'dd/mm/yyyy'), null, 2);
CALL p_insert_HopDong('HĐLĐMV12', 'Active', 'có thời hạn',
    to_date('1/1/2019', 'dd/mm/yyyy'), to_date('1/8/2018', 'dd/mm/yyyy'), 1);
CALL p_insert_HopDong('HĐLĐMV13', 'Active', 'có thời hạn',
    to_date('1/1/2019', 'dd/mm/yyyy'), to_date('1/8/2018', 'dd/mm/yyyy'), 100);
--Cau3---------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_HopDong_InsertTrigger() RETURNS TRIGGER AS $$
BEGIN
    if new.HD_NgayKetThuc is null AND new.HD_LoaiHopDong <> 'không thời hạn' then
        RAISE EXCEPTION  'Phải có ngày kết thúc';
    end if;

    if new.HD_NgayBatDau > new.HD_NgayKetThuc OR new.HD_NgayKetThuc is null then
        RAISE EXCEPTION  'Ngày kết thúc không hợp lệ';
    end if;

    if not exists(SELECT * FROM CongViec WHERE CongViec.CV_MaCongViec = new.HD_MaCongViec) then
        RAISE EXCEPTION  'Không tồn tại công việc này';
    end if;

    if new.HD_NgayBatDau::date - integer'30' > current_date then
        insert into DotTuyenDung (DTD_NgayBatDau, DTD_NgayKetThuc, DTD_MaCongViec, DTD_SoLuongCanTuyen)
        values (current_date, new.HD_NgayBatDau - interval '30 day', new.HD_MaCongViec, 1);
    end if;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER HopDong_InsertTrigger
    BEFORE INSERT ON HopDong
    FOR EACH ROW
    EXECUTE PROCEDURE f_HopDong_InsertTrigger();

DROP TRIGGER HopDong_InsertTrigger ON HopDong;

SELECT * FROM HopDong;
SELECT * FROM DotTuyenDung;
insert into HopDong (HD_Ten, HD_TrangThai, HD_LoaiHopDong, HD_NgayBatDau, HD_NgayKetThuc, HD_MaCongViec)
values ('HĐLĐMV10', 'Active', 'có thời hạn', to_date('1/2/2020', 'dd/mm/yyyy'), null, 1);

insert into HopDong (HD_Ten, HD_TrangThai, HD_LoaiHopDong, HD_NgayBatDau, HD_NgayKetThuc, HD_MaCongViec)
values ('HĐLĐMV11', 'Active', 'có thời hạn', to_date('1/8/2020', 'dd/mm/yyyy'), to_date('1/5/2017', 'dd/mm/yyyy'), 1);

insert into HopDong (HD_Ten, HD_TrangThai, HD_LoaiHopDong, HD_NgayBatDau, HD_NgayKetThuc, HD_MaCongViec)
values ('HĐLĐMV12', 'Active', 'có thời hạn', to_date('1/1/2020', 'dd/mm/yyyy'), to_date('1/10/2020', 'dd/mm/yyyy'), 100);

insert into HopDong (HD_Ten, HD_TrangThai, HD_LoaiHopDong, HD_NgayBatDau, HD_NgayKetThuc, HD_MaCongViec)
values ('HĐLĐMV14'::varchar, 'Expired'::TT_HopDong, 'có thời hạn'::varchar, '10/1/2021'::timestamp, '1/10/2025'::timestamp, 3::integer);
-----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_HopDong_UpdateTrigger() RETURNS TRIGGER AS $$
BEGIN
    if new.HD_NgayKetThuc < new.HD_NgayBatDau or new.HD_NgayKetThuc < old.HD_NgayBatDau then
        RAISE EXCEPTION 'Ngày kết thúc không hợp lệ';
    end if;

    if old.HD_TrangThai = 'Active' and new.HD_TrangThai <> 'Active' then
        UPDATE Luong
        SET L_LuongCoBan = 0, L_HeSoLuong = 0, L_HeSoPhuCap = 0
        WHERE concat(Luong.L_QuocTich, Luong.L_MaSoCMND) in (SELECT concat(NV_QuocTich,NV_MaSoCMND)
                                                            FROM (NhanVien join LamViecCho  on NV_QuocTich = LVC_QuocTich
                                                                    and NV_MaSoCMND = LVC_MaSoCMND)
                                                            WHERE LVC_MaHopDong = old.HD_MaHopDong);
    end if;

    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER HopDong_UpdateTrigger
    AFTER UPDATE ON HopDong
    FOR EACH ROW
    EXECUTE PROCEDURE f_HopDong_UpdateTrigger();

DROP TRIGGER HopDong_UpdateTrigger ON HopDong;

SELECT * FROM Luong;
SELECT * FROM NhanVien;
SELECT * FROM HopDong;
SELECT * FROM LamViecCho;
insert into NhanVien (NV_QuocTich, NV_MaSoCMND, NV_MaNV, NV_QuocTich_NGS, NV_MaSoCMND_NGS, NV_MaSoBangCong)
values ('Viet Nam', '100000000', '20001', 'Viet Nam', '261572930', 2);
insert into Luong (L_QuocTich, L_MaSoCMND, L_LuongCoBan, L_HeSoLuong, L_HeSoPhuCap, L_SoNgayNghiKhongPhep, L_ChiPhiThueVaBaoHiem)
values ('Viet Nam', '261746589', 1550::money, 7, 0.5, 0, 350);
insert into HopDong values (9, 'HĐLĐMV9', 'Active', 'có thời hạn', to_date('1/6/2017', 'dd/mm/yyyy'), to_date('1/6/2021', 'dd/mm/yyyy'), null);

DELETE  FROM Luong WHERE L_LuongCoBan = 0::money;
UPDATE HopDong
SET HD_TrangThai = 'Terminated'
WHERE HD_MaHopDong = 7;

UPDATE HopDong
SET HD_NgayKetThuc = '1/1/1999'
WHERE HD_MaHopDong = 3;

UPDATE HopDong
SET HD_NgayKetThuc = '1/1/2018', HD_NgayBatDau = '1/1/2022'
WHERE HD_MaHopDong = 3;

-----------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_HopDong_DeleteTrigger() RETURNS TRIGGER AS $$
BEGIN
    if old.HD_TrangThai = 'Active' then
        RAISE EXCEPTION 'Không thể xóa hợp đồng đang có hiệu lực';
    end if;

    DELETE FROM LamViecCho
    WHERE LamViecCho.LVC_MaHopDong = old.HD_MaHopDong;
    RETURN OLD;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER HopDong_DeleteTrigger
    BEFORE DELETE ON HopDong
    FOR EACH ROW
    EXECUTE PROCEDURE f_HopDong_DeleteTrigger();


DROP TRIGGER HopDong_DeleteTrigger ON HopDong;

SELECT * FROM HopDong;
SELECT * FROM LamViecCho;
insert into HopDong values (5, 'HĐLĐMV4', 'Active', 'không thời hạn', to_date('1/6/2020', 'dd/mm/yyyy'), to_date('1/6/2021', 'dd/mm/yyyy'), 1);
insert into LamViecCho values ('USA', '100000000', 20, 1);
insert into HopDong values (10, 'HĐLĐMV4', 'Expired', 'có thời hạn', to_date('1/6/2018', 'dd/mm/yyyy'), to_date('1/6/2020', 'dd/mm/yyyy'), 1);
insert into LamViecCho values ('Viet Nam', '100000001', 4, 1);

DELETE FROM HopDong WHERE HD_MaHopDong = 9;

DELETE FROM HopDong WHERE HD_MaHopDong = 4;
--Cau4---------------------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION f_quality_of_contract(id int, quality int , amount money)
RETURNS Table (MaHopDong int, Ten varchar(50) , TrangThai TT_HopDong, LoaiHopDong varchar(50),
            NgayBatDau timestamp , NgayKetThuc timestamp , MaCongViec int) AS $$
DECLARE Count int;
DECLARE counter record;
DECLARE sum money;
begin
    if exists(SELECT * FROM PhongBan WHERE PB_MaSo = id) then
        if quality <= 0 then
            RAISE NOTICE 'Số lượng phải lớn hơn 0';
            quality := 1;
        end if;
        SELECT count(*) INTO Count
        FROM (PhongBan join LamViecCho on PhongBan.PB_MaSo = LamViecCho.LVC_MaSoPhongBan) PL
                join NhanVien on PL.LVC_QuocTich = NhanVien.NV_QuocTich AND PL.LVC_MaSoCMND = NhanVien.NV_MaSoCMND
        WHERE PB_MaSo = id
        GROUP BY PB_MaSo;
        sum := 0::money;
        for counter in SELECT L_LuongCoBan FROM Luong WHERE concat(L_QuocTich, L_MaSoCMND)
                        in (SELECT concat(LVC_QuocTich,LVC_MaSoCMND)
                        FROM PhongBan join LamViecCho on PB_MaSo = LVC_MaSoPhongBan WHERE PB_MaSo = 1)
            loop
                sum := sum + counter.L_LuongCoBan;
            end loop;

        if count >= quality and sum >= amount then
            RETURN QUERY
            SELECT HD_MaHopDong,HD_Ten ,HD_TrangThai, HD_LoaiHopDong, HD_NgayKetThuc, HD_NgayKetThuc, HD_MaCongViec
            FROM (PhongBan join LamViecCho on PhongBan.PB_MaSo = LamViecCho.LVC_MaSoPhongBan) PBLVC
                    join HopDong on PBLVC.LVC_MaHopDong = HopDong.HD_MaHopDong
            WHERE PB_MaSo = id;
        else
            RAISE NOTICE 'Không tìm thấy phòng ban phù hợp với yêu cầu';
        end if;
    else
        RAISE NOTICE 'Không tìm thấy phòng ban';
    end if;
end; $$ language plpgsql;

DROP FUNCTION f_quality_of_contract;

SELECT * FROM f_quality_of_contract(100,1,money(0));

SELECT * FROM f_quality_of_contract(1,100,money(0));

SELECT * FROM f_quality_of_contract(1,1,money(10000));

SELECT * FROM f_quality_of_contract(1,0,money(0));

SELECT * FROM f_quality_of_contract(1,1,money(2000));


