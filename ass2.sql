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

drop type if exists TT_DuAn;
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

drop type if exists TT_HopDong;
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
       ('Viet Nam', '261456738', '20001', 'Viet Nam', '261572930', 2),
       ('USA', '100000000', '20001', 'Viet Nam', '261572930', 2),
       ('Viet Nam', '100000001', '20002', 'Viet Nam', '261572930', 1);

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
