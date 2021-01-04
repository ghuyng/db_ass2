-- 1a1
 select
	*
from
	((banghocvan b
join chungchi c on
	b.bhv_machungchi = c.cc_machungchi) as bc
join nguoilaodong n2 on
	n2.nld_quoctich = bc.cc_quoctich
	and n2.nld_masocmnd = bc.cc_masocmnd)
where
	n2.nld_quoctich = 'Viet Nam'
order by
	n2.nld_ngaysinh ;
--1a2
 select
	*
from
	((khoahoconline k
join chungchi c on
	k.kho_machungchi = c.cc_machungchi) as kc
join nguoilaodong n2 on
	n2.nld_quoctich = kc.cc_quoctich
	and n2.nld_masocmnd = kc.cc_masocmnd)
where
	extract (year
from
	kc.kho_ngayhoanthanh) < 2021
order by
	kho_ngayhoanthanh ;
--1b1
 select
	nld_ngaysinh,
	truong,
	nld_ho,
	nld_tendem,
	nld_ten,
	bhv_gpa,
	bhv_nambatdau
from
	(((
	select
		bhv_truong as truong
	from
		banghocvan b
	group by
		bhv_truong
	having
		avg(bhv_gpa) > 5.0) as truong_temp
join banghocvan b2 on
	b2.bhv_truong = truong_temp.truong)) as truong_co_trung_bing_gpa_tu_5_tro_len
join chungchi c on
	truong_co_trung_bing_gpa_tu_5_tro_len.bhv_machungchi = c.cc_machungchi
join nguoilaodong n on
	c.cc_masocmnd = n.nld_masocmnd
	and c.cc_quoctich = n.nld_quoctich
where
	extract(year
from
	n.nld_ngaysinh) < 2000
order by
	bhv_namtotnghiep ;
--1b2
 select
	avg(extract (year from age(nld_ngaysinh))),
	bpv_ketquapv
from
	( (
	select
		*
	from
		(((buoiphongvan b
	join thamgiapv t2 on
		b.bpv_quoctich = t2.tgpv_quoctich_nguoixinviec
		and b.bpv_masocmnd = t2.tgpv_masocmnd_nguoixinviec)
	join nhanvien n2 on
		tgpv_quoctich_nv = n2.nv_quoctich
		and tgpv_masocmnd_nv = n2.nv_masocmnd)
	join nguoilaodong on
		nv_quoctich = nld_quoctich
		and nv_masocmnd = nld_masocmnd)) as subq natural
join thamgiapv )
where
	nv_quoctich = 'Viet Nam'
group by
	bpv_ketquapv
having
	min(extract (year from nld_ngaysinh)) > 20 ;
--2.1
 create or replace
function liet_ke_dot_tuyen_dung_co_so_luong_nhieu_hon (amount int) returns table(
--
 DTD_MaDot int,
DTD_NgayBatDau date,
DTD_NgayKetThuc date,
DTD_MaCongViec int,
DTD_SoLuongCanTuyen int,
CV_MaCongViec int,
CV_TenCongViec varchar(50),
CV_MoTa varchar(200),
CV_MaSoPhongBan int
--
) language plpgsql as $$ begin
--
 if amount < 0 then raise notice 'So luong nhap vao la am.';
else return query
select
	*
from
	dottuyendung d2
join congviec c2 on
	d2.dtd_macongviec = c2.cv_macongviec
where
	d2.dtd_soluongcantuyen > amount;
end if;
end;

$$;

select
	liet_ke_dot_tuyen_dung_co_so_luong_nhieu_hon(0);
--2.2
 create or replace
procedure duoi_viec_theo_quoc_tich (nationality varchar(50)) language plpgsql as $$ begin if nationality in (
select
	nv_quoctich
from
	( (nhanvien n
join lamvieccho l2 on
	n.nv_quoctich = l2.lvc_quoctich
	and n.nv_masocmnd = l2.lvc_masocmnd)
join hopdong h2 on
	lvc_mahopdong = h2.hd_mahopdong)
where
	h2.hd_trangthai = 'Active') then
update
	hopdong
set
	hd_trangthai = 'Terminated'
from
	lamvieccho l3
where
	l3.lvc_quoctich = nationality
	and l3.lvc_mahopdong = hopdong.hd_mahopdong
	and hopdong.hd_trangthai = 'Active';
else raise notice 'Khong co ai hien dang lam viec co quoc tich nay.';
end if ;
end;

$$;
--call duoi_viec_theo_quoc_tich('Lunarian');
-- 3. insert trigger
 create or replace
function dan_trigger_fn_insert_nguoilaodong () returns trigger language plpgsql as $$
--
 begin if extract(year
from
age(NEW.nld_ngaysinh)) < 16 then raise notice 'Nguoi lao dong con qua nho tuoi.' ;

return null;
end if;

return new;
end;

$$;

drop trigger if exists dan_trigger_insert_nguoilaodong on
nguoilaodong;

create trigger dan_trigger_insert_nguoilaodong before
insert
	on
	nguoilaodong for each row execute function dan_trigger_fn_insert_nguoilaodong();
-- 3. update trigger
 create or replace
function dan_trigger_fn_update_nguoilaodong() returns trigger language plpgsql as $$ begin
update
	nhanvien
set
	nhanvien.NV_MaSoCMND = new.nld_masocmnd
where
	nhanvien.NV_MaSoCMND = old.nld_masocmnd;

update
	nhanvien
set
	nhanvien.NV_QuocTich = new.nld_quoctich
where
	nhanvien.NV_QuocTich = old.nld_quoctich;

update
	nguoixinviec
set
	nguoixinviec.NXV_MaSoCMND = new.nld_masocmnd
where
	nguoixinviec.NXV_MaSoCMND = old.nld_masocmnd;

update
	nguoixinviec
set
	nguoixinviec.NXV_QuocTich = new.nld_quoctich
where
	nguoixinviec.NXV_QuocTich = old.nld_quoctich;

update
	buoiphongvan
set
	buoiphongvan.BPV_MaSoCMND = new.nld_masocmnd
where
	buoiphongvan.BPV_MaSoCMND = old.nld_masocmnd;

update
	buoiphongvan
set
	buoiphongvan.BPV_QuocTich = new.nld_quoctich
where
	buoiphongvan.BPV_QuocTich = old.nld_quoctich;

update
	luong
set
	luong.L_MaSoCMND = new.nld_masocmnd
where
	luong.L_MaSoCMND = old.nld_masocmnd;

update
	luong
set
	luong.L_QuocTich = new.nld_quoctich
where
	luong.L_QuocTich = old.nld_quoctich;

update
	nguoithan
set
	nguoithan.NT_MaSoCMND_NV = new.nld_masocmnd
where
	nguoithan.NT_MaSoCMND_NV = old.nld_masocmnd;

update
	nguoithan
set
	nguoithan.NT_QuocTich_NV = new.nld_quoctich
where
	nguoithan.NT_QuocTich_NV = old.nld_quoctich;

update
	chungchi
set
	chungchi.CC_MaSoCMND = new.nld_masocmnd
where
	chungchi.CC_MaSoCMND = old.nld_masocmnd;

update
	chungchi
set
	chungchi.CC_QuocTich = new.nld_quoctich
where
	chungchi.CC_QuocTich = old.nld_quoctich;

update
	duocnhanboi
set
	duocnhanboi.DNB_MaSoCMND = new.nld_masocmnd
where
	duocnhanboi.DNB_MaSoCMND = old.nld_masocmnd;

update
	duocnhanboi
set
	duocnhanboi.DNB_QuocTich = new.nld_quoctich
where
	duocnhanboi.DNB_QuocTich = old.nld_quoctich;

update
	thamgiaphongvan
set
	thamgiaphongvan.TGPV_MaSoCMND_NV = new.nld_masocmnd
where
	thamgiaphongvan.TGPV_MaSoCMND_NV = old.nld_masocmnd;

update
	thamgiaphongvan
set
	thamgiaphongvan.TGPV_QuocTich_NV = new.nld_quoctich
where
	thamgiaphongvan.TGPV_QuocTich_NV = old.nld_quoctich;

update
	thamgiaphongvan
set
	thamgiaphongvan.TGPV_MaSoCMND_NguoiXinViec = new.nld_masocmnd
where
	thamgiaphongvan.TGPV_MaSoCMND_NguoiXinViec = old.nld_masocmnd;

update
	thamgiaphongvan
set
	thamgiaphongvan.TGPV_QuocTich_NguoiXinViec = new.nld_quoctich
where
	thamgiaphongvan.TGPV_QuocTich_NguoiXinViec = old.nld_quoctich;

update
	thamgiataphuan
set
	thamgiataphuan.TGTH_MaSoCMND = new.nld_masocmnd
where
	thamgiataphuan.TGTH_MaSoCMND = old.nld_masocmnd;

update
	thamgiataphuan
set
	thamgiataphuan.TGTH_QuocTich = new.nld_quoctich
where
	thamgiataphuan.TGTH_QuocTich = old.nld_quoctich;

update
	lamviectren
set
	lamviectren.LVT_MaSoCMND = new.nld_masocmnd
where
	lamviectren.LVT_MaSoCMND = old.nld_masocmnd;

update
	lamviectren
set
	lamviectren.LVT_QuocTich = new.nld_quoctich
where
	lamviectren.LVT_QuocTich = old.nld_quoctich;

update
	thoigianlam
set
	thoigianlam.TGL_MaSoCMND = new.nld_masocmnd
where
	thoigianlam.TGL_MaSoCMND = old.nld_masocmnd;

update
	thoigianlam
set
	thoigianlam.TGL_QuocTich = new.nld_quoctich
where
	thoigianlam.TGL_QuocTich = old.nld_quoctich;

update
	lamviecho
set
	lamviecho.LVC_MaSoCMND = new.nld_masocmnd
where
	lamviecho.LVC_MaSoCMND = old.nld_masocmnd;

update
	lamviecho
set
	lamviecho.LVC_QuocTich = new.nld_quoctich
where
	lamviecho.LVC_QuocTich = old.nld_quoctich;
end;

$$;

drop trigger if exists dan_trigger_update_nguoilaodong on
nguoilaodong;

create trigger dan_trigger_update_nguoilaodong after
update
	on
	nguoilaodong for each row execute function dan_trigger_fn_update_nguoilaodong();

-- 3. delete trigger

create or replace
view lam_cong_viec as
select
	*
from
	(lamvieccho l
join hopdong h2 on
	l.lvc_mahopdong = h2.hd_mahopdong
join congviec c on
	c.cv_macongviec = h2.hd_macongviec
join nguoilaodong n on
	n.nld_quoctich = l.lvc_quoctich
	and n.nld_masocmnd = l.lvc_masocmnd);

create or replace
function dan_trigger_fn_delete_lam_cong_viec () returns trigger language plpgsql as $$ begin
--
 if old.cv_tencongviec = 'Quản lý' then
--
 raise notice 'Nguoi lao dong hien dang la quan ly.';

return null;
else
delete
from
	lam_cong_viec n2
where
	n2.nld_masocmnd = old.nld_masocmnd
	and n2.nld_quoctich = old.nld_quoctich;
end if;

return old;
end;

$$;

drop trigger if exists dan_trigger_delete_lam_cong_viec on
lam_cong_viec;

create trigger dan_trigger_delete_lam_cong_viec instead of
delete
	on
	lam_cong_viec for each row execute function dan_trigger_fn_delete_lam_cong_viec();


-- 4.
--create or replace function tong_thoi_gian_di_thieu_theo_thang(department int) return 