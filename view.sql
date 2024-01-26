-- Ürünlerin bilgilerini getiren iç içe 2 view.
IF OBJECT_ID(' dbo.vOyun') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.vOyun
		END
	GO

CREATE OR ALTER VIEW dbo.vUrun AS
	-- Ürünlerin bilgileri getirilmiþtir.
	SELECT
		t.Ad AS UrununTuru,
		ul.Ad AS UlkeAdi,
		U.Ad AS UrununAdi,
		u.YasSiniri AS OyununYasSiniri,
		GF.Ad AS GelistirenFirmanýnAdi,
		YF.Ad AS YayimlayanFirma,
		dbo.fncBasarimYuzdesi(u.ID) AS BasarimYuzdesi,
		Itemfiyatlari.EnPahalItem,
    	Itemfiyatlari.EnUcuzItem,
		Itemfiyatlari.OrtalamaFiyat,
		CONVERT(CHAR(10), CikisTarihi, 103) AS CikisTarihi, -- Ürünlerin çýkýþ tarihini char olarak deðiþtirir ve tabloya ekler.
		 CASE   
		    -- Oyun çýkalý maximum 1 ay olmuþsa yeni oyun ifadesiyle bilgilendirilir.
            WHEN DATEDIFF(MONTH, u.cikisTarihi, GETDATE()) <= 1 THEN 'Yeni Oyun!!!'   
			-- Ürünün türü yazýlýmsa, yazýlým için bilgilendirilir.
			WHEN u.TurID=2 THEN 'Yazýlýmlarda Son Nokta!!'    
            ELSE 'Efsane Oyunlar'  -- Eski/yeni olmayan bir oyunsa efsane oyun ifadesiyle bilgilendirilir.
        END AS UrunDurumu

	FROM tblUrun u
		INNER JOIN tblFirma GF ON u.GelistirenFirmaID = GF.ID 
		INNER JOIN tblFirma YF ON u.YayimlayanFirmaID = YF.ID
		INNER JOIN tblTur t ON u.TurID = t.ID
		INNER JOIN tblUlkedeUrunBulunma ubul ON u.ID = ubul.UrunID
		INNER JOIN tblUlke ul ON ubul.UlkeID = ul.ID
		INNER JOIN (SELECT	u.ID, 
							MIN(kisa.Fiyat) AS EnUcuzItem, -- Oyunla iliþkili itemlerin en pahalýsýný, en ucuzunu ve ortalamasýný getitir.
							MAX(kisa.Fiyat) AS EnPahalItem,
						    AVG(kisa.Fiyat) AS OrtalamaFiyat
							FROM tblUrun u
							LEFT JOIN tblItem i ON u.ID = i.UrunID -- Iteme sahip olmayan ürünlerin de çýkmasý için left join ile baðlandý.
							LEFT JOIN tblKullaniciItemSatinAlma kisa ON i.ID = kisa.ItemID	
							GROUP BY u.ID
		           )Itemfiyatlari ON Itemfiyatlari.ID= U.ID
GO

-- Türkiyedeki ürünlerin bilgileri sorgulanmýþtýr.
SELECT * FROM vUrun 
WHERE UlkeAdi='TÜRKÝYE';
GO