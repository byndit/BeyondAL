pageextension 50001 "BIT Comment Sheet" extends "Comment Sheet"
{
    layout
    {
        addbefore(Control1)
        {
            part(EditorText; "BIT Comment Editor")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No."), "Table Name" = field("Table Name");
            }
        }
    }
    actions
    {
        addfirst(Processing)
        {
            action(save)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Save';
                Image = Save;
                ToolTip = 'Save text.';
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CurrPage.EditorText.Page.SaveRec();
                    if Rec.FindFirst() then
                        CurrPage.Update(false);
                end;
            }
        }
    }
}