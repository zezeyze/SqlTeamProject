-- Kullanýcýlar ürün satýn aldýktan sonra belirlenen miktarda puan tablosuna ödül puanlar ekleyen trigger.
IF OBJECT_ID(' dbo.trg_UrunSatinAlma') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.trg_UrunSatinAlma
		END
	GO

-- Puan tablosu eklendi.
--CREATE TABLE PuanTablosu ( KullaniciID INT, OdulPuan INT );

CREATE OR ALTER TRIGGER trg_UrunSatinAlma
ON tblKullaniciUrunSatinAlma
AFTER INSERT
AS
BEGIN
    DECLARE @KullaniciID INT, @Harcama MONEY;

    -- Eklenen verilerin bilgileri alýnýr.
    SELECT @KullaniciID = KullaniciID, @Harcama = SUM(Fiyat)
    FROM inserted
    GROUP BY KullaniciID; -- KullaniciID'ye göre gruplanýr.
    BEGIN        
		-- Her ürünün fiyatýnýn %10'u kadar ödül puan verilir.
        DECLARE @OdulPuan INT = @Harcama * 0.1; 

        -- PuanTablosu tablosuna kullanýcýya verilen ödül puaný eklenir.
        INSERT INTO PuanTablosu (KullaniciID, OdulPuan)
        VALUES (@KullaniciID, @OdulPuan);

        -- Kullanýcýya yapýlan iþlem hakkýnda bilgilendirme yapýlýr.
        PRINT 'Tebrikler! Toplam harcamanýz ' + CONVERT(VARCHAR, @Harcama) +
		' üzerinde olduðu için ' + CONVERT(VARCHAR, @OdulPuan) + ' puan kazandýnýz.';
    END
END;

