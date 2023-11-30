page 50003 "BIT Comment Editor"
{
    PageType = CardPart;
    Caption = ' ';
    UsageCategory = None;
    SourceTable = "Comment Line";
    SaveValues = false;

    layout
    {
        area(content)
        {
            field(EditorText; Msg)
            {
                ApplicationArea = All;
                MultiLine = true;
                ShowCaption = false;
                ExtendedDatatype = None;
            }
        }
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if xMsg <> Msg then
            if Confirm(ConfirmSaveDataMsg, true) then
                SaveRec();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
    begin
        Found := FindRec(Rec, Which);
        exit(Found);
    end;

    procedure FindRec(var Comments: Record "Comment Line"; Which: Text): Boolean
    var
        CommentLine: Record "Comment Line";
        Found: Boolean;
    begin
        Clear(Msg);

        Comments.FilterGroup := 4;
        CommentLine.CopyFilters(Comments);
        Comments.FilterGroup := 2;

        Found := CommentLine.Find(Which);
        if Found then
            repeat
                if Msg = '' then
                    Msg := CommentLine.Comment
                else
                    Msg += GetLF() + CommentLine.Comment;
            until CommentLine.Next() = 0;
        xMsg := Msg;
        exit(Found);
    end;

    procedure SaveRec()
    var
        CommentLine: Record "Comment Line";
        TempGroups: Record Groups temporary;
        TempMatches: Record Matches temporary;
        RegEx: Codeunit Regex;
        No: Code[20];
        LineNo: Integer;
        CommentLineTableName: Enum "Comment Line Table Name";
        RegExPattern: Text;
        RegExPatternLbl: Label '(?![^\n]{1,%1}$)([^\n]{1,%1})\s', Locked = true;
    begin
        Rec.FilterGroup := 4;
        CommentLine.CopyFilters(Rec);
        if CommentLine.GETFILTER("No.") <> '' then
            No := CopyStr(CommentLine.GETFILTER("No."), 1, 20);
        if CommentLine.GETFILTER("Table Name") <> '' then
            Evaluate(CommentLineTableName, CommentLine.GETFILTER("Table Name"));
        Rec.FilterGroup := 2;
        CommentLine.DeleteAll(true);

        RegExPattern := StrSubstNo(RegExPatternLbl, MaxStrLen(CommentLine.Comment));
        RegEx.Match(Msg, RegExPattern, TempMatches);

        if TempMatches.IsEmpty() then
            exit;

        TempMatches.find('-');
        repeat
            RegEx.Groups(TempMatches, TempGroups);
            TempGroups.Get(1);
            LineNo += 10000;
            CommentLine."No." := No;
            CommentLine."Table Name" := CommentLineTableName;
            CommentLine.Comment := copystr(TempGroups.ReadValue(), 1, MaxStrLen(CommentLine.Comment));
            CommentLine."Line No." := LineNo;
            CommentLine.Date := Today();
            CommentLine.Insert(true);
        until TempMatches.Next() = 0;
        xMsg := Msg;
    end;

    local procedure GetLF(): Text[1]
    var
        Chr: Text[1];
    begin
        Chr[1] := 10;
        exit(Chr);
    end;

    var
        Msg: Text;
        xMsg: Text;
        ConfirmSaveDataMsg: Label 'Do you want to save the changes?';
}