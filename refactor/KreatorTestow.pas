program test_kreator; // v.1.3

{Copyright 2011-2021 A.K.}

uses
    Crt, DOS, Windows, sysUtils, kryptogram;

const
    USER_STUDENT = 'Zdajacy';
    USER_EXAMINER = 'Egzaminator';

    TEXT_ANSWER = 'Odpowiedz';
    TEXT_FIRST_NAME = 'Imie';
    TEXT_GRADE_CHEATER = 'Oszust!';
    TEXT_GRADE_FAIL = 'Nie zdal';
    TEXT_GRADE_GOOD = 'Dobry';
    TEXT_GRADE_PASS = 'Zdal';
    TEXT_GRADE_PASSING = 'Dopuszczajacy';
    TEXT_GRADE_SATISFACTORY = 'Dostateczny';
    TEXT_GRADE_UNSATISFACTORY = 'Niedostateczny';
    TEXT_GRADE_VERY_GOOD = 'Bardzo Dobry';
    TEXT_GRADING_METHOD_PASS_OR_FAIL = 'Zdalˆ/Nie Zdal';
    TEXT_GRADING_METHOD_SCHOOL_SCALE = 'Szkolna skala ocen';
    TEXT_HELLO = 'Witaj';
    TEXT_LABEL_ALL_POINTS = 'na';
    TEXT_LABEL_DATE = 'Data';
    TEXT_LABEL_EARNED_POINTS = 'Punkty za zadanie';
    TEXT_LABEL_EXPECTED_ANSWER = 'Prawidlowa odpowiedz';
    TEXT_LABEL_GIVEN_ANSWER = 'Odpowiedz zdajacego';
    TEXT_LABEL_GRADE = 'Ocena';
    TEXT_LABEL_SCORE = 'Wynik';
    TEXT_LABEL_STUDENT_NAME = USER_STUDENT;
    TEXT_LABEL_TIME_BEGIN = 'Czas rozpoczecia';
    TEXT_LABEL_TIME_END = 'Czas zakonczenia';
    TEXT_LAST_NAME = 'Nazwisko';
    TEXT_MSG_ANSWER_OUT_OF_RANGE = 'Podana odpowiedz nie istnieje! Wprowadz ponownie!';
    TEXT_MSG_ENTER_PASSWORD = 'Wprowadz haslˆo aby rozpoczac prace z kreatorem.';
    TEXT_MSG_INCORRECT_PASSWORD = 'Hasˆlo nieprawidˆowe! Wci˜nij [ENTER] aby kontynuowac!';
    TEXT_MSG_METHOD_NOT_FOUND = 'Nie znaleziono! Wybierz ponownie!';
    TEXT_MSG_NO_EXAMS = 'Brak testow do rozwiazania!';
    TEXT_MSG_NO_PASSWORD = 'Brak hasˆla zabezpieczajacego! Utworz nowe hasˆlo!';
    TEXT_MSG_PASSWORD_LIMIT = 'Uwaga! Haslˆo nie moze miec wiecej niz 10 znakow!';
    TEXT_MSG_USER_NOT_EXISTS = 'Podany uzytkownik nie istnieje!';
    TEXT_PASSWORD = 'Haslo';
    TEXT_PLEASE_ENTER_ANSWERS = 'Podaj odpowiedzi';
    TEXT_PLEASE_ENTER_CONTENT = 'Podaj tresc pytania';
    TEXT_PLEASE_ENTER_HEADER = 'Wprowadz nagˆlowek';
    TEXT_PLEASE_ENTER_MIN_PASS_SCORE = 'Zdane od [%]';
    TEXT_PLEASE_ENTER_TASKS_COUNT = 'Podaj ilo˜sc pytan';
    TEXT_PLEASE_ENTER_USER = 'Podaj nazwe uzytkownika';
    TEXT_PLEASE_SELECT_METHOD = 'Wybierz sposob oceniania:';
    TEXT_QUESTION = 'Pytanie';
    TEXT_QUESTION_NO = 'Pytanie nr';
    TEXT_STUDENT_DATA = 'Dane zdajacego';
    TEXT_TO = 'do';
    TEXT_WHICH_ONE_ANSWER_IS_CORRECT = 'Ktora odpowiedz jest poprawna?';

    FIRST_ANSWER = Ord('a');
    LAST_ANSWER = Ord('c');

    TASKS_LIMIT = 250;

    PATH_DIR_EXAM = 'C:\Egzamin';
    PATH_FILE_TASKLIST = PATH_DIR_EXAM + '\test.data';
    PATH_FILE_EXAM_PROPERTIES = PATH_DIR_EXAM + '\settings.ini';
    PATH_FILE_BACKUP = 'backup.rtf';
    PATH_FILE_SOLUTION = PATH_DIR_EXAM + '\test.rtf';
    PATH_FILE_PASSWORD = 'pass.dat';

    GRADING_METHOD_CHEATER = 0;
    GRADING_METHOD_PASS_OR_FAIL = 1;
    GRADING_METHOD_SCHOOL_SCALE = 2;

type
    TTask = record
    Id: byte;
    Content: string;
    Answers: array[FIRST_ANSWER..LAST_ANSWER] of string;
    CorrectAnswer: byte;
    end;

    TTime = record
    Hour: word;
    Minute: word;
    Second: word;
    end;

    TDate = record
    Day: word;
    Month: word;
    Year: word;
    end;

    TPerson = record
    FirstName: string;
    LastName: string;
    end;

    TExamProperties = record
    Header: string;
    GradingMethod: byte;
    MinPassScore: byte;
    end;

    TExam = record
    Properties: TExamProperties;
    TasksCount: byte;
    Tasks: array[1..TASKS_LIMIT] of TTask;
    end;

    TExamSolution = record
    Date: TDate;
    BeginTime: TTime;
    EndTime: TTime;
    Student: TPerson;
    Exam: TExam;
    Answers: array[1..TASKS_LIMIT] of byte;
    Score: byte;
    PercentageScore: byte;
    end;

function GetCurrentDate: TDate;
var
    TempDate: TDate;
    TempDateArray: array[1..4] of word;
begin
    GetDate(TempDateArray[1], TempDateArray[2], TempDateArray[3], TempDateArray[4]);
    TempDate.Year := TempDateArray[1];
    TempDate.Month := TempDateArray[2];
    TempDate.Day := TempDateArray[3];
    GetCurrentDate := TempDate;
end;

function GetCurrentTime: TTime;
var
    TempTime: TTime;
    TempTimeArray: array[1..4] of word;
begin
    GetTime(TempTimeArray[1], TempTimeArray[2], TempTimeArray[3], TempTimeArray[4]);
    TempTime.Hour := TempTimeArray[1];
    TempTime.Minute := TempTimeArray[2];
    TempTime.Second := TempTimeArray[3];
    GetCurrentTime := TempTime;
end;

function GetOneOfBinaryGradesByMinScore(Score, MinPassScore: byte): string;
begin
    if(Score < MinPassScore) then
        GetOneOfBinaryGradesByMinScore := TEXT_GRADE_FAIL
    else
        GetOneOfBinaryGradesByMinScore := TEXT_GRADE_PASS;
end;

function GetSchoolGrade(Score: byte): string;
const
    MARGIN_PASSING = 30;
    MARGIN_SATISFACTORY = 50;
    MARGIN_GOOD = 70;
    MARGIN_VERY_GOOD = 90;
begin
    if(score >= MARGIN_VERY_GOOD) then
        GetSchoolGrade := TEXT_GRADE_VERY_GOOD
    else if (score >= MARGIN_GOOD) then
        GetSchoolGrade := TEXT_GRADE_GOOD
    else if (score >= MARGIN_SATISFACTORY) then
        GetSchoolGrade := TEXT_GRADE_SATISFACTORY
    else if (score >= MARGIN_PASSING) then
        GetSchoolGrade := TEXT_GRADE_PASSING
    else
        GetSchoolGrade := TEXT_GRADE_UNSATISFACTORY;
end;

function GetGrade(Method, Score, MinPassScore: byte): string;
begin
    case Method of
        GRADING_METHOD_CHEATER:
            GetGrade := TEXT_GRADE_CHEATER;
        GRADING_METHOD_PASS_OR_FAIL:
            GetGrade := GetOneOfBinaryGradesByMinScore(Score, MinPassScore);
        GRADING_METHOD_SCHOOL_SCALE:
            GetGrade := GetSchoolGrade(Score);
    end;
end;

function Percent(Amount, Total: integer): real;
begin
    Percent := ((Amount * 100) / Total);
end;

procedure HideFile(Path: string);
begin
    FileSetAttr(Path, faHidden);
end;

procedure WriteTask(Task: TTask);
var
    Counter: byte;
begin
    WriteLn;
    WriteLn(' ', TEXT_QUESTION, ' ', Task.Id);
    WriteLn('  ', Task.Content);
    WriteLn;
    for Counter := FIRST_ANSWER to LAST_ANSWER do
        WriteLn('  ', Chr(Counter), ') ', Task.Answers[Counter]);
    WriteLn;
end;

function ExtractAnswerCode(Input: string): byte;
begin
    if(Length(Input) < 1) then
        ExtractAnswerCode := FIRST_ANSWER - 1
    else
        ExtractAnswerCode := Ord(LowerCase(Input[1]));
end;

function IsAnswerInRange(Answer: byte): boolean;
begin
    IsAnswerInRange := (Answer >= FIRST_ANSWER) and (Answer <= LAST_ANSWER);
end;

function CalculatePercentageScore(Amount, Total: byte): byte;
begin
    CalculatePercentageScore := Trunc(Percent(Amount, Total));
end;

function ReadAnswer: byte;
var
    TmpInput: string;
    TmpAnswer: byte;
    IsAnswerSetCorrectly: boolean;
begin
    repeat
        Write(' ', TEXT_ANSWER, ': ');
        ReadLn(TmpInput);
        TmpAnswer := ExtractAnswerCode(TmpInput);
        IsAnswerSetCorrectly := IsAnswerInRange(TmpAnswer);
        if not IsAnswerSetCorrectly then
            WriteLn(' ', TEXT_MSG_ANSWER_OUT_OF_RANGE);
    until IsAnswerSetCorrectly;

    ReadAnswer := TmpAnswer;
end;

function CreateTask(Id: byte) : TTask;
var
    TmpTask: TTask;
    Counter: byte;
    TmpInput: string;
    IsCorrectAnswerSet: boolean;
begin
    TmpTask.Id := Id;

    WriteLn;
    WriteLn(' ', TEXT_QUESTION_NO, ' ', TmpTask.Id,':');
    WriteLn;
    WriteLn;
    WriteLn(' ', TEXT_PLEASE_ENTER_CONTENT, ':');
    WriteLn;
    Write(' ');
    ReadLn(TmpTask.Content);
    WriteLn;
    WriteLn(' ', TEXT_PLEASE_ENTER_ANSWERS, ':');

    for Counter := FIRST_ANSWER to LAST_ANSWER do
    begin
        WriteLn;
        Write(' ', Chr(Counter),') ');
        ReadLn(TmpTask.Answers[Counter]);
        WriteLn;
    end;

    Write(' ', TEXT_WHICH_ONE_ANSWER_IS_CORRECT, ' ');
    TmpTask.CorrectAnswer := ReadAnswer;
    ClrScr;

    CreateTask := TmpTask;
end;

procedure WriteTime(var TextFile: text; TimeLabel: string; Time: TTime);
begin
    Write(TextFile, ' ', TimeLabel, ': ', Time.Hour, ':', Time.Minute, ':', Time.Second);
end;

procedure WriteTaskSolution(var TextFile: text; Task: TTask; GivenAnswer: byte);
var
    Counter: byte;
begin
    WriteLn(TextFile);
    WriteLn(TextFile, ' ', TEXT_QUESTION, ' ', Task.Id);
    Writeln(TextFile, ' ', Task.Content);

    for Counter := FIRST_ANSWER to LAST_ANSWER do
        WriteLn(TextFile, ' ', Chr(Counter), ') ', Task.Answers[Counter]);

    WriteLn(TextFile);
    WriteLn(TextFile, ' ', TEXT_LABEL_GIVEN_ANSWER, ':  ', Chr(GivenAnswer));
    WriteLn(TextFile, ' ', TEXT_LABEL_EXPECTED_ANSWER, ':  ', Chr(Task.CorrectAnswer));
    WriteLn(TextFile);

    if GivenAnswer = Task.CorrectAnswer then
        Write(TextFile, ' ', TEXT_LABEL_EARNED_POINTS, ': 1')
    else
        Write(TextFile, ' ', TEXT_LABEL_EARNED_POINTS, ': 0');

    for Counter := 1 to 3 do
        WriteLn(TextFile);
end;

procedure Save(Solution: TExamSolution; Path: string);
const
    LINE = '--------------------------------------------------------------------------------';
var
    ExamFile: text;
    Counter: byte;
begin
    Assign(ExamFile, Path);
    Rewrite(ExamFile);
    WriteLn(ExamFile, ' ', Solution.Exam.Properties.Header);
    WriteLn(ExamFile, LINE);
    WriteLn(ExamFile, ' ', TEXT_LABEL_STUDENT_NAME, ': ', Solution.Student.FirstName, ' ', Solution.Student.LastName);
    WriteLn(ExamFile, LINE);
    WriteLn(ExamFile, ' ', TEXT_LABEL_DATE, ': ', Solution.Date.Day, '.', Solution.Date.Month, '.', Solution.Date.Year, '.');
    WriteLn(ExamFile, LINE);
    WriteTime(ExamFile, TEXT_LABEL_TIME_BEGIN, Solution.BeginTime);
    Write(ExamFile, '            ');
    WriteTime(ExamFile, TEXT_LABEL_TIME_END, Solution.EndTime);
    WriteLn(ExamFile);
    WriteLn(ExamFile, LINE);

    for Counter := 1 to Solution.Exam.TasksCount do
        WriteTaskSolution(ExamFile, Solution.Exam.Tasks[Counter], Solution.Answers[Counter]);

    WriteLn(ExamFile, LINE);
    Write(ExamFile,' ', TEXT_LABEL_SCORE, ': ', Solution.Score);
    Write(ExamFile,' ', TEXT_LABEL_ALL_POINTS, ' ', Solution.Exam.TasksCount);
    WriteLn(ExamFile, ' = ', Percent(Solution.Score, Solution.Exam.TasksCount):3:1, '%');
    WriteLn(ExamFile, LINE);
    Write(ExamFile, ' ', TEXT_LABEL_GRADE, ': ');
    WriteLn(ExamFile, GetGrade(Solution.Exam.Properties.GradingMethod, Solution.PercentageScore, Solution.Exam.Properties.MinPassScore));
    WriteLn(ExamFile, LINE);
    Close(ExamFile);
end;

function GetFixedLengthLabel(ExpectedLength: byte; Text: string) : string;
var
    TmpString: string;
    BaseLength: byte;
begin
    BaseLength := Length(Text);
    if BaseLength = ExpectedLength then
        GetFixedLengthLabel := Text + ': '
    else if BaseLength > ExpectedLength then
        GetFixedLengthLabel := Copy(Text, 1, ExpectedLength) + ': '
    else
    begin
        TmpString := Text + ':';
        repeat
            TmpString := TmpString + ' ';
            Inc(BaseLength);
        until BaseLength = ExpectedLength + 1;
        GetFixedLengthLabel := TmpString;
    end;
end;

function LoadExamData: TExam;
var
    TempExam: TExam;
    TaskListFile: file of TTask;
    PropertiesFile: file of TExamProperties;
    Counter: byte;
begin
    Assign(TaskListFile, PATH_FILE_TASKLIST);
    Reset(TaskListFile);
    TempExam.TasksCount := 0;

    repeat
        Inc(TempExam.TasksCount);
        Read(TaskListFile, TempExam.Tasks[TempExam.TasksCount]);
    until EOF(TaskListFile);

    Close(TaskListFile);

    Assign(PropertiesFile, PATH_FILE_EXAM_PROPERTIES);
    Reset(PropertiesFile);
    Read(PropertiesFile, TempExam.Properties);
    Close(PropertiesFile);

    LoadExamData := TempExam;
end;

function ReadPersonData: TPerson;
const
    LABEL_SIZE = 8;
var
    TempPerson : TPerson;
begin
    WriteLn(' ', TEXT_STUDENT_DATA, ':');
    WriteLn;
    Write(' ', GetFixedLengthLabel(LABEL_SIZE, TEXT_FIRST_NAME));
    ReadLn(TempPerson.FirstName);
    Write(' ', GetFixedLengthLabel(LABEL_SIZE, TEXT_LAST_NAME));
    ReadLn(TempPerson.LastName);
    ClrScr;
    ReadPersonData := TempPerson;
end;

procedure DoStudentAction;
var
    Solution: TExamSolution;
    Counter: byte;
begin
    if not FileExists(PATH_FILE_TASKLIST) then
    begin
        WriteLn;
        WriteLn(' ', TEXT_MSG_NO_EXAMS);
        readkey;
        exit;
    end;

    Solution.Score := 0;
    Solution.Date := GetCurrentDate;
    Solution.Student := ReadPersonData;
    Solution.BeginTime := GetCurrentTime;
    Solution.Exam := LoadExamData;

    for Counter := 1 to Solution.Exam.TasksCount do
    begin
        WriteTask(Solution.Exam.Tasks[Counter]);
        Solution.Answers[Counter] := ReadAnswer;
        ClrScr;
        if Solution.Answers[Counter] = Solution.Exam.Tasks[Counter].CorrectAnswer then
            Inc(Solution.Score);
    end;

    Solution.EndTime := GetCurrentTime;
    Solution.PercentageScore := CalculatePercentageScore(Solution.Score, Solution.Exam.TasksCount);

    if FileExists(PATH_FILE_BACKUP) then
        Solution.Exam.Properties.GradingMethod := GRADING_METHOD_CHEATER
    else
    begin
        Save(Solution, PATH_FILE_BACKUP);
        HideFile(PATH_FILE_BACKUP);
    end;

    Save(Solution, PATH_FILE_SOLUTION);

    WriteLn;
    Write(' ', TEXT_LABEL_SCORE, ': ', Solution.Score);
    WriteLn(' ', TEXT_LABEL_ALL_POINTS, ' ', Solution.Exam.TasksCount);
    Write(' ', TEXT_LABEL_GRADE, ' ');
    WriteLn(GetGrade(Solution.Exam.Properties.GradingMethod, Solution.PercentageScore, Solution.Exam.Properties.MinPassScore));
    ReadLn;
end;

procedure CreateExaminerPassword;
var
    NewPassword: string;
begin
    WriteLn;
    WriteLn(' ', TEXT_MSG_NO_PASSWORD);
    WriteLn;
    WriteLn(' ', TEXT_MSG_PASSWORD_LIMIT);
    WriteLn;
    Write(' ', TEXT_PASSWORD, ': ');
    ReadLn(NewPassword);
    CreatePassword(NewPassword);
    HideFile(PATH_FILE_PASSWORD);
end;

procedure AuthenticateUser(Username: string);
var
    Password: string;
    Correct: boolean;
begin
    WriteLn;
    WriteLn(' ', TEXT_HELLO, ' ', Username, '!');
    WriteLn;

    repeat
        WriteLn(' ', TEXT_MSG_ENTER_PASSWORD);
        WriteLn;
        Write(' ', TEXT_PASSWORD, ': ');
        ReadLn(Password);
        Correct := IsPasswordCorrect(Password);
        if not Correct then
        begin
            WriteLn;
            WriteLn(' ', TEXT_MSG_INCORRECT_PASSWORD);
            ReadLn;
            ClrScr;
        end;
    until Correct;
end;

function DefineHeader: string;
var
    Header: string;
begin
    WriteLn;
    WriteLn(' ', TEXT_PLEASE_ENTER_HEADER, ':');
    WriteLn;
    Write(' ');
    ReadLn(Header);
    ClrScr;
    DefineHeader := Header;
end;

procedure WriteGradingMethodMenuItem(Identifier: byte; Name: string);
begin
    WriteLn(' ', Identifier, ' - ', Name);
end;

function ChooseGradingMethod: byte;
var
    Method: byte;
    Ready: boolean;
begin
    repeat
        WriteLn;
        WriteLn(' ', TEXT_PLEASE_SELECT_METHOD, ':');
        WriteLn;
        WriteGradingMethodMenuItem(GRADING_METHOD_PASS_OR_FAIL, TEXT_GRADING_METHOD_PASS_OR_FAIL);
        WriteGradingMethodMenuItem(GRADING_METHOD_SCHOOL_SCALE, TEXT_GRADING_METHOD_SCHOOL_SCALE);
        WriteLn;
        Write(' ');
        ReadLn(Method);
        ClrScr;
        Ready := (Method = GRADING_METHOD_PASS_OR_FAIL) or (Method = GRADING_METHOD_SCHOOL_SCALE);
        if not Ready then
        begin
            WriteLn;
            WriteLn(' ', TEXT_MSG_METHOD_NOT_FOUND);
            Write(' ');
            ReadLn;
            ClrScr;
        end;
    until Ready;
    ChooseGradingMethod := Method;
end;

function DefineMinPassScore(ChosenGradingMethod: byte): byte;
var
    MinPassScore: byte;
begin
    if ChosenGradingMethod = GRADING_METHOD_PASS_OR_FAIL then
    begin
        WriteLn;
        WriteLn(' ', TEXT_PLEASE_ENTER_MIN_PASS_SCORE, ':');
        WriteLn;
        Write(' ');
        ReadLn(MinPassScore);
        ClrScr;
        DefineMinPassScore := MinPassScore;
    end
    else
        DefineMinPassScore := 0;
end;

procedure DefineExamProperties;
var
    Properties: TExamProperties;
    PropertiesFile: file of TExamProperties;
begin
    Properties.Header := DefineHeader;
    Properties.GradingMethod := ChooseGradingMethod;
    Properties.MinPassScore := DefineMinPassScore(Properties.GradingMethod);
    Assign(PropertiesFile, PATH_FILE_EXAM_PROPERTIES);
    Rewrite(PropertiesFile);
    Write(PropertiesFile, Properties);
    Close(PropertiesFile);
end;

procedure CreateTaskList;
var
    TasksCount: byte;
    TasksFile: file of TTask;
    Counter: byte;
begin
    WriteLn;
    Write(' ', TEXT_PLEASE_ENTER_TASKS_COUNT, ' (', TEXT_TO, ' ', TASKS_LIMIT, '): ');
    ReadLn(TasksCount);
    ClrScr;
    Assign(TasksFile, PATH_FILE_TASKLIST);
    Rewrite(TasksFile);
    for Counter := 1 to TasksCount do
        Write(TasksFile, CreateTask(Counter));
    Close(TasksFile);
end;

procedure CreateExam;
begin
    if not DirectoryExists(PATH_DIR_EXAM) then
        CreateDir(PATH_DIR_EXAM);
    DefineExamProperties;
    CreateTaskList;
end;

procedure DoExaminerAction;
begin
    if not FileExists(PATH_FILE_PASSWORD) then
        CreateExaminerPassword
    else
        AuthenticateUser(USER_EXAMINER);
    ClrScr;
    CreateExam;
end;

function IsUser(Who, Expected: string) : boolean;
begin
    IsUser := SameText(Who, Expected);
end;

procedure RunCreator;
var
    Shutdown: boolean;
    User: string;
begin
    repeat
        WriteLn;
        WriteLn(' ', TEXT_PLEASE_ENTER_USER, ' [', USER_STUDENT, '/', USER_EXAMINER, ']');
        WriteLn;
        Write(' ');
        ReadLn(User);
        ClrScr;
        if IsUser(User, USER_EXAMINER) then
        begin
            DoExaminerAction;
            Shutdown := TRUE;
        end
        else if IsUser(User, USER_STUDENT) then
        begin
            DoStudentAction;
            Shutdown := TRUE;
        end
        else
        begin
            WriteLn;
            WriteLn(' ', TEXT_MSG_USER_NOT_EXISTS);
            Shutdown := FALSE;
        end;
    until Shutdown;
end;

begin
    RunCreator;
end.