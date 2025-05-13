-- Kullanıcılar ürün satın aldıktan sonra belirlenen miktarda puan tablosuna ödül puanlar ekleyen trigger.
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

    -- Eklenen verilerin bilgileri alınır.
    SELECT @KullaniciID = KullaniciID, @Harcama = SUM(Fiyat)
    FROM inserted
    GROUP BY KullaniciID; -- KullaniciID'ye göre gruplanır.
    BEGIN        
		-- Her ürünün fiyatının %10'u kadar ödül puan verilir.
        DECLARE @OdulPuan INT = @Harcama * 0.1; 

        -- PuanTablosu tablosuna kullanıcıya verilen ödül puanı eklenir.
        INSERT INTO PuanTablosu (KullaniciID, OdulPuan)
        VALUES (@KullaniciID, @OdulPuan);

        -- Kullanıcıya yapılan işlem hakkında bilgilendirme yapılır.
        PRINT 'Tebrikler! Toplam harcamanız ' + CONVERT(VARCHAR, @Harcama) +
		' üzerinde olduğu için ' + CONVERT(VARCHAR, @OdulPuan) + ' puan kazandınız.';
    END
END;

