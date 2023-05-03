pageextension 50002 "Customer List Ext." extends "Customer List"
{
    trigger OnOpenPage()
    begin
        Rec.SetFilter(Name, '<>%1', 'Adatum*'); // Works

        Rec.SetFilter(Name, '<>@*%1*', 'Adatum'); // Doesn't work

        Rec.SetFilter(Name, StrSubstNo('<>@*%1*', 'Adatum')); // Works
    end;
}