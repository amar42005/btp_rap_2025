@EndUserText.label: 'Vendor Invoice Item - Consumption'
@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
define view entity ZC_VendorInvoiceItem_TP

  as projection on ZI_VendorInvoiceItem_TP
{
  key ItemUuid,
  key ParentUuid,
      ItemNumber,
      //@Consumption.valueHelpDefinition: [{ entity: { name: 'I_GLAccountInCompanyCodeStdVH', element: 'GLAccount' },
     //                                      additionalBinding: [ { localElement: 'CompanyCode', element: 'CompanyCode', usage: #FILTER } ]
     //                                   }]
      GlAccountNumber,
      AmountInDocumentCurrency,
     // @Consumption.valueHelpDefinition: [{ entity: { name: 'I_TaxCodeStdVH', element: 'TaxCode' } }] // Adjust VH
      TaxCode,
     // @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CostCenterStdVH', element: 'CostCenter' } }]
      CostCenter,
      //@Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProfitCenterStdVH', element: 'ProfitCenter' } }]
      ProfitCenter,
      OrderNumber,
      WbsElement,
      AssignmentNumber,
      ItemText,
      /* Associations */
      _Header : redirected to parent ZC_VendorInvoiceHead_TP
}
