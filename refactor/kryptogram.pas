unit kryptogram;

{Copyright 2011-2021 A.K.}

interface

    procedure CreatePassword(Password: string);
    function IsPasswordCorrect(Password: string): boolean;

implementation

    const
        PASSWORD_FILE_PATH = 'pass.dat';
        MAX_PASSWORD_Length = 10;
        CORRECT_CHAR_POSITION = 2;
        OFFSET = CORRECT_CHAR_POSITION - 1;
        ENCRYPTED_DATA_ARRAY_SIZE = CORRECT_CHAR_POSITION * MAX_PASSWORD_Length + OFFSET;

    type
        TEncryptedData = record
        Elements: array[1..ENCRYPTED_DATA_ARRAY_SIZE] of string;
        Length: byte
    end;

    function GetRandomChar: char;
    const
        FIRST_CHAR_OFFSET = 32;
        ALL_CHARS = 94;
    begin
        GetRandomChar := char((Random(ALL_CHARS)) + FIRST_CHAR_OFFSET);
    end;

    function GetRandomString: string;
    const
        MAX_RAND_STRING_LENGTH = 200;
    var
        Index: byte;
        RandomString: string;
    begin
        for Index := 0 to Random(MAX_RAND_STRING_LENGTH) do
            RandomString[Index] := GetRandomChar;
        GetRandomString := RandomString;
    end;

    procedure SaveEncryptedPassword(EncryptedPassword: TEncryptedData);
    var
        PassFile: file of TEncryptedData;
    begin
        Assign(PassFile, PASSWORD_FILE_PATH);
        Rewrite(PassFile);
        Write(PassFile, EncryptedPassword);
        Close(PassFile);
    end;

    function ReadEncryptedPassword: TEncryptedData;
    var
        PassFile: file of TEncryptedData;
        TempData: TEncryptedData;
    begin
        Assign(PassFile, PASSWORD_FILE_PATH);
        Reset(PassFile);
        Read(PassFile, TempData);
        Close(PassFile);
        ReadEncryptedPassword := TempData;
    end;

    function IsPasswordCorrect(Password: string): boolean;
    var
        PasswordVerifier: byte;
        PasswordLength: byte;
        StoredPasswordData: TEncryptedData;
        CurrentElement: byte;
    begin
        PasswordLength := Length(Password);
        StoredPasswordData := ReadEncryptedPassword;

        if StoredPasswordData.Length <> PasswordLength then
            Exit(FALSE);

        for CurrentElement := 1 to CORRECT_CHAR_POSITION * StoredPasswordData.Length do
        begin
            if CurrentElement mod CORRECT_CHAR_POSITION = 0 then
                if not (Password[CurrentElement div CORRECT_CHAR_POSITION] = StoredPasswordData.Elements[CurrentElement][1]) then
                    Exit(FALSE);
        end;

        IsPasswordCorrect := TRUE
    end;

    procedure CreatePassword(Password: string);
    var
        EncryptedPassword: TEncryptedData;
        CurrentElement: byte;
    begin
        EncryptedPassword.Length := Length(Password);
        Randomize;

        for CurrentElement := 1 to CORRECT_CHAR_POSITION * EncryptedPassword.Length + OFFSET do
            if(CurrentElement mod CORRECT_CHAR_POSITION = 0) then
                EncryptedPassword.Elements[CurrentElement] := Password[CurrentElement div CORRECT_CHAR_POSITION]
            else
                EncryptedPassword.Elements[CurrentElement] := GetRandomString;

        SaveEncryptedPassword(EncryptedPassword);
    end;
end.