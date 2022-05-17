pageextension 50000 "BIT Data Exch Def Card" extends "Data Exch Def Card"
{
    actions
    {
        addlast(Navigation)
        {
            action(ImportFile)
            {
                ApplicationArea = All;
                Caption = '&Import File';
                Ellipsis = true;
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'To start the process of importing a txt or csv file.';
                Enabled = Rec.Type = Rec.Type::"Generic Import";

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"BIT Import File", Rec);
                end;
            }
        }
    }
}