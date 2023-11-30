page 50004 "BIT Copy Sales Comments"
{
    Caption = 'Copy Sales Comments';
    ApplicationArea = All;
    PageType = StandardDialog;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(ContentGrp)
            {
                ShowCaption = false;
                group(FromDocument)
                {
                    Caption = 'From Document';
                    field(FromDocType; FromDocType)
                    {
                        Caption = 'From Document Type';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the From Document Type field.';
                        trigger OnValidate()
                        begin
                            Clear(FromDocNo);
                        end;
                    }
                    field(FromDocNo; FromDocNo)
                    {
                        Caption = 'From Document No.';
                        Editable = false;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the From Document No. field.';
                        trigger OnDrillDown()
                        begin
                            FromDocNo := SelectRecord(FromDocType);
                        end;
                    }
                }
                group(ToDocument)
                {
                    Caption = 'To Document';
                    field(ToDocType; ToDocType)
                    {
                        Caption = 'To Document Type';
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the To Document Type field.';
                        trigger OnValidate()
                        begin
                            Clear(ToDocNo);
                        end;
                    }
                    field(ToDocNo; ToDocNo)
                    {
                        Caption = 'To Document No.';
                        Editable = false;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the To Document No. field.';
                        trigger OnDrillDown()
                        begin
                            ToDocNo := SelectRecord(ToDocType);
                        end;
                    }
                }
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = CloseAction::OK then
            CopyComments();
    end;

    local procedure SelectRecord(DocType: Enum "Sales Comment Document Type"): Code[20]
    var
        RecVar: Variant;
        RecRef: RecordRef;
    begin
        case DocType of
            DocType::Quote, DocType::Order, DocType::Invoice, DocType::"Credit Memo", DocType::"Blanket Order", DocType::"Return Order":
                begin
                    RecRef.Open(Database::"Sales Header");
                    RecRef.Field(1).SetRange(DocType.AsInteger());
                end;
            DocType::Shipment:
                RecRef.Open(Database::"Sales Shipment Header");
            DocType::"Posted Return Receipt":
                RecRef.Open(Database::"Return Receipt Header");
            DocType::"Posted Invoice":
                RecRef.Open(Database::"Sales Invoice Header");
            DocType::"Posted Credit Memo":
                RecRef.Open(Database::"Sales Cr.Memo Header");
        end;

        RecVar := RecRef;
        if Page.RunModal(0, RecVar) <> Action::LookupOK then
            exit;

        RecRef.GetTable(RecVar);
        exit(RecRef.Field(3).Value);
    end;

    local procedure CopyComments()
    var
        FromSalesCommentLine: Record "Sales Comment Line";
        ToSalesCommentLine: Record "Sales Comment Line";
        NewLineNo: Integer;
    begin
        FromSalesCommentLine.SetRange("Document Type", FromDocType);
        FromSalesCommentLine.SetRange("No.", FromDocNo);
        FromSalesCommentLine.SetRange("Document Line No.", 0);
        if FromSalesCommentLine.IsEmpty() then
            exit;

        NewLineNo := 10000;

        ToSalesCommentLine.SetRange("Document Type", ToDocType);
        ToSalesCommentLine.SetRange("No.", ToDocNo);
        ToSalesCommentLine.SetRange("Document Line No.", 0);
        if ToSalesCommentLine.FindLast() then
            NewLineNo += ToSalesCommentLine."Line No.";

        FromSalesCommentLine.FindSet();
        repeat
            ToSalesCommentLine.Init();
            ToSalesCommentLine."Document Type" := ToDocType;
            ToSalesCommentLine."No." := ToDocNo;
            ToSalesCommentLine."Document Line No." := 0;
            ToSalesCommentLine."Line No." := NewLineNo;
            ToSalesCommentLine.Date := FromSalesCommentLine.Date;
            ToSalesCommentLine.Code := FromSalesCommentLine.Code;
            ToSalesCommentLine.Comment := FromSalesCommentLine.Comment;
            ToSalesCommentLine.Insert(true);
            NewLineNo += 10000;
        until FromSalesCommentLine.Next() = 0;

        Message('%1 Comment Line(s) copied.', FromSalesCommentLine.Count());
    end;

    var
        FromDocType: Enum "Sales Comment Document Type";
        FromDocNo: Code[20];

        ToDocType: Enum "Sales Comment Document Type";
        ToDocNo: Code[20];
}