@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
//@ObjectModel.semanticKey: [ ExternalInvoiceID ]
@Search.searchable: true // Enable search
@Consumption.semanticObject: 'VendorInvoice' // For intent-based navigation
define root view entity ZC_VendorInvoiceHead_TP
  provider contract transactional_query
  as projection on ZI_VendorInvoiceHead_TP
{
  key InvoiceUuid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      ExternalInvoiceID,
      //@Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
      CompanyCode,
      //@Consumption.valueHelpDefinition: [{ entity: { name: 'I_SupplierStdVH', element: 'Supplier' } }] // Adjust VH as needed
      VendorNumber,
      InvoiceDate,
      PostingDate,
      DocumentCurrency,
      GrossInvoiceAmount,
      DocumentHeaderText,
      ReferenceDocumentNumber,
     // @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PaymentTermsStdVH', element: 'PaymentTerms' } }]
      PaymentTerms,
      BaselineDate,
      TaxReportingDate,
      ExchangeRate,
      @Consumption.filter.selectionType: #SINGLE // Example for filtering
      @Consumption.filter.mandatory: false
      ProcessingStatus,
      SapDocumentNumber,
      SapFiscalYear,
      ErrorMessage,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      /* Associations */
      //@ObjectModel.association.type: [#TO_COMPOSITION_CHILD] // Expose composition for Fiori elements
      _Items : redirected to composition child ZC_VendorInvoiceItem_TP
}
