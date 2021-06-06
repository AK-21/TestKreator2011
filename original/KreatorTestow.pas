program test_kreator; // v.1.2                                                                                                                                                                                                 {Autor: A.K.}
                                                                                                                                                                                                                        {Wszelkie prawa zastrzezone!}
uses crt, dos, windows, sysutils, kryptogram;


function ocena(jak_ocenic,osiagniety_wynik,prog_zdawalnosci:byte):string;
        var skala:byte;
        begin
        //////////////////////////////////////////
        //          Wynik dla czitera           //
        //////////////////////////////////////////
        if jak_ocenic=0 then ocena:='Oszust!'
        else begin
        //////////////////////////////////////////
        //          Zdalˆ / Nie Zdaˆl             //
        //////////////////////////////////////////
             if jak_ocenic=1 then begin
                if (osiagniety_wynik<prog_zdawalnosci) then ocena:='Nie zdal'
                else ocena:='Zdal';
             end
             else begin
        //////////////////////////////////////////
        //          Skala szkolna               //
        //////////////////////////////////////////
                if jak_ocenic=2 then begin
                        if (osiagniety_wynik<30) then writeln('Niedostateczny');
                        if (osiagniety_wynik>=30) and (osiagniety_wynik<50) then ocena:='Dopuszczajacy';
                        if (osiagniety_wynik>=50) and (osiagniety_wynik<70) then ocena:='Dostateczny';
                        if (osiagniety_wynik>=70) and (osiagniety_wynik<90) then ocena:='Dobry';
                        if (osiagniety_wynik>=90) then ocena:='Bardzo Dobry';
                end;
             end;
        end;
        end;


function procent (ile,wsio:integer):real;
        begin
               procent:=((ile*100)/wsio);
        end;

procedure tematzadania(a0:byte; a1,a2,a3,a4:string);
        begin
                writeln;
                writeln(' Pytanie ',a0);
                writeln('  ',a1);
                writeln;
                writeln('  a) ',a2);
                writeln('  b) ',a3);
                writeln('  c) ',a4);
                writeln;
        end;

type
        pytanko = record
        nr      : byte;
        tresc   : string;
        odp_1   : string;
        odp_2   : string;
        odp_3   : string;
        trafna  : string;
        end;

        ustawienia = record
        naglowek   : string;
        sposoc     : byte;
        pz         : byte;
        end;

var
        data         : array[1..4] of word;     // czwarta nieuzywana - dzien tygodnia
        czas_p       : array[1..4] of word;      // czwarta nieuzywana na sec/100
        czas_k       : array[1..4] of word;
        personalia   : array[1..2] of string;
        uzytkownik   : string;
        username     : char;
        zadanie      : array[1..250] of pytanko;
        formularz    : file of pytanko;
        rozwiazany   : text;
        liczba_pytan : byte;
        i,j          : byte;
        udzielona    : array[1..250] of string;
        punkty       : byte;
        rtf          : string;
        nowe_haslo   : string;
        podane_haslo : string;
        ini          : file of ustawienia;
        ust          : ustawienia;
        osiag        : byte;

procedure kreator(var a:byte);  //uzywa zmiennych glob. !!!   Umiescic pod dekl. !!!
        begin

        for i:=1 to a do begin

        zadanie[i].nr:=i;
        writeln;
        writeln(' Pytanie nr ',zadanie[i].nr,':'); writeln; writeln;
        writeln(' Podaj tresc pytania:');
        writeln; write(' '); readln(zadanie[i].tresc); writeln;
        writeln(' Podaj pierwsza odpowiedz:');
        writeln; write(' a) '); readln(zadanie[i].odp_1); writeln;
        writeln(' Podaj druga odpowiedz:');
        writeln; write(' b) '); readln(zadanie[i].odp_2); writeln;
        writeln(' Podaj trzecia odpowiedz:');
        writeln; write(' c) '); readln(zadanie[i].odp_3); writeln;

        repeat
        write(' Ktora odpowiedz jest poprawna? ');
        readln(zadanie[i].trafna);

        for j:=1 to length(zadanie[i].trafna) do
                                        zadanie[i].trafna[j]:= upcase(zadanie[i].trafna[j]);

        if (zadanie[i].trafna<>'A') and (zadanie[i].trafna<>'B') and (zadanie[i].trafna<>'C') then
                                writeln(' Podana odpowiedz nie istnieje! Wprowadz ponownie!');
        until (zadanie[i].trafna='A') or (zadanie[i].trafna='B') or (zadanie[i].trafna='C');
        clrscr;
        end;

        end;

procedure  zapis(var sciezka : string);  //u¾ywa zmiennych glob. !!!   Umie˜ci† pod dekl. !!!
        begin
                assign(rozwiazany,sciezka);
                rewrite(rozwiazany);
                write(rozwiazany,' ',ust.naglowek,#10);
                write(rozwiazany,'--------------------------------------------------------------------------------',#10);
                write(rozwiazany,' Zdajacy: ',personalia[1],' ',personalia[2],#10);
                write(rozwiazany,'--------------------------------------------------------------------------------',#10);
                write(rozwiazany,' Data: ',data[3],'.',data[2],'.',data[1],'.',#10);
                write(rozwiazany,'--------------------------------------------------------------------------------',#10);
                write(rozwiazany,' Czas rozpoczecia: ',czas_p[1],':',czas_p[2],':',czas_p[3],'             Czas zakonczenia: ',czas_k[1],':',czas_k[2],':',czas_k[3],#10);
                write(rozwiazany,'--------------------------------------------------------------------------------',#10);

                        for i:=1 to liczba_pytan do begin
                                write(rozwiazany,#10,' Pytanie ',zadanie[i].nr,#10);
                                write(rozwiazany,' ',zadanie[i].tresc,#10);
                                write(rozwiazany,' a) ',zadanie[i].odp_1,#10);
                                write(rozwiazany,' b) ',zadanie[i].odp_2,#10);
                                write(rozwiazany,' c) ',zadanie[i].odp_3,#10,#10);
                                write(rozwiazany,' Odpowiedz zdajacego:  ',udzielona[i],#10,' Prawidlowa odpowiedz: ',zadanie[i].trafna,#10,#10);
                                if  udzielona[i]=zadanie[i].trafna then
                                        write(rozwiazany,' Punkty za zadanie: 1')
                                        else
                                                write(rozwiazany,' Punkty za zadanie: 0');
                                write(rozwiazany,#10,#10,#10);
                        end;

                write(rozwiazany,'--------------------------------------------------------------------------------',#10);
                write(rozwiazany,' Wynik: ',punkty,' na ',liczba_pytan,' = ',procent(punkty,liczba_pytan):3:1,'%',#10);
                write(rozwiazany,'--------------------------------------------------------------------------------',#10);
                write(rozwiazany,' Ocena: ',ocena(ust.sposoc,trunc(procent(punkty,liczba_pytan)),ust.pz),#10);
                write(rozwiazany,'--------------------------------------------------------------------------------',#10);
                close(rozwiazany);
        end;

begin
        repeat
        writeln; writeln(' Podaj nazwe uzytkownika [Zdajacy/Egzaminator]');
        writeln; write(' '); readln(uzytkownik); clrscr;
        for j:=1 to length(uzytkownik) do
                                        uzytkownik[j]:= upcase(uzytkownik[j]);
        if uzytkownik='EGZAMINATOR' then username:='a' else
                if uzytkownik='ZDAJACY' then username:='b' else begin writeln; writeln(' Podany uzytkownik nie istnieje!'); end;
        until (username='a') or (username='b');

        case username of

(******************************************************************************************************************************************
**************************************CZesc*DLA*EGZAMINATORA*******************************************************************************
******************************************************************************************************************************************)

        'a':begin

        if not fileexists('pass.dat') then begin writeln; writeln(' Brak hasˆla zabezpieczajacego! Utworz nowe hasˆlo!');
        writeln; writeln(' Uwaga! Haslˆo nie moze miec wiecej niz 10 znakow!'); writeln;
        write(' Hasˆo: '); readln(nowe_haslo); wprowadz_haslo(nowe_haslo);

        filesetattr('pass.dat',fahidden);

        end
                else begin
                writeln; writeln(' Witaj ',uzytkownik,'!'); writeln;
                repeat
                        writeln(' Wprowadz haslˆo aby rozpoczac prace z kreatorem.');
                        writeln(); write(' Haslˆo: '); readln(podane_haslo);
                        porownaj_haslo(podane_haslo);
                        if porownaj_haslo(podane_haslo) = FALSE then begin writeln;
                        writeln(' Hasˆlo nieprawidˆowe! Wci˜nij [ENTER] aby kontynuowac!');
                        readln; clrscr;
                        end;
                until porownaj_haslo(podane_haslo) = TRUE;
                end;
         clrscr;
        /////////////////////////////////////////////////////////////////////
        //                Tworzenie testu                                  //
        /////////////////////////////////////////////////////////////////////

                if not directoryexists('C:\Egzamin') then  createdir('C:\Egzamin');

                writeln; writeln(' Wprowadz nagˆlowek:'); writeln; write(' ');
                readln(ust.naglowek); clrscr;

                repeat
                writeln; writeln(' Wybierz sposob oceniania:'); writeln;
                writeln(' 1 - Zdalˆ/Nie Zdalˆ'); writeln(' 2 - Szkolna skala ocen');
                writeln; write(' '); readln(ust.sposoc); clrscr;
                if ust.sposoc=1 then begin
                writeln; writeln(' Zdane od [%]:'); writeln;
                write(' '); readln(ust.pz); clrscr;
                end else begin ust.pz:=0; end;
                if (ust.sposoc<>1) and (ust.sposoc<>2) then begin
                writeln; writeln(' Nie znaleziono! Wybierz ponownie!'); write(' ');
                readln; clrscr;
                end;
                until (ust.sposoc=1) or (ust.sposoc=2);

                assign(ini,'C:\Egzamin\settings.ini');
                rewrite(ini);
                write(ini,ust);
                close(ini);

                writeln;
                write(' Podaj ilo˜sc pytan (do 250): '); readln(liczba_pytan);
                clrscr;

                assign(formularz,'C:\Egzamin\test.data');
                rewrite(formularz);

                        /////////////////////////////
                        //       Wprowadzanie      //
                        /////////////////////////////


                        kreator(liczba_pytan);



                        /////////////////////////////
                        //     Zapis do pliku      //
                        /////////////////////////////

                        for i:=1 to liczba_pytan do

                                write(formularz,zadanie[i]);

                close(formularz);
        end;

(******************************************************************************************************************************************
**************************************CZesc*DLA*ZDAJaCEGO**********************************************************************************
******************************************************************************************************************************************)

        'b':begin

        if not fileexists('C:\Egzamin\test.data') then begin writeln; writeln(' Brak testow do rozwiazania!'); readkey; exit; end;

        punkty:=0;

        getdate(data[1],data[2],data[3],data[4]);

        writeln(' Dane zdajacego:'); writeln;
        write(' Imie:     '); readln(personalia[1]);
        write(' Nazwisko: '); readln(personalia[2]);
        clrscr;

        gettime(czas_p[1],czas_p[2],czas_p[3],czas_p[4]);

        /////////////////////////////////////////////////////////////////////
        //                  Odwoˆlanie do pliku                             //
        /////////////////////////////////////////////////////////////////////

        assign(formularz,'C:\Egzamin\test.data');
        reset(formularz);

                i:=1;
                repeat
                        read(formularz,zadanie[i]);
                        inc(i);
                until eof(formularz);              //Wazne!!! bez tego czyta po dokumencie!!!


        close(formularz);

        assign(ini,'C:\Egzamin\settings.ini');
        reset(ini);
        read(ini,ust);
        close(ini);

        /////////////////////////////////////////////////////////////////////
        //                    Rozwiazanie                                  //
        /////////////////////////////////////////////////////////////////////

             liczba_pytan := i-1;

                for i:=1 to liczba_pytan do begin

                     repeat

                        tematzadania(zadanie[i].nr,zadanie[i].tresc,zadanie[i].odp_1,zadanie[i].odp_2,zadanie[i].odp_3);

                        write(' Odpowiedz: '); readln(udzielona[i]);
                        clrscr;

                        for j:=1 to length(udzielona[i]) do
                                        udzielona[i][j]:= upcase(udzielona[i][j]);

                        if (udzielona[i]<>'A') and (udzielona[i]<>'B') and (udzielona[i]<>'C') then
                                writeln(' Podana odpowiedz nie istnieje! Sprobuj ponownie!');

                     until (udzielona[i]='A') or (udzielona[i]='B') or (udzielona[i]='C');

                     if  udzielona[i]=zadanie[i].trafna then inc(punkty);

                end;

                gettime(czas_k[1],czas_k[2],czas_k[3],czas_k[4]);

                if fileexists('backup.rtf') then ust.sposoc:=0;

                rtf:='C:\Egzamin\test.rtf';

                zapis(rtf);

                ////////////////////////////////////////////
                //      Kopia na wypadek czitowania       //
                ////////////////////////////////////////////

                if not fileexists('backup.rtf') then begin

                rtf:='backup.rtf';

                zapis(rtf);

                filesetattr('backup.rtf',fahidden);

                end;

                ///////////////////////////////////////////

                writeln;
                writeln(' Wynik: ',punkty,' na ', liczba_pytan);
                writeln(' Ocena: ',ocena(ust.sposoc,trunc(procent(punkty,liczba_pytan)),ust.pz));

                readln;

        end;

        end;
end.
