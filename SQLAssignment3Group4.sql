CREATE PROCEDURE LibraryProject.spCreateNewAssetType
	@AssetType VARCHAR(50)
AS
BEGIN
	INSERT INTO LibraryProject.AssetTypes
	(
		AssetType
	)
	VALUES (@AssetType)
END;


CREATE PROCEDURE LibraryProject.spCreateAsset
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


CREATE PROCEDURE LibraryProject.spUpdateAsset
		@AssetKey INT,
		@Asset VARCHAR(50),
		@AssetDescription VARCHAR(50),
		@AssetTypeKey INT,
		@ReplacementCost MONEY,
		@Restricted BIT
AS
BEGIN
	Update LibraryProject.Assets
	SET Asset = @Asset,AssetDescription = @AssetDescription, AssetTypeKey = @AssetTypeKey,ReplacementCost = @ReplacementCost,Restricted = @Restricted
	WHERE AssetKey = @AssetKey
END


CREATE PROCEDURE LibraryProject.spDeactivateAsset
		@AssetKey INT
AS
BEGIN
	UPDATE LibraryProject.Assets
	SET DeactivatedOn = GetDate()
	WHERE AssetKey = @AssetKey
END


CREATE PROCEDURE LibraryProject.spAddOrUpdateUser
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
	IF (@Add_Update = 'add' OR @Add_Update = 'Add')
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
	IF (@Add_Update = 'update' OR @Add_Update = 'Update')
	BEGIN
		UPDATE LibraryProject.Users
		SET LastName = @LastName,FirstName = @FirstName,Email = @Email,Address1 = @Address1,Address2 = @Address2,City = @City,StateAbbreviation = @StateAbb,Birthdate = @Bdate,ResponsibleUserKey = @Ruk
		WHERE UserKey = @UserKey
	END
END

CREATE PROCEDURE LibraryProject.spIssueCard
	@CardNum VARCHAR(11),
	@UserKey INT,
	@CardType INT
AS
BEGIN
	INSERT INTO LibraryProject.Cards
	(
		CardNumber,
		UserKey,
		CardTypeKey
	)
	VALUES (@CardNum,@UserKey,@CardType)
END;


CREATE PROCEDURE LibraryProject.spDeactivateCard
	@CardKey INT
AS
BEGIN
	UPDATE LibraryProject.Cards
	SET DeactivatedOn = GETDATE()
	WHERE CardKey = @CardKey
END;

/*Testing purposes
EXEC LibraryProject.spCreateNewAssetType @AssetType = 'ok';

EXEC LibraryProject.spCreateAsset @Asset = 'a book',@AssetDescription = 'none',@AssetTypeKey = 1,@ReplacementCost = 20,@Restricted = 1;

EXEC LibraryProject.spUpdateAsset @AssetKey = 9, @Asset = 'a dvd',@AssetDescription = 'none',@AssetTypeKey = 2,@ReplacementCost = 20,@Restricted = 1;

EXEC LibraryProject.spDeactivateAsset @AssetKey = 9;

EXEC LibraryProject.spAddOrUpdateUser @add_Update = 'add', @UserKey = '7', @LastName = 'Dirt',@FirstName = 'Joe',@Email = 'somthing@mail.com',@Address1 = '123N 456S',@Address2 = Null ,@City = 'the big city',@StateAbb = 'UT',@Bdate = '1-Jul-30' ,@Ruk = 1

EXEC LibraryProject.spAddOrUpdateUser @add_Update = 'update', @UserKey = '7', @LastName = 'Dirt',@FirstName = 'Joe',@Email = 'somthing@mail.com',@Address1 = '123N 456S',@Address2 = Null ,@City = 'the big city',@StateAbb = 'UT',@Bdate = '1-Jul-30' ,@Ruk = 1

EXEC LibraryProject.spIssueCard @CardNum = 'C9079-647-9065',@UserKey = 7,@CardType = 1

EXEC LibraryProject.spDeactivateCard @CardKey =  9

select *from LibraryProject.AssetTypes
select *from LibraryProject.Assets
select *from LibraryProject.Users
select * from LibraryProject.Cards
*/


