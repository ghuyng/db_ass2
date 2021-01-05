
-- 1a1
 select
	bhv_truong,
	bhv_chuyennganh,
	bhv_gpa,
	nld_ho,
	nld_tendem,
	nld_ten,
	nld_ngaysinh
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
	liet_ke_dot_tuyen_dung_co_so_luong_nhieu_hon(-1);

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
--	
 if current_date < new.nld_ngaysinh then raise exception 'Ngay sinh moi qua moi.';

return null;
end if;

return new;
end;

$$;

drop trigger if exists dan_trigger_update_nguoilaodong on
nguoilaodong;

create trigger dan_trigger_update_nguoilaodong before
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
 create or replace
function tong_thoi_gian_di_thieu_nam_nay(department int) returns interval language plpgsql as $$
--
 declare total interval := 0;

ngay_cham_cong record;

begin
--
 if not department in (
select
	p.pb_maso
from
	phongban p) then raise exception 'Phong ban % khong ton tai',
department ;
end if;

for ngay_cham_cong in (
select
	*
from
	(nhanvien n
join lamvieccho l on
	n.nv_quoctich = l.lvc_quoctich
	and n.nv_masocmnd = l.lvc_masocmnd
join phongban p2 on
	p2.pb_maso = l.lvc_masophongban
join hopdong h2 on
	h2.hd_mahopdong = l.lvc_mahopdong)
join bangcong b2 on
	b2.bc_maso = n.nv_masobangcong
join ngaylamviec n2 on
	n2.nlv_mabangcong = b2.bc_maso
where
	l.lvc_masophongban = department
	and h2.hd_trangthai = 'Active') loop
--
 continue
when extract (year
from
current_date) <> extract (year
from
ngay_cham_cong.nlv_ngay);

if ngay_cham_cong.nlv_giovaolam > ngay_cham_cong.bc_giovaolamquydinh then total := total - ngay_cham_cong.bc_giovaolamquydinh + ngay_cham_cong.nlv_giovaolam;
end if;

if ngay_cham_cong.nlv_giorave < ngay_cham_cong.bc_gioravequydinh then total := total + ngay_cham_cong.bc_gioravequydinh - ngay_cham_cong.nlv_giorave;
end if;
end loop ;

return total;
end;

$$;

--select
--	tong_thoi_gian_di_thieu_nam_nay(-1);

select
	tong_thoi_gian_di_thieu_nam_nay(5);
