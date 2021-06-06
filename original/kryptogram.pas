unit kryptogram;                                                                                                                                                                                        {Autor: A.K.}
                                                                                                                                                                                                {Wszelkie prawa zastrzezone!}

interface

        procedure wprowadz_haslo(hw:string);
        function porownaj_haslo(hds:string):boolean;

implementation

        function porownaj_haslo(hds:string):boolean;

        type
                kod = record
                el  : array[1..21] of string;
                dl  : byte
        end;

        var

                licznik : byte; //dˆlugo˜sc haslˆa
                a,b     : byte; //na pozniej
                i,j,k   : byte;
                has     : kod;
                fil     : file of kod;
                tab     : array[1..10] of char;
                tabp    : array[1..10] of char;
        begin
                assign(fil,'pass.dat');
                reset(fil);
                read(fil,has);
                close(fil);

                a:=0;

                for j:=1 to length(hds) do
                tabp[j]:=hds[j];

                for i:=1 to 2*has.dl do begin
                        if i mod 2 = 0 then begin
                                a:=a+1;
                                tab[a]:=has.el[i][1];
                        end;
                end;

                b:=0;

                if has.dl=length(hds) then licznik:=0 else licznik:=1;

                for k:=1 to length(hds) do begin
                        inc(b);
                        if not (tabp[b] = tab[b]) then inc(licznik);
                end;

                if licznik=0 then porownaj_haslo:= TRUE
                else  porownaj_haslo:= FALSE;

        end;

        procedure wprowadz_haslo(hw:string);

                type
                        kod = record
                        el  : array[1..21] of string;
                        dl  : byte;
                end;

                var
                        dh      : byte; //dˆlugo˜sc haslˆa
                        a,b     : byte; //na pozniej
                        i,j,k   : byte;
                        has     : kod;
                        fil     : file of kod;
                        pierwaja: string;
                begin
                        dh := length(hw);
                        has.dl := dh;
                        a := 1;

                        randomize;

                        for i:=1 to dh+1 do begin
                                for j:=0 to random(200) do
                                        has.el[a][j] := char((random(94))+32);
                                inc(a);
                                if a>2*dh then break;
                                has.el[a] := hw[i];
                                inc(a);
                        end;

                        assign(fil,'pass.dat');
                        rewrite(fil);
                        write(fil,has);
                        close(fil);


        end;
begin
end.

