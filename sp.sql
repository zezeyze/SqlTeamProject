--Ürün satýn alýrken, ürünün fiyatý ve cüzdandaki bakiye kontrolü yapan procedure.
IF OBJECT_ID(' dbo.sp_UrunSatisi') IS NOT NULL
	BEGIN
		DROP FUNCTION dbo.sp_UrunSatisi
		END
	GO
-- Puan tablosu eklendi.
--CREATE TABLE PuanTablosu ( KullaniciID INT, OdulPuan INT );

CREATE OR ALTER PROCEDURE  dbo.sp_UrunSatisi (@KullaniciID INT, @UrunID INT)
AS 
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY

	DECLARE @UrununFiyati MONEY;
	SELECT @UrununFiyati=Fiyat
	FROM tblKullaniciUrunSatinAlma
	WHERE @UrunID=UrunID;

	DECLARE @MevcutBakiye MONEY;
	SELECT @MevcutBakiye=Cuzdan
	FROM tblKullanici
	WHERE @KullaniciID=ID;

	--Eðer ürünün fiyatý, kullanýcýnýn bakiyesinden yüksekse ERROR verilir.
	IF @UrununFiyati>@MevcutBakiye
		BEGIN
			RAISERROR('Yetersiz bakiye. Satýþ tamamlanamadý.',16,1);	
		END

	-- Ürünün fiyatýna bakiyesi yetiyorsa, ürünün ve kullanýcýnýn bilgileri tblKullaniciUrunSatinAlma tablosuna eklenir.
	-- Kullanýcýnýn cüzdanýnda da gerekli deðiþiklikler yapýlýr.
    ELSE 
		BEGIN
			-- Her ürünün SeriNumarasi için için unique ID'ler verilir.
			DECLARE @SeriNumarasi VARCHAR(25) = CONVERT(VARCHAR(MAX), NEWID());
			INSERT INTO tblKullaniciUrunSatinAlma VALUES(@SeriNumarasi, GETDATE(), @UrununFiyati, @KullaniciID,@UrunID);
			PRINT 'Satýþ iþlemi gerçekleþtirildi';

			-- Kullanýcýnýn cüzdaný, satýn alma iþleminden sonra güncellenir.
			UPDATE tblKullanici
			SET Cuzdan = Cuzdan - @UrununFiyati
			WHERE ID = @KullaniciID;
		END
	END TRY
	-- If blogundaki ERROR'u yazdýrýr.
	BEGIN CATCH
		PRINT 'Hata Oluþtu: ' + ERROR_MESSAGE();
	END CATCH
	COMMIT TRANSACTION
	END
	
--KullaniciID'si 1 olan UrunID'si 2 olan ürün satýþý gerçekleþir.
EXEC dbo.sp_UrunSatisi 1,2 -- Oyun hiç satýn almamýþ ve cüzdanýnda para bulunan bir kullanýcý
EXEC dbo.sp_UrunSatisi 440,1 -- Oyun daha önce satýn almýþ bir kullanýcý
EXEC dbo.sp_UrunSatisi 500,1 -- Oyun daha önce satýn almamýþ ama cüzdanýnda para bulunmayan bir kullanýcý

	