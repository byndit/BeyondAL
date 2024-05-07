codeunit 50009 "BIT Default Type"
{
    [EventSubscriber(ObjectType::Page, Page::"Sales Order Subform", 'OnBeforeSetDefaultType', '', false, false)]
    local procedure OnBeforeSetDefaultTypeSalesLine(var IsHandled: Boolean; var SalesLine: Record "Sales Line"; var xSalesLine: Record "Sales Line")
    begin
        IsHandled := true;
        SalesLine.Type := SalesLine.GetDefaultLineType();
    end;

    [EventSubscriber(ObjectType::Page, Page::"Purchase Order Subform", 'OnBeforeSetDefaultType', '', false, false)]
    local procedure OnBeforeSetDefaultTypePurchaseLine(var IsHandled: Boolean; var PurchaseLine: Record "Purchase Line"; var xPurchaseLine: Record "Purchase Line")
    begin
        IsHandled := true;
        PurchaseLine.Type := PurchaseLine.GetDefaultLineType();
    end;
}