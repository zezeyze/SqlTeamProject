-- �r�nlerin bilgilerini getiren i� i�e 2 view.
IF OBJECT_ID(' dbo.vOyun') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.vOyun
		END
	GO

CREATE OR ALTER VIEW dbo.vUrun AS
	-- �r�nlerin bilgileri getirilmi�tir.
	SELECT
		t.Ad AS UrununTuru,
		ul.Ad AS UlkeAdi,
		U.Ad AS UrununAdi,
		u.YasSiniri AS OyununYasSiniri,
		GF.Ad AS GelistirenFirman�nAdi,
		YF.Ad AS YayimlayanFirma,
		dbo.fncBasarimYuzdesi(u.ID) AS BasarimYuzdesi,
		Itemfiyatlari.EnPahalItem,
    	Itemfiyatlari.EnUcuzItem,
		Itemfiyatlari.OrtalamaFiyat,
		CONVERT(CHAR(10), CikisTarihi, 103) AS CikisTarihi, -- �r�nlerin ��k�� tarihini char olarak de�i�tirir ve tabloya ekler.
		 CASE   
		    -- Oyun ��kal� maximum 1 ay olmu�sa yeni oyun ifadesiyle bilgilendirilir.
            WHEN DATEDIFF(MONTH, u.cikisTarihi, GETDATE()) <= 1 THEN 'Yeni Oyun!!!'   
			-- �r�n�n t�r� yaz�l�msa, yaz�l�m i�in bilgilendirilir.
			WHEN u.TurID=2 THEN 'Yaz�l�mlarda Son Nokta!!'    
            ELSE 'Efsane Oyunlar'  -- Eski/yeni olmayan bir oyunsa efsane oyun ifadesiyle bilgilendirilir.
        END AS UrunDurumu

	FROM tblUrun u
		INNER JOIN tblFirma GF ON u.GelistirenFirmaID = GF.ID 
		INNER JOIN tblFirma YF ON u.YayimlayanFirmaID = YF.ID
		INNER JOIN tblTur t ON u.TurID = t.ID
		INNER JOIN tblUlkedeUrunBulunma ubul ON u.ID = ubul.UrunID
		INNER JOIN tblUlke ul ON ubul.UlkeID = ul.ID
		INNER JOIN (SELECT	u.ID, 
							MIN(kisa.Fiyat) AS EnUcuzItem, -- Oyunla ili�kili itemlerin en pahal�s�n�, en ucuzunu ve ortalamas�n� getitir.
							MAX(kisa.Fiyat) AS EnPahalItem,
						    AVG(kisa.Fiyat) AS OrtalamaFiyat
							FROM tblUrun u
							LEFT JOIN tblItem i ON u.ID = i.UrunID -- Iteme sahip olmayan �r�nlerin de ��kmas� i�in left join ile ba�land�.
							LEFT JOIN tblKullaniciItemSatinAlma kisa ON i.ID = kisa.ItemID	
							GROUP BY u.ID
		           )Itemfiyatlari ON Itemfiyatlari.ID= U.ID
GO

-- T�rkiyedeki �r�nlerin bilgileri sorgulanm��t�r.
SELECT * FROM vUrun 
WHERE UlkeAdi='T�RK�YE';
GO