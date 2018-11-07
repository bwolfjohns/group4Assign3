ALTER TABLE LibraryProject.AssetTypes
ADD PreperationFees MONEY NOT NULL
DEFAULT $0.99;


UPDATE LibraryProject.AssetTypes ATS SET ATS.PreperationFees = $1.99 WHERE ATS.AssetTypeKey = 2

--Add ten items to the Asset table

SET IDENTITY_INSERT LibraryProject.Assets ON

INSERT 
	LibraryProject.Assets (AssetKey, Asset, AssetDescription, AssetTypeKey, ReplacementCost, Restricted) 
VALUES 
	(9,'OathBringer','Book 3 of the Stormlight Archives by BrandonSanderson',2,24.19,0),
	(10,'Mistborn','First book in the Mistborn trilogy by Brandon Sanderson',2,9.89,0),
	(11,'Fight Club','R rated movie staring Brad Pitt and Edward Norton',1,14.99,1),
	(12,'The Shining','A Horror thriller by Stephen King',2,6.29,1),
	(13,'Misery','A Horror thriller by Stephen King',2,7.55,1),
	(14,'Misery','R rated thriller movie starring James Cann and Kathy Bates',1,10.99,1),
	(15,'Despicable Me','PG rated childrens movie starring Steve Carell',1,15.99,0),
	(16,'The Nightmare Before Christmas','PG rated stop motion musical featuring the music of Danny Elfman',1,20.05,0),
	(17,'Wackey Wednesday','A Childrens book by Dr. Suess',2,19.25,0),
	(18,'Singing in the Rain','A musical movie starring Debbie Reynolds and Gene Kelley',1,5.69,0)

 SET IDENTITY_INSERT LibraryProject.Assets OFF

 --add new asset type stored proc.
CREATE OR ALTER PROCEDURE LibraryProject.spCreateNewAssetType
	@AssetType VARCHAR(50)
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset Type Already Exists'
	SELECT
		@DoYouExist = COUNT(LPAT.AssetTypeKey)

	FROM
		LibraryProject.AssetTypes LPAT

	WHERE
		UPPER(LPAT.AssetType) = UPPER(@AssetType)
	IF (@DoYouExist = 0)
	BEGIN
		INSERT INTO LibraryProject.AssetTypes
		(
			AssetType
		)
		VALUES (@AssetType)
	END
	ELSE
	BEGIN
	PRINT @ErrorStatement
	END
END;


--update asset prep fees, because the asset prep fees default to $0.99 add ability to change it
CREATE OR ALTER PROCEDURE LibraryProject.spUpdateAssetPrepFees
	@AssetTypeKey INT,
	@PrepFee MONEY
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset Type Does not exist'
	SELECT
		@DoYouExist = COUNT(LPAT.AssetTypeKey)

	FROM
		LibraryProject.AssetTypes LPAT

	WHERE
		LPAT.AssetTypeKey = @AssetTypeKey
	IF (@DoYouExist > 0)
		BEGIN
			UPDATE 
			LibraryProject.AssetTypes 
			SET 
				PreperationFees = @PrepFee 
			WHERE 
				AssetTypeKey = @AssetTypeKey
		END
	ELSE
		BEGIN
			PRINT @ErrorStatement
		END
	 
END;


--create new asset stored proc.
CREATE OR ALTER PROCEDURE LibraryProject.spCreateAsset
		@Asset VARCHAR(50),
		@AssetDescription VARCHAR(50),
		@AssetTypeKey INT,
		@ReplacementCost MONEY,
		@Restricted BIT
AS
BEGIN
	INSERT INTO LibraryProject.Assets
	(
		Asset ,
		AssetDescription,
		AssetTypeKey,
		ReplacementCost,
		Restricted
	)
	VALUES	(@Asset,@AssetDescription,@AssetTypeKey,@ReplacementCost,@Restricted)
END;

--update asset stored proc
CREATE OR ALTER PROCEDURE LibraryProject.spUpdateAsset
		@AssetKey INT,
		@Asset VARCHAR(50),
		@AssetDescription VARCHAR(50),
		@AssetTypeKey INT,
		@ReplacementCost MONEY,
		@Restricted BIT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset Does Not Exist'
	SELECT
		@DoYouExist = COUNT(LPUA.AssetKey)

	FROM
		LibraryProject.Assets LPUA

	WHERE
		LPUA.AssetKey = @AssetKey
	IF (@DoYouExist > 0)
		BEGIN
			UPDATE 
				LibraryProject.Assets
			SET	
				Asset = @Asset,
				AssetDescription = @AssetDescription, 
				AssetTypeKey = @AssetTypeKey,
				ReplacementCost = @ReplacementCost,
				Restricted = @Restricted
			WHERE 
				AssetKey = @AssetKey
		END
	ELSE
		BEGIN
			PRINT @ErrorStatement
		END
	
END

--deactivate asset that is in use
CREATE OR ALTER PROCEDURE LibraryProject.spDeactivateAsset
		@AssetKey INT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset Does Not Exist'
	SELECT
		@DoYouExist = COUNT(LPUA.AssetKey)

	FROM
		LibraryProject.Assets LPUA

	WHERE
		LPUA.AssetTypeKey = @AssetKey
	IF (@DoYouExist > 0)
	BEGIN
		UPDATE LibraryProject.Assets
		SET DeactivatedOn = GetDate()
		WHERE AssetKey = @AssetKey
	END
	ELSE
	BEGIN
		PRINT @ErrorStatement
	END
END


CREATE OR ALTER PROCEDURE LibraryProject.spAddOrUpdateUser
		@Add_Update VARCHAR(6),
		@UserKey INT,
		@LastName VARCHAR(50),
		@FirstName VARCHAR(50),
		@Email VARCHAR(50),
		@Address1 VARCHAR(50),
		@Address2 VARCHAR(30),
		@City VARCHAR(30),
		@StateAbb CHAR(2),--StateAbbreviation
		@Bdate DATE,--Birthdate
		@Ruk INT--ResponsibleUserKey
		
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorMessage varchar(100) = 'Must have Add or Update as first variable to Use spAddOrUpdateUser'
	DECLARE @ErrorMesAllreadyExists varchar(100) = 'User already exists'
	DECLARE @ErrorMesDoesntExist varchar(100) = 'This User Does Not Exist'

	IF (UPPER(@Add_Update) = 'ADD')
		SELECT
			@DoYouExist = COUNT(LPUU.UserKey)

		FROM
			LibraryProject.Users LPUU

		WHERE
			UPPER(LPUU.LastName) = UPPER(@LastName)
			AND
			UPPER(LPUU.FirstName) = UPPER(@FirstName)
			AND
			UPPER(LPUU.Address1) = UPPER(@Address1)
			AND
			UPPER(LPUU.City) = UPPER(@City)
			AND 
			UPPER(LPUU.StateAbbreviation) = UPPER(@StateAbb)
			AND
			LPUU.Birthdate = @Bdate
			AND
			UPPER(LPUU.Email) = UPPER(@Email)

		IF(@DoYouExist = 0)
		BEGIN
			INSERT INTO LibraryProject.Users
			(
				LastName,
				FirstName,
				Email,
				Address1,
				Address2,
				City,
				StateAbbreviation,
				BirthDate,
				ResponsibleUserKey
			)
			VALUES	(@LastName,@FirstName,@Email,@Address1,@Address2,@City,@StateAbb,@Bdate,@Ruk)
		END
		IF(@DoYouExist > 0)
		BEGIN
			PRINT @ErrorMesAllreadyExists
		END
	ELSE IF (UPPER(@Add_Update) = 'UPDATE')
	SELECT
			@DoYouExist = COUNT(LPUU.UserKey)

		FROM
			LibraryProject.Users LPUU

		WHERE
			LPUU.UserKey = @UserKey

		IF(@DoYouExist > 0)
		BEGIN
			UPDATE 
				LibraryProject.Users
			SET	
				LastName = @LastName,
				FirstName = @FirstName,
				Email = @Email,
				Address1 = @Address1,
				Address2 = @Address2,
				City = @City,
				StateAbbreviation = @StateAbb,
				Birthdate = @Bdate,
				ResponsibleUserKey = @Ruk
			WHERE 
				UserKey = @UserKey
		END
		IF(@DoYouExist = 0)
		BEGIN
			PRINT @ErrorMesDoesntExist
		END
	
	ELSE
	BEGIN
	PRINT @ErrorMessage
	END
END

--DEACTIVATE USER CARD
CREATE OR ALTER PROCEDURE LibraryProject.spDeactivateCard
	@CardKey INT,
	@UserKey INT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Card Does Not Exist'
	SELECT
		@DoYouExist = COUNT(CD.UserKey),
		@CardKey = CD.CardKey

	FROM
		LibraryProject.Cards CD

	WHERE
		CD.UserKey = @UserKey
	GROUP BY
		CD.CardKey
	IF(@DoYouExist > 0)
	BEGIN
		UPDATE LibraryProject.Cards
		SET DeactivatedOn = GETDATE()
		WHERE CardKey = @CardKey
	END
END;


CREATE OR ALTER PROCEDURE LibraryProject.spIssueCard
	@CardNum VARCHAR(11),
	@UserKey INT,
	@CardType INT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	SELECT
		@DoYouExist = COUNT(CD.UserKey)

	FROM
		LibraryProject.Cards CD

	WHERE
		CD.UserKey = @UserKey
	IF(@DoYouExist = 0)
	BEGIN
	INSERT INTO LibraryProject.Cards
	(
		CardNumber,
		UserKey,
		CardTypeKey
	)
	VALUES (@CardNum,@UserKey,@CardType)
	END
	ELSE
	BEGIN
		EXEC LibraryProject.spDeactivateCard @UserKey
	END
END;


--Loan Assets
CREATE OR ALTER PROCEDURE LibraryProject.spLoanAsset
	@AssetKey INT,
	@UserKey INT
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(50) = 'Asset Is already checked out'
	DECLARE @LostItem DATE
	DECLARE @LoanKey INT
	DECLARE @LostStatement varchar(50)
	SELECT
		@DoYouExist = COUNT(AL.AssetKey),
		@LoanKey = AL.AssetLoanKey,
		@LostItem = AL.LostOn

	FROM
		LibraryProject.AssetLoans AL

	WHERE
		AL.ReturnedOn IS NULL
		AND
		AL.AssetKey = @AssetKey
	GROUP BY
		AL.LostOn,
		AL.AssetLoanKey
	IF(@DoYouExist = 0)
	BEGIN
		INSERT INTO LibraryProject.AssetLoans
		(
			AssetKey,
			UserKey,
			LoanedOn
		)
		VALUES	(@AssetKey,@UserKey,GETDATE())
	END
	ELSE IF (@LostItem IS NOT NULL)
	BEGIN
		SET @LostStatement = CONCAT('Item was reported lost on ', @LostItem)
		PRINT @LostStatement
	END
	ELSE
	BEGIN
		PRINT @ErrorStatement
	END
END;


CREATE OR ALTER PROCEDURE LibraryProject.spLoanReturnAsset
	@AssetLoanKey INT
	
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset has not been Loaned'
	DECLARE @LostError DATE
	DECLARE @LostStatement varchar(50)
	SELECT
		@DoYouExist = COUNT(AL.AssetKey),
		@LostError = AL.LostOn

	FROM
		LibraryProject.AssetLoans AL

	WHERE
		AL.AssetLoanKey = @AssetLoanKey
		AND
		AL.ReturnedOn IS NULL
	GROUP BY
		AL.LostOn
	IF(@DoYouExist > 0)
	BEGIN
		IF(@LostError IS NULL)
		BEGIN
		UPDATE LibraryProject.AssetLoans
		SET ReturnedOn = GETDATE()
		WHERE AssetLoanKey = @AssetLoanKey
		END
		ELSE
		BEGIN
		SET @LostStatement = CONCAT('Item was reported lost on ', @LostError)
		PRINT @LostStatement
		END
	END
	ELSE
	BEGIN
		PRINT @ErrorStatement
	END
END;


CREATE OR ALTER PROCEDURE LibraryProject.spAssetLost
	@AssetLoanKey INT
	
AS
BEGIN
	DECLARE @DoYouExist int = 0
	DECLARE @ErrorStatement varchar(30) = 'Asset loan does not exist'
	SELECT
		@DoYouExist = COUNT(AL.AssetKey)

	FROM
		LibraryProject.AssetLoans AL

	WHERE
		AL.AssetLoanKey = @AssetLoanKey
		AND
		AL.LoanedOn IS NOT NULL
		AND
		AL.ReturnedOn IS NULL

	IF(@DoYouExist > 0)
	BEGIN
		UPDATE LibraryProject.AssetLoans
		SET LostOn = GETDATE()
		WHERE AssetLoanKey = @AssetLoanKey
	END
	ELSE
	BEGIN
		PRINT @ErrorStatement
	END

END;



CREATE OR ALTER PROCEDURE LibraryProject.spPayFee
	@FeeKey INT
AS
BEGIN
	UPDATE LibraryProject.Fees
	SET Paid = 1, Amount = 0
	WHERE FeeKey = @FeeKey
END;

CREATE OR ALTER TRIGGER LibraryProject.VerifyUser
ON LibraryProject.AssetLoans
AFTER INSERT
AS
BEGIN
	DECLARE @UserCardType INT
	DECLARE @AssetLoanKeyID INT
	DECLARE @NotOldEnough varchar(50) = 'You are not old enough'
	SELECT
		@UserCardType = CD.CardTypeKey,
		@AssetLoanKeyID = i.AssetLoanKey 
	FROM 
		inserted i 
		INNER JOIN LibraryProject.AssetLoans AL ON i.AssetLoanKey = AL.AssetLoanKey
		INNER JOIN LibraryProject.Cards CD ON i.UserKey = CD.UserKey
	
	IF(@UserCardType <> 1)
	BEGIN
		DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = @AssetLoanKeyID
		PRINT @NotOldEnough
	END

END;

CREATE OR ALTER TRIGGER LibraryProject.CheckLimitOfAssets
ON LibraryProject.AssetLoans
AFTER INSERT
AS
BEGIN
	DECLARE @UserKey INT
	DECLARE @UserCardType INT
	DECLARE @ItemsLoaned INT
	DECLARE @AssetLoanInsKey INT
	DECLARE @ErrorMsg varchar(50) = CONCAT(CONCAT('You have exceded the asset loan limit of ', @ItemsLoaned), ' Items.')

	SELECT
		@AssetLoanInsKey = AssetLoanKey
	FROM
		inserted

	SELECT 
		@ItemsLoaned = COUNT(AL.AssetLoanKey), 
		@UserKey = CD.UserKey,
		@UserCardType =  CD.CardTypeKey
	FROM 
		LibraryProject.Cards CD
		INNER JOIN LibraryProject.AssetLoans AL ON CD.UserKey = AL.UserKey
	WHERE 
		AL.ReturnedOn IS NULL 
		AND AL.LostOn IS NULL
	GROUP BY
		CD.UserKey,
		CD.CardTypeKey
	
	IF(@UserCardType = 1 AND @ItemsLoaned > 6) --ADULTS
	BEGIN
		DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = @AssetLoanInsKey
	END
	ELSE IF(@UserCardType = 2 AND @ItemsLoaned > 4) --TEENS
	BEGIN
		DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = @AssetLoanInsKey
	END
	ELSE IF(@UserCardType = 3 AND @ItemsLoaned > 2) --CHILDREN
	BEGIN
		DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = @AssetLoanInsKey
	END
END

UPDATE LibraryProject.AssetLoans
SET LostOn = GETDATE()
WHERE AssetKey = 1 AND UserKey = 6


--Fee Function
CREATE OR ALTER FUNCTION LibraryProject.CalculateFees(@LoanedOn AS DATE,@ReturnedOn AS DATE,@LostOn AS DATE)
RETURNS MONEY
AS
BEGIN
	Declare @Cost MONEY = 0
	Declare @Days INT = 0
	IF (@ReturnedOn IS NOT NULL)
	BEGIN
		IF (@LostOn IS NOT NULL)
		BEGIN
			--set cost = to price of asset
		END
		ELSE
		BEGIN
			IF (DATEDIFF(day,@LoanedOn,GETDATE()) > 3 AND DATEDIFF(day,@LoanedOn,GETDATE()) < 7)
			BEGIN
				@Cost = 1.00
			END
			ELSE IF (DATEDIFF(day,@LoanedOn,GETDATE()) > 6 AND DATEDIFF(day,@LoanedOn,GETDATE()) < 15)
			BEGIN 
				@Cost = 3.00
			END
			ELSE IF (DATEDIFF(day,@LoanedOn,GETDATE()) > 14)
			BEGIN 
				@Cost = 3.00
			END
		END

	END

	RETURN (@Cost)
END;


/*Testing purposes
EXEC LibraryProject.spCreateNewAssetType 'Audio Book';

EXEC LibraryProject.spUpdateAssetPrepFees 4, 2.99;

EXEC LibraryProject.spCreateAsset 'a book','none','1','20','1';

EXEC LibraryProject.spUpdateAsset  '9', 'a dvd','none', 2, 20, 1;

EXEC LibraryProject.spDeactivateAsset '9';

EXEC LibraryProject.spAddOrUpdateUser 'add', '7', 'Adams', 'Joe', 'somthing@mail.com','123N 456S',Null, 'the big city','UT','1-Jul-30' , 1

EXEC LibraryProject.spAddOrUpdateUser 'update', '7', 'Hughes', 'John','somthing@mail.com','123N 456S', 'Null', 'the big city', 'UT', '1-Jul-30','1'

EXEC LibraryProject.spIssueCard 'C9079-647-9065','7','1'

EXEC LibraryProject.spDeactivateCard '8'

EXEC LibraryProject.spLoanAsset '11', '6'

EXEC LibraryProject.spAssetLost '12'

EXEC LibraryProject.spLoanReturnAsset '9'

select *from LibraryProject.AssetTypes
select *from LibraryProject.Assets
select *from LibraryProject.Users
select * from LibraryProject.Cards



select * from LibraryProject.AssetLoans
select * from LibraryProject.Cards
select * from LibraryProject.AssetLoans
select * from LibraryProject.Assets
select * from LibraryProject.CardTypes
select * from LibraryProject.Fees
select * from LibraryProject.Users

*/

INSERT INTO LibraryProject.AssetLoans VALUES(7, 3, '9/15/2018', '10/26/2018', NULL)

DELETE FROM LibraryProject.AssetLoans WHERE AssetLoanKey = '6'

SELECT
		CD.CardTypeKey,
		AL.AssetLoanKey 
	FROM 
		LibraryProject.AssetLoans AL INNER JOIN LibraryProject.Cards CD ON AL.UserKey = CD.UserKey

SELECT
		COUNT(AL.AssetKey),
		AL.AssetLoanKey,
		AL.LostOn

	FROM
		LibraryProject.AssetLoans AL
	WHERE
		AL.ReturnedOn IS NULL
	GROUP BY
		AL.AssetLoanKey,
		AL.LostOn



		--testing

		DECLARE @LoanedOn DATE = '6-nov-2018'
		SELECT DATEDIFF(day,@LoanedOn,GETDATE())