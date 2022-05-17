codeunit 50003 "BIT Import to Data Exch"
{
    Permissions = TableData "Data Exch. Field" = rimd;
    TableNo = "Data Exch.";

    var
        DataExchDef: Record "Data Exch. Def";
        CSVregex: Label '(?:^|%1)(?=[^"]|(")?)"?((?(1)[^"]*|[^%1"]*))"?(?=%1|$)', Locked = true;

    trigger OnRun()
    var
        ReadStream: InStream;
        LineNo: Integer;
        ReadLen: Integer;
        SkippedLineNo: Integer;
        ReadText: Text;
    begin
        DataExchDef.Get(Rec."Data Exch. Def Code");
        case DataExchDef."File Encoding" of
            DataExchDef."File Encoding"::"MS-DOS":
                Rec."File Content".CreateInStream(ReadStream, TextEncoding::MSDos);
            DataExchDef."File Encoding"::"UTF-8":
                Rec."File Content".CreateInStream(ReadStream, TextEncoding::UTF8);
            DataExchDef."File Encoding"::"UTF-16":
                Rec."File Content".CreateInStream(ReadStream, TextEncoding::UTF16);
            DataExchDef."File Encoding"::WINDOWS:
                Rec."File Content".CreateInStream(ReadStream, TextEncoding::Windows);
        end;
        LineNo := 1;
        repeat
            ReadLen := ReadStream.ReadText(ReadText);
            if ReadLen > 0 then
                ParseLine(ReadText, Rec, LineNo, SkippedLineNo);
        until ReadLen = 0;
    end;

    local procedure ParseLine(Line: Text; DataExch: Record "Data Exch."; var LineNo: Integer; var SkippedLineNo: Integer)
    var
        DataExchColumnDef: Record "Data Exch. Column Def";
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        DataExchLineDef.FindFirst;

        if ((LineNo + SkippedLineNo) <= DataExchDef."Header Lines") or
           ((DataExchLineDef."Data Line Tag" <> '') and (StrPos(Line, DataExchLineDef."Data Line Tag") <> 1))
        then begin
            SkippedLineNo += 1;
            exit;
        end;

        DataExchColumnDef.SetRange("Data Exch. Def Code", DataExch."Data Exch. Def Code");
        DataExchColumnDef.SetRange("Data Exch. Line Def Code", DataExchLineDef.Code);
        DataExchColumnDef.FindSet();

        repeat
            InsertRec(DataExch."Entry No.", LineNo, DataExchColumnDef."Column No.", Line, DataExchLineDef.Code);
        until DataExchColumnDef.Next() = 0;
        LineNo += 1;
    end;

    procedure InsertRec(DataExchNo: Integer; LineNo: Integer; ColumnNo: Integer; NewValue: Text; DataExchLineDefCode: Code[20])
    var
        DataExchField: Record "Data Exch. Field";
        TempGroups: Record Groups temporary;
        TempMatches: Record Matches temporary;
        RegEx: Codeunit Regex;
        UseRegExValue: Text;
    begin
        UseRegExValue := strsubstno(CSVregex, DataExchDef.ColumnSeparatorChar());
        RegEx.Match(NewValue, UseRegExValue, TempMatches);

        TempMatches.Get(ColumnNo - 1);
        RegEx.Groups(TempMatches, TempGroups);
        TempGroups.Get(2); //Match 1: "02.01.2022", Group 1: '', Group 2: 02.01.2022

        DataExchField.Init;
        DataExchField.Validate("Data Exch. No.", DataExchNo);
        DataExchField.Validate("Line No.", LineNo);
        DataExchField.Validate("Column No.", ColumnNo);
        DataExchField.Value := TempGroups.ReadValue();
        DataExchField.Validate("Data Exch. Line Def Code", DataExchLineDefCode);
        DataExchField.Insert;
    end;
}

