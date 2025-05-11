@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Vendor Invoice Header - Transactional'
@ObjectModel.semanticKey: [ 'ExternalInvoiceID' ]
//@ObjectModel.representativeKey: 'ExternalInvoiceID'
//@ObjectModel.transactionalProcessingEnabled: true
//@ObjectModel.writeActivePersistence: 'ZSTG_VEND_INV_H' // Name of the staging table
define root view entity ZI_VendorInvoiceHead_TP
  
  as select from zstg_vend_inv_h as Header
    composition [0..*] of ZI_VendorInvoiceItem_TP as _Items // Composition to items
{
  key Header.invoice_uuid            as InvoiceUuid,
      Header.external_invoice_id     as ExternalInvoiceID,
      Header.company_code            as CompanyCode,
      Header.vendor_number           as VendorNumber,
      Header.invoice_date            as InvoiceDate,
      Header.posting_date            as PostingDate,
      Header.document_currency       as DocumentCurrency,
      Header.gross_invoice_amount    as GrossInvoiceAmount,
      Header.document_header_text    as DocumentHeaderText,
      Header.reference_document_number as ReferenceDocumentNumber,
      Header.payment_terms           as PaymentTerms,
      Header.baseline_date           as BaselineDate,
      Header.tax_reporting_date      as TaxReportingDate,
      Header.exchange_rate           as ExchangeRate,
      Header.processing_status       as ProcessingStatus,
      Header.sap_document_number     as SapDocumentNumber,
      Header.sap_fiscal_year         as SapFiscalYear,
      Header.error_message           as ErrorMessage,
      @EndUserText.label: 'Created By'
      Header.created_by              as CreatedBy,
      //@ObjectModel.readOnly: true
      @EndUserText.label: 'Created At'
      Header.created_at              as CreatedAt,
      //@ObjectModel.readOnly: true
      @EndUserText.label: 'Last Changed By'
      Header.last_changed_by         as LastChangedBy,
      //@ObjectModel.readOnly: true
      @EndUserText.label: 'Last Changed At'
      Header.last_changed_at         as LastChangedAt,

      /* Associations */
      _Items // Make association public
}
 